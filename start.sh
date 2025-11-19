#!/bin/bash

# Script para inicializar o backend Flask e o frontend
# Uso: ./start.sh

# set -e removido temporariamente para melhor tratamento de erros
# Vamos tratar erros manualmente onde necessário

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretórios
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/apps/web"

# PID files para gerenciar processos
BACKEND_PID_FILE="$ROOT_DIR/.backend.pid"
FRONTEND_PID_FILE="$ROOT_DIR/.frontend.pid"

# Função para limpar processos ao sair
cleanup() {
    echo -e "\n${YELLOW}Parando processos...${NC}"
    
    if [ -f "$BACKEND_PID_FILE" ]; then
        BACKEND_PID=$(cat "$BACKEND_PID_FILE")
        if ps -p "$BACKEND_PID" > /dev/null 2>&1; then
            echo -e "${BLUE}Parando backend Flask (PID: $BACKEND_PID)...${NC}"
            kill "$BACKEND_PID" 2>/dev/null || true
        fi
        rm -f "$BACKEND_PID_FILE"
    fi
    
    if [ -f "$FRONTEND_PID_FILE" ]; then
        FRONTEND_PID=$(cat "$FRONTEND_PID_FILE")
        if ps -p "$FRONTEND_PID" > /dev/null 2>&1; then
            echo -e "${BLUE}Parando frontend (PID: $FRONTEND_PID)...${NC}"
            kill "$FRONTEND_PID" 2>/dev/null || true
        fi
        rm -f "$FRONTEND_PID_FILE"
    fi
    
    # Mata processos Python e Node que possam ter ficado órfãos
    pkill -f "python.*app.py" 2>/dev/null || true
    pkill -f "vite" 2>/dev/null || true
    
    echo -e "${GREEN}Limpeza concluída!${NC}"
    exit 0
}

# Configura trap para limpar ao sair
trap cleanup SIGINT SIGTERM EXIT

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificações iniciais
echo -e "${BLUE}=== Verificando dependências ===${NC}"

# Verifica Python
if ! command_exists python3; then
    echo -e "${RED}Erro: Python 3 não está instalado!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python 3 encontrado${NC}"

# Verifica Node.js
if ! command_exists node; then
    echo -e "${RED}Erro: Node.js não está instalado!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js encontrado: $(node --version)${NC}"

# Verifica npm
if ! command_exists npm; then
    echo -e "${RED}Erro: npm não está instalado!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ npm encontrado: $(npm --version)${NC}"

# Verifica se as dependências do frontend estão instaladas
if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
    echo -e "${YELLOW}⚠ Dependências do frontend não encontradas. Instalando...${NC}"
    cd "$FRONTEND_DIR" || exit 1
    npm install || {
        echo -e "${RED}Erro ao instalar dependências do frontend${NC}"
        exit 1
    }
    cd "$ROOT_DIR" || exit 1
else
    echo -e "${GREEN}✓ Dependências do frontend encontradas${NC}"
fi

# Verifica se as dependências da raiz estão instaladas
if [ ! -d "$ROOT_DIR/node_modules" ]; then
    echo -e "${YELLOW}⚠ Dependências da raiz não encontradas. Instalando...${NC}"
    cd "$ROOT_DIR" || exit 1
    npm install || {
        echo -e "${RED}Erro ao instalar dependências da raiz${NC}"
        exit 1
    }
else
    echo -e "${GREEN}✓ Dependências da raiz encontradas${NC}"
fi

# Verifica se o ambiente virtual Python existe (opcional)
if [ ! -d "$BACKEND_DIR/venv" ]; then
    echo -e "${YELLOW}⚠ Ambiente virtual Python não encontrado.${NC}"
    echo -e "${YELLOW}  Criando ambiente virtual...${NC}"
    cd "$BACKEND_DIR" || exit 1
    python3 -m venv venv || {
        echo -e "${RED}Erro ao criar ambiente virtual${NC}"
        exit 1
    }
    cd "$ROOT_DIR" || exit 1
    echo -e "${GREEN}✓ Ambiente virtual criado${NC}"
