/**
 * Standart hata y?netimi ve error response formatlar?
 */

export enum ErrorCode {
  // Genel hatalar
  INTERNAL_ERROR = 'INTERNAL_ERROR',
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  NOT_FOUND = 'NOT_FOUND',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  BAD_REQUEST = 'BAD_REQUEST',
  
  // Database hatalar?
  DATABASE_ERROR = 'DATABASE_ERROR',
  CONNECTION_ERROR = 'CONNECTION_ERROR',
  
  // Authentication hatalar?
  INVALID_CREDENTIALS = 'INVALID_CREDENTIALS',
  SESSION_EXPIRED = 'SESSION_EXPIRED',
  
  // API hatalar?
  EXTERNAL_API_ERROR = 'EXTERNAL_API_ERROR',
  RATE_LIMIT_EXCEEDED = 'RATE_LIMIT_EXCEEDED',
}

export interface ApiErrorResponse {
  success: false;
  error: {
    code: ErrorCode;
    message: string;
    details?: unknown;
    timestamp: string;
    path?: string;
  };
}

export interface ApiSuccessResponse<T = unknown> {
  success: true;
  data: T;
}

export type ApiResponse<T = unknown> = ApiSuccessResponse<T> | ApiErrorResponse;

/**
 * Custom Application Error s?n?f?
 */
export class AppError extends Error {
  constructor(
    public code: ErrorCode,
    message: string,
    public statusCode: number = 500,
    public details?: unknown
  ) {
    super(message);
    this.name = 'AppError';
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Hata koduna g?re HTTP status code d?nd?r?r
 */
export function getStatusCodeFromErrorCode(code: ErrorCode): number {
  const statusMap: Record<ErrorCode, number> = {
    [ErrorCode.INTERNAL_ERROR]: 500,
    [ErrorCode.VALIDATION_ERROR]: 400,
    [ErrorCode.NOT_FOUND]: 404,
    [ErrorCode.UNAUTHORIZED]: 401,
    [ErrorCode.FORBIDDEN]: 403,
    [ErrorCode.BAD_REQUEST]: 400,
    [ErrorCode.DATABASE_ERROR]: 500,
    [ErrorCode.CONNECTION_ERROR]: 503,
    [ErrorCode.INVALID_CREDENTIALS]: 401,
    [ErrorCode.SESSION_EXPIRED]: 401,
    [ErrorCode.EXTERNAL_API_ERROR]: 502,
    [ErrorCode.RATE_LIMIT_EXCEEDED]: 429,
  };
  
  return statusMap[code] || 500;
}

/**
 * Hata mesaj?n? kullan?c? dostu hale getirir
 */
export function getUserFriendlyMessage(error: unknown): string {
  if (error instanceof AppError) {
    return error.message;
  }
  
  if (error instanceof Error) {
    // Production'da internal error mesajlar?n? gizle
    if (process.env.NODE_ENV === 'production') {
      return 'Bir hata olu?tu. L?tfen daha sonra tekrar deneyin.';
    }
    return error.message;
  }
  
  return 'Beklenmeyen bir hata olu?tu.';
}

/**
 * Error'? ApiErrorResponse format?na d?n??t?r?r
 */
export function formatErrorResponse(
  error: unknown,
  path?: string
): ApiErrorResponse {
  if (error instanceof AppError) {
    return {
      success: false,
      error: {
        code: error.code,
        message: error.message,
        details: error.details,
        timestamp: new Date().toISOString(),
        path,
      },
    };
  }
  
  if (error instanceof Error) {
    return {
      success: false,
      error: {
        code: ErrorCode.INTERNAL_ERROR,
        message: getUserFriendlyMessage(error),
        details: process.env.NODE_ENV === 'development' ? error.stack : undefined,
        timestamp: new Date().toISOString(),
        path,
      },
    };
  }
  
  return {
    success: false,
    error: {
      code: ErrorCode.INTERNAL_ERROR,
      message: getUserFriendlyMessage(error),
      timestamp: new Date().toISOString(),
      path,
    },
  };
}
