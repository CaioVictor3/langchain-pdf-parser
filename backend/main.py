"""
Script CLI para testar o sistema RAG via linha de comando
"""

from rag_service import processar_pergunta

def main():
    """
    Função principal para interface de linha de comando
    """
    pergunta_usuario = input("Digite sua pergunta: ")
    resposta = processar_pergunta(pergunta_usuario)
    print("Resposta da IA:", resposta)

if __name__ == "__main__":
    main()