import test from 'node:test';
import assert from 'node:assert/strict';

process.env.NEXT_PUBLIC_API_URL = 'https://api.bookish.example/';
delete process.env.NEXT_PUBLIC_WS_URL;
const urls = await import('../lib/backend-url.ts');

test('HTTPS deployment uses encrypted WebSocket and removes trailing slash', () => {
  assert.equal(urls.API_BASE_URL, 'https://api.bookish.example');
  assert.equal(urls.getWebSocketUrl(), 'wss://api.bookish.example/ws/websocket');
});

test('old localhost image URLs use deployed backend while public assets keep their URLs', () => {
  assert.equal(urls.getBackendImageUrl('http://localhost:8080/uploads/book.jpg'), 'https://api.bookish.example/uploads/book.jpg');
  assert.equal(urls.getBackendImageUrl('/uploads/book.jpg'), 'https://api.bookish.example/uploads/book.jpg');
  assert.equal(urls.getBackendImageUrl('book.jpg'), 'https://api.bookish.example/uploads/book.jpg');
  assert.equal(urls.getBackendImageUrl('/banners/Banner1.png'), '/banners/Banner1.png');
  assert.equal(urls.getBackendImageUrl('https://images.example/book.jpg'), 'https://images.example/book.jpg');
  assert.equal(urls.getBackendImageUrl(null), '/placeholder.svg');
});

test('explicit WebSocket endpoint is respected', () => {
  process.env.NEXT_PUBLIC_WS_URL = 'wss://realtime.bookish.example/ws';
  assert.equal(urls.getWebSocketUrl(), 'wss://realtime.bookish.example/ws');
});
