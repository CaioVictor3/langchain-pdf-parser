/**
 * Script principal do frontend
 * Gerencia a comunicação com o backend via fetch/AJAX
 */

// URL da API backend (ajuste se necessário)
const API_URL = 'http://localhost:5001/api/pergunta';

/**
 * Função principal para enviar pergunta ao backend
 */
async function enviarPergunta() {
    // Obtém o valor da pergunta
    const perguntaInput = document.getElementById('perguntaInput');
    const pergunta = perguntaInput.value.trim();
    
    // Validação
    if (!pergunta) {
        alert('Por favor, digite uma pergunta antes de enviar.');
        perguntaInput.focus();
        return;
    }
    
    // Esconde áreas anteriores
    esconderAreas();
    
    // Mostra loading
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
        
        // Verifica se a resposta foi bem-sucedida
        if (!response.ok) {
            throw new Error(`Erro HTTP: ${response.status}`);
        }
        
        // Converte resposta para JSON
        const data = await response.json();
        
        // Verifica se há erro na resposta
        if (data.erro) {
            mostrarErro(data.erro);
        } else if (data.resposta) {
            mostrarResposta(data.resposta);
        } else {
            mostrarErro('Resposta inválida do servidor.');
        }
        
    } catch (error) {
        console.error('Erro ao enviar pergunta:', error);
        mostrarErro(`Erro ao conectar com o servidor: ${error.message}. Verifique se o backend está rodando.`);
    } finally {
        // Remove loading
        mostrarLoading(false);
    }
}

/**
 * Mostra a resposta na tela
 */
function mostrarResposta(resposta) {
    const areaResposta = document.getElementById('areaResposta');
    const respostaTexto = document.getElementById('respostaTexto');
    
    respostaTexto.textContent = resposta;
    areaResposta.classList.remove('d-none');
    areaResposta.classList.add('fade-in');
    
    // Scroll suave até a resposta
    areaResposta.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

/**
 * Mostra mensagem de erro
 */
function mostrarErro(mensagem) {
    const areaErro = document.getElementById('areaErro');
    const erroTexto = document.getElementById('erroTexto');
    
    erroTexto.textContent = mensagem;
    areaErro.classList.remove('d-none');
    areaErro.classList.add('fade-in');
    
    // Scroll suave até o erro
    areaErro.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

/**
 * Esconde as áreas de resposta e erro
 */
function esconderAreas() {
    document.getElementById('areaResposta').classList.add('d-none');
    document.getElementById('areaErro').classList.add('d-none');
}

/**
 * Controla o estado de loading do botão
 */
function mostrarLoading(mostrar) {
    const btnEnviar = document.getElementById('btnEnviar');
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
 * Permite enviar pergunta pressionando Enter (Ctrl+Enter para quebra de linha)
 */
document.addEventListener('DOMContentLoaded', function() {
    const perguntaInput = document.getElementById('perguntaInput');
    
    perguntaInput.addEventListener('keydown', function(event) {
        // Enter sem Ctrl/Shift envia a pergunta
        if (event.key === 'Enter' && !event.ctrlKey && !event.shiftKey) {
            event.preventDefault();
            enviarPergunta();
        }
    });
    
    // Foca no input ao carregar a página
    perguntaInput.focus();
});