fi

# Garante que o caminho está correto mesmo com espaços
PYTHON_CMD="$BACKEND_DIR/venv/bin/python"
# Verifica se o executável existe
if [ ! -f "$PYTHON_CMD" ]; then
    echo -e "${YELLOW}⚠ Python do venv não encontrado, usando python3 do sistema${NC}"
    PYTHON_CMD="python3"
else
    echo -e "${GREEN}✓ Ambiente virtual encontrado${NC}"
fi

# Verifica e instala dependências Python
if [ -f "$BACKEND_DIR/requirements.txt" ]; then
    echo -e "${BLUE}Verificando dependências Python...${NC}"
    cd "$BACKEND_DIR" || exit 1
    # Verifica se as dependências estão instaladas (testa flask)
    if ! "$PYTHON_CMD" -c "import flask" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ Dependências Python não encontradas no ambiente atual.${NC}"
        echo -e "${YELLOW}  Instalando dependências...${NC}"
        "$PYTHON_CMD" -m pip install --upgrade pip >/dev/null 2>&1 || true
        if "$PYTHON_CMD" -m pip install -r requirements.txt; then
            echo -e "${GREEN}✓ Dependências Python instaladas${NC}"
        else
            echo -e "${RED}Erro ao instalar dependências Python${NC}"
            echo -e "${YELLOW}Tentando usar Python do sistema...${NC}"
            # Se falhar e estiver usando venv, tenta usar python3 do sistema
            if [ "$PYTHON_CMD" != "python3" ] && python3 -c "import flask" >/dev/null 2>&1; then
                echo -e "${YELLOW}Usando Python do sistema (que já tem Flask instalado)${NC}"
                PYTHON_CMD="python3"
            else
                echo -e "${RED}Erro: Não foi possível instalar ou encontrar Flask${NC}"
                exit 1
            fi
        fi
    else
        echo -e "${GREEN}✓ Dependências Python encontradas${NC}"
    fi
    cd "$ROOT_DIR" || exit 1
else
    echo -e "${YELLOW}⚠ Arquivo requirements.txt não encontrado no backend${NC}"
    # Verifica se Flask está disponível no Python atual
    if ! "$PYTHON_CMD" -c "import flask" >/dev/null 2>&1; then
        echo -e "${RED}Erro: Flask não está instalado e requirements.txt não existe${NC}"
        exit 1
    fi
fi

# Verifica se o arquivo .env existe no backend
if [ ! -f "$BACKEND_DIR/.env" ]; then
    echo -e "${YELLOW}⚠ Arquivo .env não encontrado no backend${NC}"
    echo -e "${YELLOW}  Certifique-se de criar um arquivo .env com as variáveis necessárias${NC}"
fi

# Inicia o backend Flask
echo -e "\n${BLUE}=== Iniciando Backend Flask ===${NC}"
cd "$BACKEND_DIR" || {
    echo -e "${RED}Erro: Não foi possível acessar o diretório do backend: $BACKEND_DIR${NC}"
    exit 1
}

# Verifica se já existe um processo rodando na porta 5001
if command_exists lsof; then
    if lsof -Pi :5001 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}⚠ Porta 5001 já está em uso!${NC}"
        echo -e "${YELLOW}  Parando processo existente...${NC}"
        lsof -ti:5001 | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
else
    # Fallback: tenta usar netstat ou apenas continua
    if command_exists netstat; then
        if netstat -an | grep -q ":5001.*LISTEN"; then
            echo -e "${YELLOW}⚠ Porta 5001 pode estar em uso${NC}"
        fi
    fi
fi

echo -e "${GREEN}Iniciando Flask na porta 5001...${NC}"
# Executa o Python no diretório do backend, redirecionando o output
(cd "$BACKEND_DIR" && "$PYTHON_CMD" app.py > "$ROOT_DIR/.backend.log" 2>&1) &
BACKEND_PID=$!
echo $BACKEND_PID > "$BACKEND_PID_FILE"
echo -e "${GREEN}✓ Backend iniciado (PID: $BACKEND_PID)${NC}"

