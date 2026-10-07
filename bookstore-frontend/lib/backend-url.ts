export const API_BASE_URL = (process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080').replace(/\/+$/, '');

export function getWebSocketUrl(): string {
  if (process.env.NEXT_PUBLIC_WS_URL) return process.env.NEXT_PUBLIC_WS_URL;

  const url = new URL(`${API_BASE_URL}/ws/websocket`);
  url.protocol = url.protocol === 'https:' ? 'wss:' : 'ws:';
  return url.toString();
}

// Old database exports contain absolute localhost upload URLs.
export function getBackendImageUrl(image: string | null | undefined): string {
  if (!image) return '/placeholder.svg';
  if (/^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?\/uploads\//i.test(image)) {
    return `${API_BASE_URL}${new URL(image).pathname}`;
  }
  if (/^(https?:\/\/|data:|blob:)/i.test(image)) return image;
  if (image.startsWith('/uploads/')) return `${API_BASE_URL}${image}`;
  if (image.startsWith('/')) return image;
  return `${API_BASE_URL}/uploads/${image}`;
}
