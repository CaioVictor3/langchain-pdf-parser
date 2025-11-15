"""
Serviço RAG (Retrieval-Augmented Generation)
Função principal que processa perguntas e retorna respostas baseadas nos documentos
"""

from langchain_chroma.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv
import os

load_dotenv()

CAMINHO_DB = "db"

prompt_template = """Você é um assistente de IA especializado em responder perguntas:
{pergunta}
com base em documentos fornecidos. Use as informações dos documentos para formular suas respostas:
{base_de_conhecimento}
"""

def processar_pergunta(pergunta: str) -> str:
    """
    Função principal que recebe uma pergunta, processa a busca nos PDFs e retorna a resposta como string.
    
    Args:
        pergunta (str): A pergunta do usuário
        
    Returns:
        str: A resposta processada pela IA baseada nos documentos
    """
    try:
        # Inicializa embeddings e banco de dados vetorial
        funcao_embeddings = OpenAIEmbeddings()
        db = Chroma(persist_directory=CAMINHO_DB, embedding_function=funcao_embeddings)
        
        # Busca documentos similares
        resultados = db.similarity_search(pergunta, k=4)
        
        # Verifica se encontrou resultados
        if len(resultados) == 0:
            return "Desculpe, não tenho essa informação no momento."
        
        # Extrai o conteúdo dos documentos encontrados
        textos_resultado = []
        for resultado in resultados:
            texto = resultado.page_content
            textos_resultado.append(texto)
        
        # Junta os textos em uma base de conhecimento
        base_conhecimento = "\n\n----\n\n".join(textos_resultado)
        
        # Cria e invoca o prompt
        prompt = ChatPromptTemplate.from_template(prompt_template)
        prompt_invocado = prompt.invoke({
            "pergunta": pergunta,
            "base_de_conhecimento": base_conhecimento
        })
        
        # Gera a resposta usando o modelo de IA
        modelo = ChatOpenAI()
        texto_resposta = modelo.invoke(prompt_invocado).content
        
        return texto_resposta
        
    except Exception as e:
        return f"Erro ao processar pergunta: {str(e)}"

