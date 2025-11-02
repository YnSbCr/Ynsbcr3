import { ErrorCode } from '@shared/errors';

/**
 * Frontend i?in error handling utility fonksiyonlar?
 */

export interface ApiError {
  code: ErrorCode;
  message: string;
  details?: unknown;
  timestamp?: string;
  path?: string;
}

/**
 * API response'dan error ??kar?r
 */
export function extractError(response: unknown): ApiError {
  if (
    response &&
    typeof response === 'object' &&
    'error' in response &&
    response.error &&
    typeof response.error === 'object'
  ) {
    const error = response.error as Record<string, unknown>;
    return {
      code: (error.code as ErrorCode) || ErrorCode.INTERNAL_ERROR,
      message: (error.message as string) || 'Bir hata olu?tu',
      details: error.details,
      timestamp: error.timestamp as string,
      path: error.path as string,
    };
  }

  return {
    code: ErrorCode.INTERNAL_ERROR,
    message: 'Beklenmeyen bir hata olu?tu',
  };
}

/**
 * Error code'a g?re kullan?c? dostu mesaj d?nd?r?r
 */
export function getUserFriendlyError(error: ApiError | Error | unknown): string {
  if (error && typeof error === 'object' && 'code' in error) {
    const apiError = error as ApiError;
    
    // Error code'a g?re ?zel mesajlar
    const errorMessages: Partial<Record<ErrorCode, string>> = {
      [ErrorCode.NOT_FOUND]: 'Arad???n?z kay?t bulunamad?',
      [ErrorCode.UNAUTHORIZED]: 'Oturum a?man?z gerekiyor',
      [ErrorCode.FORBIDDEN]: 'Bu i?lem i?in yetkiniz yok',
      [ErrorCode.VALIDATION_ERROR]: 'Girdi?iniz bilgiler ge?ersiz',
      [ErrorCode.BAD_REQUEST]: 'Ge?ersiz istek',
      [ErrorCode.DATABASE_ERROR]: 'Veritaban? hatas? olu?tu',
      [ErrorCode.CONNECTION_ERROR]: 'Ba?lant? hatas? olu?tu',
      [ErrorCode.EXTERNAL_API_ERROR]: 'Harici servis hatas?',
      [ErrorCode.RATE_LIMIT_EXCEEDED]: '?ok fazla istek g?nderdiniz. L?tfen bekleyin.',
    };

    return errorMessages[apiError.code] || apiError.message || 'Bir hata olu?tu';
  }

  if (error instanceof Error) {
    return error.message;
  }

  return 'Beklenmeyen bir hata olu?tu';
}

/**
 * Error'? loglar (production'da error tracking service'e g?nderilebilir)
 */
export function logError(error: unknown, context?: Record<string, unknown>): void {
  const errorMessage = error instanceof Error ? error.message : String(error);
  const errorStack = error instanceof Error ? error.stack : undefined;

  console.error('Client Error:', {
    message: errorMessage,
    stack: errorStack,
    context,
    timestamp: new Date().toISOString(),
  });

  // Production'da error tracking service'e g?nder
  // ?rnek: Sentry, LogRocket, vb.
  if (process.env.NODE_ENV === 'production') {
    // Sentry.captureException(error, { extra: context });
  }
}

/**
 * Fetch response'u kontrol eder ve hata varsa throw eder
 */
export async function handleApiResponse<T>(
  response: Response
): Promise<T> {
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    const apiError = extractError(errorData);
    throw new Error(apiError.message);
  }

  const data = await response.json().catch(() => ({}));
  
  // API response format?n? kontrol et
  if (data && typeof data === 'object' && 'success' in data) {
    if (data.success === false) {
      const apiError = extractError(data);
      throw new Error(apiError.message);
    }
    return data.data as T;
  }

  return data as T;
}
