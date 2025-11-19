from langchain_community.document_loaders import PyPDFDirectoryLoader, PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_chroma.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings
from dotenv import load_dotenv
import os

load_dotenv()


PASTA_BASE = "base"

def criar_db():
    # carregar docs
    documentos = carregar_documentos()
    chunks = dividir_docs_em_chunks(documentos)
    vetorizar_chunks(chunks)


def carregar_documentos():
    """
    Carrega todos os PDFs da pasta base e adiciona metadados para identificar a origem
    """
    documentos = []
    
    # Lista todos os PDFs na pasta base
    if os.path.exists(PASTA_BASE):
        arquivos_pdf = [f for f in os.listdir(PASTA_BASE) if f.endswith('.pdf')]
        
        for arquivo_pdf in arquivos_pdf:
            caminho_completo = os.path.join(PASTA_BASE, arquivo_pdf)
            print(f"Carregando: {arquivo_pdf}")
            
            # Carrega o PDF individualmente
            carregador = PyPDFLoader(caminho_completo)
            docs_pdf = carregador.load()
            
            # Adiciona metadados para identificar o PDF de origem
            nome_arquivo = os.path.splitext(arquivo_pdf)[0]  # Remove a extensão .pdf
            
            for doc in docs_pdf:
                # Adiciona metadados ao documento
                doc.metadata['fonte'] = nome_arquivo
                doc.metadata['arquivo'] = arquivo_pdf
                doc.metadata['tipo'] = 'pdf'
            
            documentos.extend(docs_pdf)
            print(f"  → {len(docs_pdf)} páginas carregadas de {arquivo_pdf}")
    
    print(f"\nTotal de documentos carregados: {len(documentos)}")
    return documentos


# divisão de docs em chunks
def dividir_docs_em_chunks(documentos):
    """
    Divide os documentos em chunks, preservando os metadados de origem
    """
    separador_documentos = RecursiveCharacterTextSplitter(
        chunk_size=2000,           # tamanho de cada chunk
        chunk_overlap=350,         # sobreposição para manter contexto
        length_function=len,
        add_start_index=True,
    )

    chunks = separador_documentos.split_documents(documentos)
    
    # Conta chunks por fonte
    fontes = {}
    for chunk in chunks:
        fonte = chunk.metadata.get('fonte', 'desconhecido')
        fontes[fonte] = fontes.get(fonte, 0) + 1
    
    print(f"\nNúmero total de chunks criados: {len(chunks)}")
    for fonte, quantidade in fontes.items():
        print(f"  → {fonte}: {quantidade} chunks")
    
    return chunks


# vetorização dos chunks
def vetorizar_chunks(chunks):
   db = Chroma.from_documents(chunks, OpenAIEmbeddings(), persist_directory="db")
   print("Database criado com sucesso!")
    
criar_db()
