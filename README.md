# RAG AI Project

Sistema de Retrieval-Augmented Generation (RAG) que processa documentos PDF, cria um banco de dados vetorial e responde perguntas baseadas no conteúdo dos documentos usando IA.

## 📁 Estrutura do Projeto

```
RAG-AI PROJECT/
├── backend/              # Código do backend (Python/Flask)
│   ├── app.py           # API Flask principal
│   ├── rag_service.py   # Serviço RAG (lógica de processamento)
│   ├── main.py          # Script CLI para testes
│   ├── criardb.py       # Script para criar o banco de dados vetorial
│   ├── base/            # Pasta com os PDFs a serem processados
│   └── db/              # Banco de dados Chroma (gerado automaticamente)
│
├── frontend/            # Interface web (HTML/CSS/JS)
│   ├── index.html       # Página principal
│   ├── styles.css       # Estilos customizados
│   └── script.js        # Lógica JavaScript
│
├── requirements.txt     # Dependências Python
├── start.sh            # Script para iniciar backend e frontend juntos
├── stop.sh             # Script para parar ambos os serviços
└── README.md           # Este arquivo
```

## 🚀 Como Usar

### Pré-requisitos

- Python 3.8 ou superior
- Node.js (opcional, apenas se quiser usar um servidor local para o frontend)
- Chave de API da OpenAI (configure no arquivo `.env`)

### Instalação

1. **Clone o repositório** (se aplicável)

2. **Instale as dependências Python:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure as variáveis de ambiente:**
   Crie um arquivo `.env` na raiz do projeto com:
   ```
   OPENAI_API_KEY=sua_chave_api_aqui
   ```

4. **Prepare o banco de dados:**
   ```bash
   cd backend
   python criardb.py
   ```
   Isso processará os PDFs na pasta `backend/base/` e criará o banco de dados vetorial em `backend/db/`.

### Executando o Sistema

#### Opção 1: Iniciar Backend e Frontend Juntos (Recomendado)

1. **Inicie ambos os serviços com um único comando:**
   ```bash
   ./start.sh
   ```
   
   Isso iniciará:
   - Backend (Flask) em `http://localhost:5000`
   - Frontend (HTTP Server) em `http://localhost:8000`

2. **Para parar os serviços:**
   ```bash
   ./stop.sh
   ```
   
   Ou pressione `Ctrl+C` no terminal onde o `start.sh` está rodando.

3. **Use a interface:**
   - Acesse `http://localhost:8000` no navegador
   - Digite sua pergunta no campo de texto
   - Clique em "Enviar Pergunta" ou pressione Enter
   - A resposta será exibida abaixo

#### Opção 2: Iniciar Separadamente

**Backend (API Flask):**
```bash
cd backend
python app.py
```
O servidor estará rodando em `http://localhost:5000`

**Frontend:**
```bash
cd frontend
python -m http.server 8000
```
Depois acesse `http://localhost:8000`

### Testando via CLI

Você também pode testar o sistema via linha de comando:

```bash
cd backend
python main.py
```

## 🔧 Configuração

### Adicionando Novos Documentos

1. Coloque os arquivos PDF na pasta `backend/base/`
2. Execute novamente `python criardb.py` para reprocessar

### Ajustando Parâmetros

No arquivo `backend/criardb.py`, você pode ajustar:
- `chunk_size`: Tamanho de cada chunk (padrão: 2000)
- `chunk_overlap`: Sobreposição entre chunks (padrão: 350)

No arquivo `backend/rag_service.py`, você pode ajustar:
- `k=4`: Número de documentos similares a buscar

## 📝 Endpoints da API

### POST `/api/pergunta`
Envia uma pergunta e recebe a resposta processada.

**Request:**
```json
{
  "pergunta": "Sua pergunta aqui"
}
```

**Response:**
```json
{
  "erro": null,
  "resposta": "Resposta da IA baseada nos documentos..."
}
```

### GET `/api/health`
Verifica se a API está funcionando.

**Response:**
```json
{
  "status": "ok",
  "mensagem": "API está funcionando corretamente"
}
```

## 🎨 Personalização

O frontend usa Bootstrap 5 e um tema azul claro. Você pode personalizar as cores editando as variáveis CSS em `frontend/styles.css`:

```css
:root {
    --primary-blue: #5B9BD5;
    --primary-blue-light: #B3D9F2;
    --primary-blue-dark: #4472C4;
    /* ... */
}
```

## 🐛 Solução de Problemas

### Erro de conexão com o backend
- Verifique se o servidor Flask está rodando
- Confirme que a URL no `script.js` está correta (`http://localhost:5000`)

### Erro ao processar PDFs
- Verifique se os PDFs estão na pasta `backend/base/`
- Certifique-se de que as dependências estão instaladas

### Erro de API Key
- Verifique se o arquivo `.env` existe e contém `OPENAI_API_KEY`
- Confirme que a chave é válida

## 📄 Licença

Este projeto é de uso educacional e demonstrativo.

## 👨‍💻 Desenvolvido com

- **Backend:** Python, Flask, LangChain, ChromaDB, OpenAI
- **Frontend:** HTML5, CSS3, JavaScript, Bootstrap 5

