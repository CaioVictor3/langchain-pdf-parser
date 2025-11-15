/**
 * Script principal do frontend
 * Gerencia a comunicação com o backend via fetch/AJAX
 */

// URL da API backend
const API_URL = 'http://localhost:5001/api/pergunta';

// Referências aos elementos
let chatMessages;
let perguntaInput;
let btnEnviar;

/**
 * Inicialização quando o DOM estiver carregado
 */
document.addEventListener('DOMContentLoaded', function() {
    chatMessages = document.getElementById('chatMessages');
    perguntaInput = document.getElementById('perguntaInput');
    btnEnviar = document.getElementById('btnEnviar');
    
    // Auto-resize do textarea
    perguntaInput.addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = Math.min(this.scrollHeight, 120) + 'px';
    });
    
    // Enviar com Enter (Shift+Enter para nova linha)
    perguntaInput.addEventListener('keydown', function(event) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            enviarPergunta();
        }
    });
    
    // Foca no input ao carregar
    perguntaInput.focus();
});

/**
 * Função principal para enviar pergunta ao backend
 */
async function enviarPergunta() {
    const pergunta = perguntaInput.value.trim();
    
    // Validação
    if (!pergunta) {
        return;
    }
    
    // Adiciona mensagem do usuário ao chat
    adicionarMensagemUsuario(pergunta);
    
    // Limpa o input
    perguntaInput.value = '';
    perguntaInput.style.height = 'auto';
    
    // Mostra indicador de digitação
    const typingId = mostrarTypingIndicator();
    
    // Desabilita botão
    mostrarLoading(true);
    
    try {
        // Faz requisição ao backend
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                pergunta: pergunta
            })
        });
        
        // Remove indicador de digitação
        removerTypingIndicator(typingId);
        
        // Verifica se a resposta foi bem-sucedida
        if (!response.ok) {
            throw new Error(`Erro HTTP: ${response.status}`);
        }
        
        // Converte resposta para JSON
        const data = await response.json();
        
        // Verifica se há erro na resposta
        if (data.erro) {
            adicionarMensagemErro(data.erro);
        } else if (data.resposta) {
            adicionarMensagemIA(data.resposta);
        } else {
            adicionarMensagemErro('Resposta inválida do servidor.');
        }
        
    } catch (error) {
        console.error('Erro ao enviar pergunta:', error);
        removerTypingIndicator(typingId);
        adicionarMensagemErro(`Erro ao conectar com o servidor: ${error.message}. Verifique se o backend está rodando.`);
    } finally {
        // Remove loading
        mostrarLoading(false);
        perguntaInput.focus();
    }
}

/**
 * Adiciona mensagem do usuário ao chat
 */
function adicionarMensagemUsuario(texto) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message message-user';
    
    messageDiv.innerHTML = `
        <div class="message-content">
            <div class="message-bubble">
                <p>${escapeHtml(texto)}</p>
            </div>
        </div>
        <div class="message-avatar">
            <i class="bi bi-person-fill"></i>
        </div>
    `;
    
    chatMessages.appendChild(messageDiv);
    scrollToBottom();
}

/**
 * Adiciona mensagem da IA ao chat
 */
function adicionarMensagemIA(texto) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message message-ai';
    
    messageDiv.innerHTML = `
        <div class="message-avatar">
            <i class="bi bi-robot"></i>
        </div>
        <div class="message-content">
            <div class="message-bubble">
                <p>${escapeHtml(texto)}</p>
            </div>
        </div>
    `;
    
    chatMessages.appendChild(messageDiv);
    scrollToBottom();
}

/**
 * Adiciona mensagem de erro
 */
function adicionarMensagemErro(mensagem) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'message-error';
    errorDiv.innerHTML = `<p><i class="bi bi-exclamation-triangle"></i> ${escapeHtml(mensagem)}</p>`;
    
    chatMessages.appendChild(errorDiv);
    scrollToBottom();
}

/**
 * Mostra indicador de digitação
 */
function mostrarTypingIndicator() {
    const typingId = 'typing-' + Date.now();
    const messageDiv = document.createElement('div');
    messageDiv.id = typingId;
    messageDiv.className = 'message message-ai';
    
    messageDiv.innerHTML = `
        <div class="message-avatar">
            <i class="bi bi-robot"></i>
        </div>
        <div class="message-content">
            <div class="message-bubble">
                <div class="typing-indicator">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
        </div>
    `;
    
    chatMessages.appendChild(messageDiv);
    scrollToBottom();
    
    return typingId;
}

/**
 * Remove indicador de digitação
 */
function removerTypingIndicator(typingId) {
    const typingElement = document.getElementById(typingId);
    if (typingElement) {
        typingElement.remove();
    }
}

/**
 * Controla o estado de loading do botão
 */
function mostrarLoading(mostrar) {
    const btnText = document.getElementById('btnText');
    const btnSpinner = document.getElementById('btnSpinner');
    
    if (mostrar) {
        btnEnviar.disabled = true;
        btnText.classList.add('d-none');
        btnSpinner.classList.remove('d-none');
    } else {
        btnEnviar.disabled = false;
        btnText.classList.remove('d-none');
        btnSpinner.classList.add('d-none');
    }
}

/**
 * Scroll suave até o final do chat
 */
function scrollToBottom() {
    setTimeout(() => {
        chatMessages.scrollTo({
            top: chatMessages.scrollHeight,
            behavior: 'smooth'
        });
    }, 100);
}

/**
 * Escapa HTML para prevenir XSS
 */
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
