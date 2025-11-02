/**
 * Hata loglama sistemi
 */

export enum LogLevel {
  ERROR = 'ERROR',
  WARN = 'WARN',
  INFO = 'INFO',
  DEBUG = 'DEBUG',
}

export interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: string;
  error?: {
    name: string;
    message: string;
    stack?: string;
    code?: string;
  };
  context?: Record<string, unknown>;
}

/**
 * Console'a log yazd?r?r
 */
export function log(entry: LogEntry): void {
  const timestamp = new Date().toISOString();
  const logMessage = {
    ...entry,
    timestamp,
  };
  
  const logString = JSON.stringify(logMessage, null, 2);
  
  switch (entry.level) {
    case LogLevel.ERROR:
      console.error(logString);
      break;
    case LogLevel.WARN:
      console.warn(logString);
      break;
    case LogLevel.INFO:
      console.info(logString);
      break;
    case LogLevel.DEBUG:
      console.debug(logString);
      break;
  }
}

/**
 * Error log helper fonksiyonlar?
 */
export const logger = {
  error: (message: string, error?: Error, context?: Record<string, unknown>) => {
    log({
      level: LogLevel.ERROR,
      message,
      error: error
        ? {
            name: error.name,
            message: error.message,
            stack: error.stack,
            code: (error as { code?: string }).code,
          }
        : undefined,
      context,
    });
  },
  
  warn: (message: string, context?: Record<string, unknown>) => {
    log({
      level: LogLevel.WARN,
      message,
      context,
    });
  },
  
  info: (message: string, context?: Record<string, unknown>) => {
    log({
      level: LogLevel.INFO,
      message,
      context,
    });
  },
  
  debug: (message: string, context?: Record<string, unknown>) => {
    if (process.env.NODE_ENV === 'development') {
      log({
        level: LogLevel.DEBUG,
        message,
        context,
      });
    }
  },
};
