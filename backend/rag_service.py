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

prompt_template = """Você é um assistente de IA especializado em responder perguntas com base em documentos fornecidos.

Pergunta do usuário:
{pergunta}

Base de conhecimento (com informações sobre a fonte de cada trecho):
{base_de_conhecimento}

Instruções:
-Responda sempre de forma organizada, clara e objetiva.
-Ao explicar procedimentos, utilize tópicos ou passos estruturados sempre que possível.
-Se a informação solicitada não estiver presente nos documentos fornecidos, informe claramente que essa informação não está disponível.
-Ao finalizar uma resposta, não declare que não existem mais passos ou informações adicionais; simplesmente encerre a explicação.
-Priorize precisão e simplicidade, evitando detalhes desnecessários.
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

        funcao_embeddings = OpenAIEmbeddings()
        db = Chroma(persist_directory=CAMINHO_DB, embedding_function=funcao_embeddings)


        # Busca documentos similares com metadados
        resultados = db.similarity_search_with_score(pergunta, k=4)
        

        if len(resultados) == 0:
            return "Desculpe, não tenho essa informação no momento."
        

        textos_resultado = []
        fontes_usadas = set()  # Para rastrear quais PDFs foram usados
        
        for resultado, score in resultados:
            texto = resultado.page_content
            fonte = resultado.metadata.get('fonte', 'Documento desconhecido')
            arquivo = resultado.metadata.get('arquivo', 'arquivo_desconhecido.pdf')
            pagina = resultado.metadata.get('page', 'N/A')
            
            # Adiciona informação da fonte ao texto
            texto_com_fonte = f"[Fonte: {fonte} - Página {pagina}]\n{texto}"
            textos_resultado.append(texto_com_fonte)
            fontes_usadas.add(fonte)
        

        # Junta os textos com separador e adiciona informação sobre as fontes
        base_conhecimento = "\n\n----\n\n".join(textos_resultado)
        
        # Adiciona informação sobre quais documentos foram consultados
        if fontes_usadas:
            fontes_info = f"\n\n[Documentos consultados: {', '.join(sorted(fontes_usadas))}]"
            base_conhecimento = base_conhecimento + fontes_info
        

        prompt = ChatPromptTemplate.from_template(prompt_template)
        prompt_invocado = prompt.invoke({
            "pergunta": pergunta,
            "base_de_conhecimento": base_conhecimento
        })
        

        modelo = ChatOpenAI()
        texto_resposta = modelo.invoke(prompt_invocado).content
        
        return texto_resposta
        
    except Exception as e:
        return f"Erro ao processar pergunta: {str(e)}"

