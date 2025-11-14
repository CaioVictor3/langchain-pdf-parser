from langchain_chroma.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv

load_dotenv()

CAMINHO_DB = "db"

prompt_template = """Você é um assistente de IA especializado em responder perguntas:
{pergunta}
com base em documentos fornecidos. Use as informações dos documentos para formular suas respostas:
{base_de_conhecimento}
Se a informação não estiver disponível nos documentos, responda com "Desculpe, não tenho essa informação no momento."""

def pergunta():

 pergunta = input("Digite sua pergunta: ")

 funcao_embeddings = OpenAIEmbeddings()
 db = Chroma(persist_directory=CAMINHO_DB, embedding_function=funcao_embeddings)

 resultados = db.similarity_search(pergunta, k=4)

 if(len(resultados) == 0) or resultados[0][1] < 0.7 :
  print("Desculpe, não tenho essa informação no momento.")


 print(resultados)
 print(f"Número de documentos recuperados: {len(resultados)}")
 return

textos_resultado = []
for resultado in resultados:
 texto = resultado[0].page_content
 textos_resultado.append(texto)

base_conhecimento = "\n\n----\n\n".join(textos_resultado)


prompt = ChatPromptTemplate.from_template(prompt_template)
prompt = prompt.invoke({"pergunta": pergunta, "base_de_conhecimento": base_conhecimento})

modelo = ChatOpenAI()
texto_resposta = modelo.invoke(prompt)
print("Resposta da IA:", texto_resposta)

pergunta()