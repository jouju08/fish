from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_core.chat_history import InMemoryChatMessageHistory
from langchain_core.runnables import RunnableLambda
from prompt.prompt import prompt
from model.gemini_model import model
from chain.memory import get_memory
from vectorstore.redis_store import retriever

def retrieve_with_history(input):
    question = input["question"]
    history = input.get("history", [])
    
    return {
        "context": retriever.invoke(question),
        "question": question,
        "history": history
    }

context_retrieval = RunnableLambda(retrieve_with_history)

output_parser=StrOutputParser()
document_chain = create_stuff_documents_chain(llm=model, prompt=prompt)
rag_chain = context_retrieval | document_chain


chain_with_history = RunnableWithMessageHistory(
    rag_chain,
    get_memory,
    input_messages_key="question",
    history_messages_key="history",
)