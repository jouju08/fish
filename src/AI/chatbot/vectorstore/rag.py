import pandas as pd
from langchain_redis import RedisVectorStore
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.docstore.document import Document
from langchain.text_splitter import CharacterTextSplitter
from langchain.chains import RetrievalQA
import re
import os
from dotenv import load_dotenv
load_dotenv()
port = os.getenv("REDIS_INSTNACE_PORT")
adress=os.getenv("REDIS_INSTANCE_ADDRESS")
redis_url=f"redis://{adress}:{port}"

def clean_text(text):
    text = re.sub(r'\s+', ' ', text)
    trash_patterns = [
        r'글/사진', r'낚시누리', r'저작권.*?알려드립니다',
        r'무단으로.*?책임을 질 수.*?유의하시기 바랍니다',
        r'추천 추천', r'이전글 이전글', r'다음글 다음글', r'목록',
        r'\[\w+\]\s*\d+월\s*\w+', 
    ]
    for pattern in trash_patterns:
        text = re.sub(pattern, '', text)
    return text.strip()

def load_csv(path):
    docs=[]
    for name in os.listdir(path):
        if name.endswith(".csv"):
            df=pd.read_csv(os.path.join(path,name))
            for _, row in df.iterrows():
                text=f"제목:{row.get('제목', '')}\n내용:{row.get('내용','')}"
                docs.append(Document(page_content=text, metadata={"source": name}))
    cleaned_docs = []
    for doc in docs:
        cleaned_content = clean_text(doc.page_content)
        if len(cleaned_content) > 100:  # 너무 짧으면 의미 없으니 필터링
            cleaned_docs.append(Document(
                page_content=cleaned_content,
                metadata=doc.metadata
            ))
    return cleaned_docs


def split_documents(docs):
    splitter = CharacterTextSplitter(separator="\n", chunk_size=1000, chunk_overlap=100)
    return splitter.split_documents(docs)


def create_vector_store(documents):
    embeddings = OpenAIEmbeddings()
    vector_store=RedisVectorStore(embeddings, redis_url=redis_url,index_name="fishing-infomation")
    vector_store.add_documents(documents)
    return vector_store

folder = "/home/juha/Desktop/git/S12P21C201/src/AI/chatbot/fishing_data"
raw_docs = load_csv(folder)
split_docs = split_documents(raw_docs)
vectorstore = create_vector_store(split_docs)
