import { Thread } from "@langchain/langgraph-sdk";
import { v4 as uuidv4 } from "uuid";

const FLASK_THREADS_STORAGE_KEY = "flask:threads";

export interface FlaskThread {
  thread_id: string;
  created_at: number;
  updated_at: number;
  values: {
    messages: any[];
  };
}

/**
 * Salva uma thread no localStorage
 */
export function saveFlaskThread(threadId: string, messages: any[]): void {
  try {
    const threads = getFlaskThreads();
    const existingThread = threads.find((t) => t.thread_id === threadId);
    
    const threadData: FlaskThread = {
      thread_id: threadId,
      created_at: existingThread?.created_at || Date.now(),
      updated_at: Date.now(),
      values: {
        messages,
      },
    };

    if (existingThread) {
      // Atualiza thread existente
      const index = threads.findIndex((t) => t.thread_id === threadId);
      threads[index] = threadData;
    } else {
      // Adiciona nova thread
      threads.push(threadData);
    }

    // Ordena por data de atualização (mais recente primeiro)
    threads.sort((a, b) => b.updated_at - a.updated_at);

    localStorage.setItem(FLASK_THREADS_STORAGE_KEY, JSON.stringify(threads));
  } catch (error) {
    console.error("Erro ao salvar thread no localStorage:", error);
  }
}

/**
 * Recupera todas as threads do localStorage
 */
export function getFlaskThreads(): FlaskThread[] {
  try {
    const stored = localStorage.getItem(FLASK_THREADS_STORAGE_KEY);
    if (!stored) return [];
    return JSON.parse(stored) as FlaskThread[];
  } catch (error) {
    console.error("Erro ao recuperar threads do localStorage:", error);
    return [];
  }
}

/**
 * Converte FlaskThread para o formato Thread do LangGraph SDK
 */
export function flaskThreadToLangGraphThread(flaskThread: FlaskThread): Thread {
  return {
    thread_id: flaskThread.thread_id,
    created_at: new Date(flaskThread.created_at).toISOString(),
    updated_at: new Date(flaskThread.updated_at).toISOString(),
    values: flaskThread.values,
    metadata: {},
  };
}

/**
 * Gera um novo thread ID
 */
export function generateFlaskThreadId(): string {
  return uuidv4();
}

/**
 * Deleta uma thread
 */
export function deleteFlaskThread(threadId: string): void {
  try {
    const threads = getFlaskThreads();
    const filtered = threads.filter((t) => t.thread_id !== threadId);
    localStorage.setItem(FLASK_THREADS_STORAGE_KEY, JSON.stringify(filtered));
  } catch (error) {
    console.error("Erro ao deletar thread:", error);
  }
}

