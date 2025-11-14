from langchain_community.document_loaders import PyPDFDirectoryLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_chroma.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings
from dotenv import load_dotenv

load_dotenv()


PASTA_BASE = "base"

def criar_db():
    # carregar docs
    documentos = carregar_documentos()
    chunks = dividir_docs_em_chunks(documentos)
    vetorizar_chunks(chunks)


def carregar_documentos():
    carregador = PyPDFDirectoryLoader(PASTA_BASE, glob="*.pdf")
    documentos = carregador.load()
    return documentos


# divisão de docs em chunks
def dividir_docs_em_chunks(documentos):

    separador_documentos = RecursiveCharacterTextSplitter(
        chunk_size=2000,           # tamanho de cada chunk
        chunk_overlap=350,         # sobreposição para manter contexto
        length_function=len,
        add_start_index=True,
    )

    chunks = separador_documentos.split_documents(documentos)
    print(f"Número de chunks criados: {len(chunks)}")
    return chunks


# vetorização dos chunks (a ser implementado)
def vetorizar_chunks(chunks):
   db = Chroma.from_documents(chunks, OpenAIEmbeddings(), persist_directory="db")
   print("Database criado com sucesso!")
    
criar_db()
