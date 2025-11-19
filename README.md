# 🤖 Assistente PDF - Chatbot com RAG

Sistema de chatbot inteligente que utiliza RAG (Retrieval-Augmented Generation) para responder perguntas baseadas em documentos PDF. O sistema consiste em um backend Flask com processamento de documentos e um frontend React moderno.

## 📋 Índice

- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalação](#-instalação)
- [Configuração](#-configuração)
- [Uso](#-uso)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Scripts Disponíveis](#-scripts-disponíveis)
- [Troubleshooting](#-troubleshooting)
- [Tecnologias Utilizadas](#-tecnologias-utilizadas)

## ✨ Características

- **RAG (Retrieval-Augmented Generation)**: Busca informações relevantes em documentos PDF antes de gerar respostas
- **Interface Moderna**: Frontend React com UI responsiva e intuitiva
- **Histórico de Conversas**: Sistema de threads que salva todas as conversas
- **Backend Flask**: API REST simples e eficiente
- **Armazenamento Local**: Threads salvas no localStorage do navegador
- **Suporte a Múltiplos Documentos**: Processa e indexa múltiplos PDFs

## 🔧 Requisitos

- **Python 3.8+**
- **Node.js 14+** e **npm**
- **Chave API OpenAI** (para embeddings e geração de texto)

## 📦 Instalação

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd my-chat-ui
```

### 2. Configure o Backend

```bash
cd backend
```

Crie um arquivo `.env` com suas credenciais:

```env
OPENAI_API_KEY=sua_chave_openai_aqui
PORT=5001
```

Instale as dependências Python:

```bash
# Opcional: criar ambiente virtual
python3 -m venv venv
source venv/bin/activate  # No Windows: venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt
```

### 3. Configure o Frontend

```bash
cd apps/web
npm install
```

## ⚙️ Configuração

### Backend

1. **Variáveis de Ambiente** (`backend/.env`):
   - `OPENAI_API_KEY`: Sua chave da API OpenAI
   - `PORT`: Porta do servidor Flask (padrão: 5001)

2. **Documentos PDF**:
   - Coloque seus PDFs na pasta `backend/base/`
   - Execute o script de indexação (se necessário):
   ```bash
   cd backend
   python criardb.py
   ```

### Frontend

O frontend detecta automaticamente se está usando o backend Flask ou LangGraph. Para usar o Flask:

- URL padrão: `http://localhost:5001`
- Não é necessário configurar Assistant ID para Flask

## 🚀 Uso

### Início Rápido

A forma mais fácil de iniciar o projeto é usando o script `start.sh`:

```bash
./start.sh
```

Este script:
- Verifica dependências
- Instala pacotes se necessário
- Inicia o backend Flask na porta 5001
- Inicia o frontend na porta 5173

### Início Manual

#### Backend

```bash
cd backend
python3 app.py
# ou se tiver venv:
venv/bin/python app.py
```

O backend estará disponível em: `http://localhost:5001`

#### Frontend

```bash
cd apps/web
npm run dev
```

O frontend estará disponível em: `http://localhost:5173`

### Parar os Serviços

Use o script `stop.sh`:

```bash
./stop.sh
```

Ou pressione `Ctrl+C` no terminal onde o `start.sh` está rodando.

## 📁 Estrutura do Projeto

```
my-chat-ui/
├── backend/                 # Backend Flask
│   ├── app.py              # Aplicação Flask principal
│   ├── rag_service.py      # Serviço RAG (processamento de documentos)
│   ├── criardb.py          # Script para criar índice de documentos
│   ├── requirements.txt    # Dependências Python
│   ├── .env                # Variáveis de ambiente (criar)
│   ├── base/               # PDFs a serem processados
│   └── db/                 # Banco de dados Chroma (gerado automaticamente)
│
├── apps/
│   └── web/                # Frontend React
│       ├── src/
│       │   ├── components/ # Componentes React
│       │   ├── providers/   # Context providers (Stream, Thread)
│       │   └── lib/        # Utilitários e helpers
│       └── package.json
│
├── start.sh                # Script para iniciar tudo
├── stop.sh                 # Script para parar tudo
└── README.md               # Este arquivo
```

## 📜 Scripts Disponíveis

### `start.sh`
Inicia o backend e frontend automaticamente.

**Funcionalidades:**
- Verifica dependências (Python, Node.js, npm)
- Instala dependências automaticamente se necessário
- Cria ambiente virtual Python se não existir
- Inicia backend Flask na porta 5001
- Inicia frontend na porta 5173
- Monitora processos e limpa ao sair

### `stop.sh`
Para todos os processos do backend e frontend.

**Funcionalidades:**
- Para processos do backend Flask
- Para processos do frontend
- Limpa processos órfãos
- Libera portas 5001 e 5173

## 🔍 Troubleshooting

### Backend não inicia

**Problema**: Erro ao iniciar o Flask

**Soluções:**
1. Verifique se o arquivo `.env` existe e tem `OPENAI_API_KEY`
2. Verifique se as dependências estão instaladas: `pip install -r requirements.txt`
3. Verifique os logs em `.backend.log`

### Frontend não inicia

**Problema**: Erro ao iniciar o Vite

**Soluções:**
1. Verifique se as dependências estão instaladas: `cd apps/web && npm install`
2. Verifique os logs em `.frontend.log`
3. Verifique se a porta 5173 está livre

### Porta já em uso

**Problema**: Porta 5001 ou 5173 já está em uso

**Soluções:**
```bash
# Ver processos na porta
lsof -i :5001
lsof -i :5173

# Matar processo específico
kill -9 <PID>
```

Ou use o script `stop.sh` para limpar tudo.

### Erro de conexão no frontend

**Problema**: "Não foi possível conectar ao backend"

**Soluções:**
1. Verifique se o backend está rodando: `curl http://localhost:5001/api/health`
2. Verifique se a URL está correta no frontend
3. Verifique se não há problemas de CORS (o Flask já tem CORS habilitado)

### Threads não aparecem no histórico

**Problema**: Conversas não são salvas

**Soluções:**
1. Verifique se o navegador permite localStorage
2. Abra o console do navegador (F12) e verifique erros
3. Verifique se há espaço suficiente no localStorage

### Erro "ModuleNotFoundError"

**Problema**: Módulo Python não encontrado

**Soluções:**
1. Instale as dependências: `pip install -r requirements.txt`
2. Se usar venv, ative-o antes: `source venv/bin/activate`
3. Verifique se está usando o Python correto: `which python3`

## 🛠️ Tecnologias Utilizadas

### Backend
- **Flask**: Framework web Python
- **Flask-CORS**: Suporte a CORS
- **LangChain**: Framework para aplicações LLM
- **Chroma**: Banco de dados vetorial
- **OpenAI**: Embeddings e geração de texto

### Frontend
- **React 19**: Biblioteca UI
- **TypeScript**: Tipagem estática
- **Vite**: Build tool e dev server
- **Tailwind CSS**: Framework CSS
- **LangGraph SDK**: Integração com LangGraph (opcional)

## 📝 Notas Importantes

1. **Armazenamento**: As threads são salvas no `localStorage` do navegador. Se você limpar os dados do navegador, as conversas serão perdidas.

2. **Documentos**: Os PDFs devem estar na pasta `backend/base/` e devem ser processados antes de usar (execute `criardb.py`).

3. **API Key**: A chave da OpenAI é necessária tanto para embeddings quanto para geração de respostas.

4. **Performance**: O primeiro processamento de documentos pode demorar. Após indexado, as buscas são rápidas.

