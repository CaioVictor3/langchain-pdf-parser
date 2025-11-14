from langchain_community.document_loaders import PyPDFDirectoryLoader
from lancgchain.text_splitter import RecursiveCharacterTextSplitter #percorre documento e divide em chunks

PASTA_BASE = "base"

def criar_db():
    #carregar docs
    documentos = carregar_documentos()
    print(documentos)
   # chunks = dividir_docs_em_chunks(documentos)   
   # vetorizar_chunks(chunks)
    
def carregar_documentos():
    carregador = PyPDFDirectoryLoader(PASTA_BASE, glob="*.pdf")
    documentos = carregador.load()
    return documentos

def dividir_docs_em_chunks(documentos):

    separador_documentos= RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200,
        length_function=len,
    )
    
    return chunks

    #divisao de docs em chunks

    #vetorizacao dos cunks em embeding



criar_db()

#pip install python-dotenv langchain langchain-openai langchain-community langchain-chroma chromadb openai pypdf