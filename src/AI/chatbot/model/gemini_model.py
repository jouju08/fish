import os
from dotenv import load_dotenv
from langchain_teddynote import logging
from langchain_google_genai import ChatGoogleGenerativeAI


load_dotenv()
logging.langsmith("that-water_GENAI")
model=ChatGoogleGenerativeAI(
    model="gemini-1.5-flash", 
)