# Aguarda o backend iniciar
sleep 3

# Verifica se o backend está rodando
sleep 2  # Aguarda um pouco mais antes de verificar
if ! ps -p "$BACKEND_PID" > /dev/null 2>&1; then
    echo -e "${RED}Erro: Backend não iniciou corretamente!${NC}"
    echo -e "${RED}Verifique o log: $ROOT_DIR/.backend.log${NC}"
    if [ -f "$ROOT_DIR/.backend.log" ]; then
        cat "$ROOT_DIR/.backend.log"
    fi
    exit 1
fi

# Testa se o backend está respondendo (aguarda um pouco mais)
sleep 2
if command_exists curl; then
    if curl -s http://localhost:5001/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Backend está respondendo${NC}"
    else
        echo -e "${YELLOW}⚠ Backend pode não estar pronto ainda${NC}"
    fi
else
    echo -e "${YELLOW}⚠ curl não encontrado, pulando verificação de health${NC}"
fi

# Inicia o frontend
echo -e "\n${BLUE}=== Iniciando Frontend ===${NC}"
cd "$FRONTEND_DIR" || {
    echo -e "${RED}Erro: Não foi possível acessar o diretório do frontend: $FRONTEND_DIR${NC}"
    exit 1
}

# Verifica se já existe um processo rodando na porta padrão do Vite (5173)
if command_exists lsof; then
    if lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}⚠ Porta 5173 já está em uso!${NC}"
        echo -e "${YELLOW}  Parando processo existente...${NC}"
        lsof -ti:5173 | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
else
    # Fallback: tenta usar netstat ou apenas continua
    if command_exists netstat; then
        if netstat -an | grep -q ":5173.*LISTEN"; then
            echo -e "${YELLOW}⚠ Porta 5173 pode estar em uso${NC}"
        fi
    fi
fi

echo -e "${GREEN}Iniciando frontend...${NC}"
npm run dev > "$ROOT_DIR/.frontend.log" 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > "$FRONTEND_PID_FILE"
echo -e "${GREEN}✓ Frontend iniciado (PID: $FRONTEND_PID)${NC}"

# Aguarda o frontend iniciar
sleep 5

# Verifica se o frontend está rodando
if ! ps -p "$FRONTEND_PID" > /dev/null 2>&1; then
    echo -e "${RED}Erro: Frontend não iniciou corretamente!${NC}"
    echo -e "${RED}Verifique o log: $ROOT_DIR/.frontend.log${NC}"
    cat "$ROOT_DIR/.frontend.log"
    exit 1
fi

# Resumo
echo -e "\n${GREEN}=== Tudo pronto! ===${NC}"
echo -e "${GREEN}Backend Flask:${NC} http://localhost:5001"
echo -e "${GREEN}Frontend:${NC} http://localhost:5173"
echo -e "\n${YELLOW}Logs:${NC}"
echo -e "  Backend: $ROOT_DIR/.backend.log"
echo -e "  Frontend: $ROOT_DIR/.frontend.log"
echo -e "\n${YELLOW}Pressione Ctrl+C para parar tudo${NC}\n"

# Monitora os processos
while true; do
    # Verifica se o backend ainda está rodando
    if [ -f "$BACKEND_PID_FILE" ]; then
        BACKEND_PID=$(cat "$BACKEND_PID_FILE")
        if ! ps -p "$BACKEND_PID" > /dev/null 2>&1; then
            echo -e "${RED}Backend parou inesperadamente!${NC}"
            break
        fi
    fi
    
    # Verifica se o frontend ainda está rodando
    if [ -f "$FRONTEND_PID_FILE" ]; then
        FRONTEND_PID=$(cat "$FRONTEND_PID_FILE")
        if ! ps -p "$FRONTEND_PID" > /dev/null 2>&1; then
            echo -e "${RED}Frontend parou inesperadamente!${NC}"
            break
        fi
    fi
    
    sleep 5
done

