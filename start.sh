#!/bin/bash
# Script para iniciar backend e frontend juntos

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Arquivo para armazenar PIDs
PID_FILE=".pids"

# Função para limpar PIDs antigos
cleanup_old_processes() {
    if [ -f "$PID_FILE" ]; then
        echo -e "${YELLOW}Limpando processos antigos...${NC}"
        while read pid; do
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid" 2>/dev/null
            fi
        done < "$PID_FILE"
        rm -f "$PID_FILE"
    fi
}

# Limpa processos antigos
cleanup_old_processes

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Iniciando RAG AI Project${NC}"
echo -e "${BLUE}========================================${NC}"

# Inicia o backend
echo -e "${GREEN}Iniciando Backend (Flask) na porta 5001...${NC}"
cd backend
python app.py > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo $BACKEND_PID > "$PID_FILE"

# Aguarda um pouco para o backend iniciar
sleep 2

# Inicia o frontend
echo -e "${GREEN}Iniciando Frontend (HTTP Server) na porta 8000...${NC}"
cd frontend
python -m http.server 8000 > ../frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..
echo $FRONTEND_PID >> "$PID_FILE"

# Aguarda um pouco para verificar se iniciaram
sleep 2

# Verifica se os processos estão rodando
if kill -0 "$BACKEND_PID" 2>/dev/null && kill -0 "$FRONTEND_PID" 2>/dev/null; then
    echo -e "${GREEN}✓ Backend iniciado com sucesso (PID: $BACKEND_PID)${NC}"
    echo -e "${GREEN}✓ Frontend iniciado com sucesso (PID: $FRONTEND_PID)${NC}"
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Serviços rodando:${NC}"
    echo -e "  • Backend:  http://localhost:5001"
    echo -e "  • Frontend: http://localhost:8000"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Para parar os serviços, execute: ./stop.sh${NC}"
    echo -e "${YELLOW}Ou pressione Ctrl+C e execute ./stop.sh${NC}"
    echo ""
    
    # Aguarda Ctrl+C
    trap "echo -e '\n${YELLOW}Parando serviços...${NC}'; ./stop.sh; exit" INT
    
    # Mantém o script rodando
    wait
else
    echo -e "${YELLOW}Erro ao iniciar os serviços. Verifique os logs:${NC}"
    echo -e "  • Backend:  backend.log"
    echo -e "  • Frontend: frontend.log"
    cleanup_old_processes
    exit 1
fi

