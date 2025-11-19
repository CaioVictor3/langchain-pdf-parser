import React, {
  createContext,
  useContext,
  ReactNode,
  useState,
  useCallback,
  useRef,
  useEffect,
} from "react";
import { type Message } from "@langchain/langgraph-sdk";
import { v4 as uuidv4 } from "uuid";
import { useQueryState } from "nuqs";
import {
  saveFlaskThread,
  generateFlaskThreadId,
  getFlaskThreads,
} from "@/lib/flask-threads";

export type StateType = { messages: Message[]; ui?: any[] };

interface FlaskStreamContextType {
  messages: Message[];
  isLoading: boolean;
  error: Error | null;
  values: StateType;
  interrupt: any;
  submit: (
    update?: { messages: Message[] },
    options?: {
      streamMode?: string[];
      optimisticValues?: (prev: StateType) => StateType;
      checkpoint?: any;
    }
  ) => Promise<void>;
  stop: () => void;
  getMessagesMetadata: (message: Message) => any;
  setBranch: (branch: string) => void;
}

export const FlaskStreamContext = createContext<FlaskStreamContextType | undefined>(
  undefined
);

interface FlaskStreamProviderProps {
  children: ReactNode;
  apiUrl: string;
}

export function FlaskStreamProvider({
  children,
  apiUrl,
}: FlaskStreamProviderProps) {
  const [threadId, setThreadId] = useQueryState("threadId");
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const abortControllerRef = useRef<AbortController | null>(null);

  // Gera um threadId se não existir
  useEffect(() => {
    if (!threadId) {
      const newThreadId = generateFlaskThreadId();
      setThreadId(newThreadId);
    }
  }, [threadId, setThreadId]);

  // Carrega mensagens quando um threadId é selecionado
  useEffect(() => {
    if (threadId) {
      const threads = getFlaskThreads();
      const thread = threads.find((t) => t.thread_id === threadId);
      if (thread && thread.values.messages) {
        setMessages(thread.values.messages);
      } else if (!thread) {
        // Thread não existe, limpa mensagens
        setMessages([]);
      }
    }
  }, [threadId]);

  // Salva as mensagens no localStorage sempre que mudarem
  useEffect(() => {
    if (threadId && messages.length > 0) {
      saveFlaskThread(threadId, messages);
    }
  }, [threadId, messages]);

  const submit = useCallback(
    async (
      update?: { messages: Message[] },
      options?: {
        streamMode?: string[];
        optimisticValues?: (prev: StateType) => StateType;
        checkpoint?: any;
      }
    ) => {
      if (!update || !update.messages || update.messages.length === 0) {
        return;
      }

      // Encontra a última mensagem humana
      const humanMessages = update.messages.filter((m) => m.type === "human");
      const lastHumanMessage = humanMessages[humanMessages.length - 1];

      if (!lastHumanMessage || typeof lastHumanMessage.content !== "string") {
        return;
      }

      const pergunta = lastHumanMessage.content;

      setIsLoading(true);
      setError(null);

      // Atualiza mensagens otimisticamente antes da requisição
      setMessages((prev) => {
        if (options?.optimisticValues) {
          const optimisticState = options.optimisticValues({
            messages: prev,
            ui: [],
          });
          return optimisticState.messages || prev;
        } else {
          // Adiciona as novas mensagens do update
          const existingIds = new Set(prev.map((m) => m.id));
          const newMessages = update.messages.filter(
            (m) => m.id && !existingIds.has(m.id)
          );
          return [...prev, ...newMessages];
        }
      });

      // Cria um novo AbortController para esta requisição
      abortControllerRef.current = new AbortController();

      try {
        const response = await fetch(`${apiUrl}/api/pergunta`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ pergunta }),
          signal: abortControllerRef.current.signal,
        }).catch((fetchError) => {
          // Erro de conexão (backend não está rodando, CORS, etc)
          if (fetchError.name === "TypeError" && fetchError.message.includes("fetch")) {
            throw new Error(
              `Não foi possível conectar ao backend em ${apiUrl}. Verifique se o servidor está rodando.`
            );
          }
          throw fetchError;
        });

        if (!response.ok) {
          let errorMessage = `Erro HTTP: ${response.status} ${response.statusText}`;
          try {
            const errorData = await response.json();
            errorMessage = errorData.erro || errorMessage;
          } catch {
            // Se não conseguir parsear JSON, usa a mensagem padrão
          }
          throw new Error(errorMessage);
        }

        const data = await response.json().catch((parseError) => {
          throw new Error("Resposta do servidor não é um JSON válido");
        });

        if (data.erro) {
          throw new Error(data.erro);
        }
        
        if (!data.resposta) {
          throw new Error("Resposta vazia do servidor");
        }

        // Cria mensagem de resposta da IA
        const aiMessage: Message = {
          id: uuidv4(),
          type: "ai",
          content: data.resposta || "Sem resposta",
        };

        // Atualiza mensagens com a resposta
        setMessages((prev) => {
          // Adiciona a resposta da IA
          return [...prev, aiMessage];
        });
      } catch (err: any) {
        if (err.name === "AbortError") {
          // Requisição foi cancelada, não é um erro real
          setIsLoading(false);
          abortControllerRef.current = null;
          return;
        }
        
        // Trata o erro
        const errorMessage = err instanceof Error ? err : new Error(String(err));
        setError(errorMessage);
        console.error("Erro ao processar pergunta:", err);
        
        // Mostra mensagem de erro na UI como uma mensagem da IA
        let errorText = "Erro desconhecido ao processar pergunta";
        if (err?.message) {
          errorText = err.message;
        } else if (typeof err === "string") {
          errorText = err;
        } else if (err?.toString) {
          errorText = err.toString();
        }
        
        const aiErrorMessage: Message = {
          id: uuidv4(),
          type: "ai",
          content: `❌ **Erro ao processar sua pergunta**\n\n${errorText}\n\nPor favor, verifique se o backend está rodando em ${apiUrl} e tente novamente.`,
        };
        
        // Adiciona mensagem de erro às mensagens
        setMessages((prev) => {
          return [...prev, aiErrorMessage];
        });
      } finally {
        setIsLoading(false);
        abortControllerRef.current = null;
      }
    },
    [apiUrl]
  );

  const stop = useCallback(() => {
    if (abortControllerRef.current) {
      abortControllerRef.current.abort();
      abortControllerRef.current = null;
      setIsLoading(false);
    }
  }, []);

  // Função para obter metadados de mensagens (compatibilidade com LangGraph SDK)
  const getMessagesMetadata = useCallback((message: Message) => {
    // Retorna um objeto vazio ou com estrutura básica
    // O Flask backend não tem branches ou checkpoints como o LangGraph
    return {
      branch: undefined,
      branchOptions: undefined,
      firstSeenState: {
        parent_checkpoint: null,
        values: { messages, ui: [] },
      },
    };
  }, [messages]);

  // Função para definir branch (compatibilidade com LangGraph SDK)
  const setBranch = useCallback((branch: string) => {
    // Flask backend não suporta branches, apenas loga
    console.log("setBranch chamado (não suportado pelo Flask backend):", branch);
  }, []);

  const value: FlaskStreamContextType = {
    messages,
    isLoading,
    error,
    values: { messages, ui: [] },
    interrupt: null,
    submit,
    stop,
    getMessagesMetadata,
    setBranch,
  };

  return (
    <FlaskStreamContext.Provider value={value}>
      {children}
    </FlaskStreamContext.Provider>
  );
}

export function useFlaskStreamContext(): FlaskStreamContextType {
  const context = useContext(FlaskStreamContext);
  if (context === undefined) {
    throw new Error(
      "useFlaskStreamContext must be used within a FlaskStreamProvider"
    );
  }
  return context;
}

