'use client';

import { useEffect, useState } from 'react';
import QRCode from 'qrcode';
import { createPaymentQrPayload, PAYMENT_ACCOUNT } from '@/lib/payment-qr';

export function PaymentQr({ amount, orderId }: { amount: number; orderId: number }) {
  const [image, setImage] = useState<{ amount: number; orderId: number; src: string } | null>(null);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    let cancelled = false;
    setFailed(false);
    async function generate() {
      try {
        const src = await QRCode.toDataURL(createPaymentQrPayload(amount, orderId), {
          errorCorrectionLevel: 'M', margin: 4, width: 320,
        });
        if (!cancelled) setImage({ amount, orderId, src });
      } catch {
        if (!cancelled) setFailed(true);
      }
    }
    void generate();
    return () => { cancelled = true; };
  }, [amount, orderId]);

  const current = image?.amount === amount && image.orderId === orderId ? image : null;
  return (
    <div className="flex flex-col items-center gap-2 text-center">
      <p className="text-sm font-semibold">{PAYMENT_ACCOUNT.bankName}</p>
      {current ? (
        <img src={current.src} alt={`QR chuyển khoản ${PAYMENT_ACCOUNT.bankName} cho đơn ${orderId}`}
          width={224} height={224} className="h-56 w-56 rounded-xl border border-[#d2d2d7]" />
      ) : (
        <p className="flex h-56 w-56 items-center justify-center text-sm text-[#6e6e73]" role="status">
          {failed ? 'Không tạo được mã QR. Vui lòng tải lại trang.' : 'Đang tạo mã QR...'}
        </p>
      )}
      <p className="text-sm font-semibold">{PAYMENT_ACCOUNT.accountName}</p>
      <p className="text-sm">Số tài khoản: {PAYMENT_ACCOUNT.accountNumber}</p>
      <p className="text-sm">Số tiền: {amount.toLocaleString('vi-VN')}đ</p>
      <p className="text-sm">Nội dung: Bookish {orderId}</p>
    </div>
  );
}
