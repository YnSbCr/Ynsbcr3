# Hata Y?netimi Sistemi

Bu proje i?in kapsaml? bir hata y?netim sistemi olu?turulmu?tur. Sistem hem backend (Express.js) hem de frontend (React) i?in hata yakalama ve y?netim ara?lar? sa?lar.

## ?zellikler

### ? Backend (Express.js)
- **Global Error Handler Middleware**: T?m route'lardan gelen hatalar? yakalar
- **Async Handler Wrapper**: Async route handler'lardaki hatalar? otomatik yakalar
- **Standart Error Response Format?**: Tutarl? API error response'lar?
- **Hata Loglama**: Detayl? hata loglar?

### ? Frontend (React)
- **Error Boundary Component**: React component tree'deki hatalar? yakalar
- **Kullan?c? Dostu Hata Mesajlar?**: T?rk?e hata mesajlar?
- **API Error Handling**: Fetch/TanStack Query ile entegrasyon

### ? Payla??lan Utilities
- **Error Code Enum**: Standart hata kodlar?
- **AppError Class**: Custom error s?n?f?
- **Logger**: Merkezi loglama sistemi

## Kullan?m

### Express Server'da

```typescript
import express from 'express';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';

const app = express();

// ... routes ...

// 404 handler (t?m route'lardan sonra)
app.use(notFoundHandler);

// Error handler (en sonda)
app.use(errorHandler);
```

### Route Handler'da

```typescript
import { asyncHandler } from './middleware/errorHandler';
import { AppError, ErrorCode } from '@shared/errors';

app.get('/api/users/:id', asyncHandler(async (req, res) => {
  const user = await getUserById(req.params.id);
  
  if (!user) {
    throw new AppError(
      ErrorCode.NOT_FOUND,
      'Kullan?c? bulunamad?',
      404
    );
  }
  
  res.json({ success: true, data: user });
}));
```

### React'te

```typescript
import { ErrorBoundary } from './components/ErrorBoundary';

function App() {
  return (
    <ErrorBoundary>
      <YourApp />
    </ErrorBoundary>
  );
}
```

### API ?steklerinde

```typescript
import { handleApiResponse, getUserFriendlyError } from './utils/errorHandler';

try {
  const response = await fetch('/api/users/1');
  const data = await handleApiResponse(response);
} catch (error) {
  const message = getUserFriendlyError(error);
  toast.error(message);
}
```

## Error Codes

- `INTERNAL_ERROR`: Genel sunucu hatas?
- `VALIDATION_ERROR`: Validasyon hatas?
- `NOT_FOUND`: Kay?t bulunamad?
- `UNAUTHORIZED`: Yetkilendirme gerekli
- `FORBIDDEN`: Yetki yok
- `BAD_REQUEST`: Ge?ersiz istek
- `DATABASE_ERROR`: Veritaban? hatas?
- `CONNECTION_ERROR`: Ba?lant? hatas?
- `INVALID_CREDENTIALS`: Ge?ersiz kimlik bilgileri
- `SESSION_EXPIRED`: Oturum s?resi dolmu?
- `EXTERNAL_API_ERROR`: Harici API hatas?
- `RATE_LIMIT_EXCEEDED`: Rate limit a??ld?

## API Response Format?

### Ba?ar?l? Response
```json
{
  "success": true,
  "data": { ... }
}
```

### Hata Response
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Kullan?c? bulunamad?",
    "details": null,
    "timestamp": "2024-01-01T12:00:00.000Z",
    "path": "/api/users/123"
  }
}
```

## Geli?tirme Notlar?

- Production'da internal error mesajlar? gizlenir
- Development'da detayl? hata bilgileri g?sterilir
- T?m hatalar loglan?r
- Error tracking service entegrasyonu i?in haz?r (Sentry, vb.)
