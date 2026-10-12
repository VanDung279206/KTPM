export const PAYMENT_ACCOUNT = {
  bankBin: '970415',
  bankName: 'VietinBank',
  accountNumber: '104883314570',
  accountName: 'NGUYEN VAN DUNG',
} as const;

function field(id: string, value: string): string {
  if (!/^[\x20-\x7e]*$/.test(value) || value.length > 99) {
    throw new Error('Invalid payment QR field');
  }
  return id + value.length.toString().padStart(2, '0') + value;
}

export function paymentQrChecksum(value: string): string {
  let crc = 0xffff;
  for (const byte of new TextEncoder().encode(value)) {
    crc ^= byte << 8;
    for (let bit = 0; bit < 8; bit++) {
      crc = ((crc & 0x8000) ? (crc << 1) ^ 0x1021 : crc << 1) & 0xffff;
    }
  }
  return crc.toString(16).toUpperCase().padStart(4, '0');
}

/** NAPAS account-transfer payload, based on the merchant's verified bank QR. */
export function createPaymentQrPayload(amount: number, orderId: number): string {
  if (!Number.isSafeInteger(amount) || amount <= 0) {
    throw new Error('Payment amount must be a positive integer in VND');
  }
  if (!Number.isSafeInteger(orderId) || orderId <= 0) {
    throw new Error('Payment QR requires a valid order');
  }
  const account = field('00', PAYMENT_ACCOUNT.bankBin) + field('01', PAYMENT_ACCOUNT.accountNumber);
  const merchant = field('00', 'A000000727') + field('01', account) + field('02', 'QRIBFTTA');
  const payload = field('00', '01')
    + field('01', '12')
    + field('38', merchant)
    + field('53', '704')
    + field('54', amount.toString())
    + field('58', 'VN')
    + field('62', field('08', `Bookish ${orderId}`))
    + '6304';
  return payload + paymentQrChecksum(payload);
}
