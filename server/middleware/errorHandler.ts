import { Request, Response, NextFunction } from 'express';
import { AppError, formatErrorResponse, ErrorCode, getStatusCodeFromErrorCode } from '@shared/errors';
import { logger } from '@shared/logger';

/**
 * Express i?in global error handler middleware
 * T?m hatalar? yakalar ve standart formatta response d?ner
 */
export function errorHandler(
  error: unknown,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  // Response zaten g?nderilmi?se, Express default error handler'a ge?
  if (res.headersSent) {
    return next(error);
  }

  // Hata loglama
  if (error instanceof AppError) {
    logger.error(
      `Application Error: ${error.message}`,
      error,
      {
        code: error.code,
        statusCode: error.statusCode,
        path: req.path,
        method: req.method,
        details: error.details,
      }
    );
  } else if (error instanceof Error) {
    logger.error(
      `Unexpected Error: ${error.message}`,
      error,
      {
        path: req.path,
        method: req.method,
      }
    );
  } else {
    logger.error(
      'Unknown error occurred',
      undefined,
      {
        error: String(error),
        path: req.path,
        method: req.method,
      }
    );
  }

  // Error response olu?tur
  const errorResponse = formatErrorResponse(error, req.path);
  
  // Status code belirle
  let statusCode = 500;
  if (error instanceof AppError) {
    statusCode = error.statusCode;
  } else if (error instanceof Error) {
    // Error'dan status code ??karabilir miyiz?
    const code = (error as { statusCode?: number }).statusCode;
    if (code && code >= 400 && code < 600) {
      statusCode = code;
    }
  }

  // Response g?nder
  res.status(statusCode).json(errorResponse);
}

/**
 * 404 Not Found handler middleware
 */
export function notFoundHandler(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const error = new AppError(
    ErrorCode.NOT_FOUND,
    `Route not found: ${req.method} ${req.path}`,
    404
  );
  next(error);
}

/**
 * Async route handler wrapper
 * Async fonksiyonlardan gelen hatalar? yakalar
 */
export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>
) {
  return (req: Request, res: Response, next: NextFunction): void => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}
