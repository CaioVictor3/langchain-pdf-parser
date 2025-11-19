#!/bin/bash

# Script para parar o backend Flask e o frontend
# Uso: ./stop.sh

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Diretórios
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_PID_FILE="$ROOT_DIR/.backend.pid"
FRONTEND_PID_FILE="$ROOT_DIR/.frontend.pid"

echo -e "${BLUE}=== Parando serviços ===${NC}"

# Para o backend
if [ -f "$BACKEND_PID_FILE" ]; then
    BACKEND_PID=$(cat "$BACKEND_PID_FILE")
    if ps -p "$BACKEND_PID" > /dev/null 2>&1; then
        echo -e "${YELLOW}Parando backend Flask (PID: $BACKEND_PID)...${NC}"
        kill "$BACKEND_PID" 2>/dev/null || true
        sleep 1
        # Se ainda estiver rodando, força
        if ps -p "$BACKEND_PID" > /dev/null 2>&1; then
            kill -9 "$BACKEND_PID" 2>/dev/null || true
        fi
        echo -e "${GREEN}✓ Backend parado${NC}"
    else
        echo -e "${YELLOW}Backend já estava parado${NC}"
    fi
    rm -f "$BACKEND_PID_FILE"
else
    echo -e "${YELLOW}Arquivo PID do backend não encontrado${NC}"
fi

# Para o frontend
if [ -f "$FRONTEND_PID_FILE" ]; then
    FRONTEND_PID=$(cat "$FRONTEND_PID_FILE")
    if ps -p "$FRONTEND_PID" > /dev/null 2>&1; then
        echo -e "${YELLOW}Parando frontend (PID: $FRONTEND_PID)...${NC}"
        kill "$FRONTEND_PID" 2>/dev/null || true
        sleep 1
        # Se ainda estiver rodando, força
        if ps -p "$FRONTEND_PID" > /dev/null 2>&1; then
            kill -9 "$FRONTEND_PID" 2>/dev/null || true
        fi
        echo -e "${GREEN}✓ Frontend parado${NC}"
    else
        echo -e "${YELLOW}Frontend já estava parado${NC}"
    fi
    rm -f "$FRONTEND_PID_FILE"
else
    echo -e "${YELLOW}Arquivo PID do frontend não encontrado${NC}"
fi

# Mata processos órfãos
echo -e "${YELLOW}Limpando processos órfãos...${NC}"
pkill -f "python.*app.py" 2>/dev/null && echo -e "${GREEN}✓ Processos Python Flask limpos${NC}" || true
pkill -f "vite" 2>/dev/null && echo -e "${GREEN}✓ Processos Vite limpos${NC}" || true

# Limpa portas se ainda estiverem em uso
if command_exists lsof; then
    if lsof -Pi :5001 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}Limpando porta 5001...${NC}"
        lsof -ti:5001 | xargs kill -9 2>/dev/null || true
        echo -e "${GREEN}✓ Porta 5001 liberada${NC}"
    fi

    if lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}Limpando porta 5173...${NC}"
        lsof -ti:5173 | xargs kill -9 2>/dev/null || true
        echo -e "${GREEN}✓ Porta 5173 liberada${NC}"
    fi
fi

echo -e "\n${GREEN}=== Tudo parado! ===${NC}"

