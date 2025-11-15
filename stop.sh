#!/bin/bash
# Script para parar backend e frontend

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Arquivo com PIDs
PID_FILE=".pids"

echo -e "${YELLOW}Parando serviços RAG AI...${NC}"

if [ ! -f "$PID_FILE" ]; then
    echo -e "${YELLOW}Nenhum processo encontrado. Os serviços podem não estar rodando.${NC}"
    
    # Tenta encontrar processos manualmente
    BACKEND_PID=$(lsof -ti:5001 2>/dev/null)
    FRONTEND_PID=$(lsof -ti:8000 2>/dev/null)
    
    if [ -z "$BACKEND_PID" ] && [ -z "$FRONTEND_PID" ]; then
        echo -e "${GREEN}Nenhum serviço encontrado nas portas 5001 ou 8000.${NC}"
        exit 0
    fi
else
    # Lê PIDs do arquivo
    BACKEND_PID=$(sed -n '1p' "$PID_FILE")
    FRONTEND_PID=$(sed -n '2p' "$PID_FILE")
fi

# Para o backend
if [ ! -z "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
    echo -e "${GREEN}Parando Backend (PID: $BACKEND_PID)...${NC}"
    kill "$BACKEND_PID" 2>/dev/null
    sleep 1
    # Força parada se ainda estiver rodando
    if kill -0 "$BACKEND_PID" 2>/dev/null; then
        kill -9 "$BACKEND_PID" 2>/dev/null
    fi
else
    # Tenta encontrar por porta
    BACKEND_PID=$(lsof -ti:5001 2>/dev/null)
    if [ ! -z "$BACKEND_PID" ]; then
        echo -e "${GREEN}Parando Backend na porta 5001 (PID: $BACKEND_PID)...${NC}"
        kill "$BACKEND_PID" 2>/dev/null
        sleep 1
        if kill -0 "$BACKEND_PID" 2>/dev/null; then
            kill -9 "$BACKEND_PID" 2>/dev/null
        fi
    fi
fi

# Para o frontend
if [ ! -z "$FRONTEND_PID" ] && kill -0 "$FRONTEND_PID" 2>/dev/null; then
    echo -e "${GREEN}Parando Frontend (PID: $FRONTEND_PID)...${NC}"
    kill "$FRONTEND_PID" 2>/dev/null
    sleep 1
    # Força parada se ainda estiver rodando
    if kill -0 "$FRONTEND_PID" 2>/dev/null; then
        kill -9 "$FRONTEND_PID" 2>/dev/null
    fi
else
    # Tenta encontrar por porta
    FRONTEND_PID=$(lsof -ti:8000 2>/dev/null)
    if [ ! -z "$FRONTEND_PID" ]; then
        echo -e "${GREEN}Parando Frontend na porta 8000 (PID: $FRONTEND_PID)...${NC}"
        kill "$FRONTEND_PID" 2>/dev/null
        sleep 1
        if kill -0 "$FRONTEND_PID" 2>/dev/null; then
            kill -9 "$FRONTEND_PID" 2>/dev/null
        fi
    fi
fi

# Remove arquivo de PIDs
rm -f "$PID_FILE"

# Limpa logs antigos (opcional)
# rm -f backend.log frontend.log

echo -e "${GREEN}✓ Serviços parados com sucesso!${NC}"

