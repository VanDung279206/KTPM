import test from 'node:test';
import assert from 'node:assert/strict';
import { createPaymentQrPayload, paymentQrChecksum } from '../lib/payment-qr.ts';

function readFields(payload) {
  const fields = {};
  for (let index = 0; index < payload.length;) {
    const key = payload.slice(index, index + 2);
    const length = Number(payload.slice(index + 2, index + 4));
    assert.ok(Number.isInteger(length));
    fields[key] = payload.slice(index + 4, index + 4 + length);
    assert.equal(fields[key].length, length);
    index += 4 + length;
  }
  return fields;
}

test('checksum matches the bank-issued static QR supplied by the merchant', () => {
  const original = '00020101021138560010A0000007270126000697041501121048833145700208QRIBFTTA53037045802VN6304';
  assert.equal(paymentQrChecksum(original), 'D68B');
});

test('generated QR carries the verified receiver and this order amount and reference', () => {
  const qr = createPaymentQrPayload(12345, 123);
  const root = readFields(qr);
  const merchant = readFields(root['38']);
  const receiver = readFields(merchant['01']);
  assert.equal(receiver['00'], '970415');
  assert.equal(receiver['01'], '104883314570');
  assert.equal(merchant['02'], 'QRIBFTTA');
  assert.equal(root['01'], '12');
  assert.equal(root['53'], '704');
  assert.equal(root['54'], '12345');
  assert.equal(readFields(root['62'])['08'], 'Bookish 123');
  assert.equal(qr.slice(-4), paymentQrChecksum(qr.slice(0, -4)));
  assert.notEqual(qr, createPaymentQrPayload(45678, 124));
});

test('invalid amounts or order IDs cannot produce a payable QR', () => {
  for (const amount of [0, -1, 10.5, NaN, Infinity, Number.MAX_SAFE_INTEGER + 1]) {
    assert.throws(() => createPaymentQrPayload(amount, 123));
  }
  for (const order of [0, -1, 1.5, NaN, Infinity]) {
    assert.throws(() => createPaymentQrPayload(12345, order));
  }
});
