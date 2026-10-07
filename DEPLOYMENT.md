# Triển khai Bookish online

Website: https://ktpm-bookish-vandung279206.vercel.app/
Backend healthcheck: https://bookish-api-production-d1a8.up.railway.app/health

Frontend: Vercel, Root Directory `bookstore-frontend`, preset Next.js.
Backend: Railway, Root Directory `bookstore-backend/bookish`, Dockerfile, Java 21.
Database: MySQL trong cùng project Railway.

## Biến môi trường backend

```dotenv
SPRING_PROFILES_ACTIVE=cloud
DB_URL=jdbc:mysql://${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}/${{MySQL.MYSQLDATABASE}}?allowPublicKeyRetrieval=true
DB_USERNAME=${{MySQL.MYSQLUSER}}
DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}
SERVER_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
CORS_ALLOWED_ORIGINS=https://ktpm-bookish-vandung279206.vercel.app
JWT_SECRET=<chuỗi ngẫu nhiên tối thiểu 32 byte, lưu riêng trong Railway>
DB_INITIALIZE=true
BOOTSTRAP_ADMIN_PASSWORD=<mật khẩu ngẫu nhiên, lưu riêng trong Railway>
UPLOAD_DIR=/app/uploads
```

`PORT` do Railway cung cấp. Nếu tự cấu hình port, dùng `SERVER_PORT=8080`.
Healthcheck: `/health`.
Trong Railway Settings đặt Builder = Dockerfile và Healthcheck Path = `/health`.

Khi `DB_INITIALIZE=true`, ứng dụng chỉ tạo schema và danh mục sách nếu database hoàn toàn trống.
Tài khoản `admin` được tạo với `BOOTSTRAP_ADMIN_PASSWORD` tại lần khởi tạo đầu tiên.
Sau lần khởi tạo thành công, đặt `DB_INITIALIZE=false`.
Lấy mật khẩu admin tại Railway → bookish-api → Variables → `BOOTSTRAP_ADMIN_PASSWORD`.
Sau khi lưu mật khẩu vào nơi riêng an toàn, có thể xóa biến này; mật khẩu đã băm trong database không thay đổi.
Database đang có bảng sẽ không bị ghi đè hoặc đặt lại mật khẩu.

Seed deploy không chứa dữ liệu tài khoản, giỏ hàng, đơn hàng hay thông tin đổi trả từ dump cũ.
Ảnh upload cũ không có trong repo; tải lại ảnh qua trang quản trị sau khi deploy.
Để giữ ảnh qua các lần deploy, gắn volume Railway tại `/app/uploads` hoặc chuyển sang object storage.

Đăng ký/OTP/reset mật khẩu cần cấu hình `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_FROM`;
các biến tùy chọn khác: `MAIL_HOST` (smtp.gmail.com), `MAIL_PORT` (587).
Chatbot cần `GROQ_API_KEY`. Nhập những giá trị này trực tiếp trong Railway Variables.
Không đặt mật khẩu hoặc key trong repo hoặc trong biến `NEXT_PUBLIC_*`.

## Biến môi trường frontend

```dotenv
NEXT_PUBLIC_API_URL=https://bookish-api-production-d1a8.up.railway.app
```

Đặt biến này trước khi build. WebSocket tự chuyển sang `wss://` từ URL HTTPS.
Có thể cấu hình riêng `NEXT_PUBLIC_WS_URL` khi cần một endpoint khác.
Đổi địa chỉ API xong phải redeploy frontend.

## Kiểm tra sau triển khai

- Backend `/health` trả `{"status":"ok"}`.
- `/books` và `/categories` trả dữ liệu từ MySQL.
- Frontend mở trang chủ, cửa hàng và chi tiết sách.
- Đăng nhập bằng tài khoản admin và kiểm tra khu vực quản trị.
- Origin frontend được backend cho phép; origin khác bị từ chối.

Gói dùng thử Railway có thời hạn và giới hạn tài nguyên. Kiểm tra Usage để quản lý chi phí.
