"""
API Flask para o sistema RAG (Retrieval-Augmented Generation)
Recebe perguntas e retorna respostas baseadas nos documentos processados
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from rag_service import processar_pergunta
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)  # Permite requisições do frontend

@app.route('/api/pergunta', methods=['POST'])
def pergunta():
    """
    Endpoint que recebe uma pergunta e retorna a resposta processada
    """
    try:
        data = request.get_json()
        
        if not data or 'pergunta' not in data:
            return jsonify({
                'erro': 'Pergunta não fornecida',
                'resposta': None
            }), 400
        
        pergunta_usuario = data['pergunta']
        
        if not pergunta_usuario or not pergunta_usuario.strip():
            return jsonify({
                'erro': 'Pergunta não pode estar vazia',
                'resposta': None
            }), 400
        
        # Processa a pergunta e obtém a resposta
        resposta = processar_pergunta(pergunta_usuario)
        
        return jsonify({
            'erro': None,
            'resposta': resposta
        }), 200
        
    except Exception as e:
        return jsonify({
            'erro': f'Erro ao processar pergunta: {str(e)}',
            'resposta': None
        }), 500

@app.route('/api/health', methods=['GET'])
def health():
    """
    Endpoint de health check
    """
    return jsonify({
        'status': 'ok',
        'mensagem': 'API está funcionando corretamente'
    }), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5001))
    app.run(debug=True, host='0.0.0.0', port=port)

