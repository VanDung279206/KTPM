# Bookish Bookstore

Bookish là hệ thống thương mại điện tử bán sách, gồm giao diện khách hàng, khu vực quản trị và REST API phục vụ các nghiệp vụ tài khoản, danh mục sách, giỏ hàng, đặt hàng, thanh toán, khuyến mãi, đánh giá và xử lý đổi trả.

Repository được tổ chức thành hai ứng dụng:

- `bookstore-frontend`: giao diện web Next.js/React.
- `bookstore-backend/bookish`: REST API Spring Boot kết nối MySQL.
- `Database/bookstore_data.sql`: schema và dữ liệu mẫu cho database `bookish`.

> Tài liệu này được viết theo cấu trúc và mã nguồn hiện tại của repository. Một số cấu hình backend đang nằm trực tiếp trong `application.properties`; cần thay thế các giá trị mẫu/nhạy cảm trước khi triển khai.

## Mục lục

- [Tính năng](#tính-năng)
- [Kiến trúc và công nghệ](#kiến-trúc-và-công-nghệ)
- [Yêu cầu môi trường](#yêu-cầu-môi-trường)
- [Cài đặt nhanh](#cài-đặt-nhanh)
- [Cấu hình](#cấu-hình)
- [Chạy dự án](#chạy-dự-án)
- [Tài khoản và phân quyền](#tài-khoản-và-phân-quyền)
- [Danh mục API](#danh-mục-api)
- [Cơ sở dữ liệu](#cơ-sở-dữ-liệu)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Kiểm thử và build](#kiểm-thử-và-build)
- [Luồng nghiệp vụ chính](#luồng-nghiệp-vụ-chính)
- [Upload ảnh và email](#upload-ảnh-và-email)
- [Realtime và thanh toán](#realtime-và-thanh-toán)
- [Xử lý sự cố](#xử-lý-sự-cố)
- [Lưu ý bảo mật](#lưu-ý-bảo-mật)

## Tính năng

### Khách hàng

- Xem sách mới, sách bán chạy, tìm kiếm và lọc theo danh mục/tác giả.
- Xem chi tiết sách, thông tin tác giả, tồn kho và đánh giá.
- Đăng ký, đăng nhập, đăng xuất bằng JWT.
- Xác thực email bằng mã OTP 6 chữ số.
- Gửi lại OTP và đổi email trước khi xác thực.
- Quên mật khẩu và đặt lại mật khẩu bằng mã gửi qua email.
- Quản lý hồ sơ, mật khẩu và ảnh đại diện.
- Thêm, sửa, xóa sản phẩm trong giỏ hàng.
- Thêm/xóa sách yêu thích và xem số lượng yêu thích.
- Checkout, tính phí vận chuyển, áp dụng mã khuyến mãi và theo dõi đơn hàng.
- Xác nhận thanh toán, xác nhận đã nhận hàng và hủy đơn theo trạng thái.
- Gửi yêu cầu đổi trả, cập nhật thông tin ngân hàng và hủy yêu cầu.
- Viết đánh giá sau khi đủ điều kiện đánh giá.
- Nhận thông báo đơn hàng realtime và sử dụng chatbot hỗ trợ.

### Quản trị viên và nhân viên

- Quản lý sách, tác giả, danh mục và người dùng.
- Quản lý nhân viên.
- Quản lý đơn hàng: cập nhật trạng thái, hủy đơn, xác nhận hàng loạt và chuyển hàng loạt.
- Quản lý khuyến mãi và kiểm tra mã giảm giá.
- Duyệt, từ chối và xử lý hoàn tiền các yêu cầu đổi trả.
- Xem dashboard báo cáo doanh thu, đơn hàng, sách bán chạy, danh mục và sách sắp hết hàng.

## Kiến trúc và công nghệ

### Frontend

- Next.js `16.1.6` với App Router.
- React `19.2.4`, TypeScript `5.7.3`.
- Tailwind CSS 4 và các component Radix UI.
- Zustand cho state management.
- React Hook Form và Zod cho form/validation.
- `lucide-react`, `framer-motion`, `recharts`, `sonner`.
- STOMP.js cho kết nối WebSocket.
- Mặc định gọi backend tại `http://localhost:8080`.

### Backend

- Java 21.
- Spring Boot `4.0.3`.
- Spring Web MVC, Spring Data JPA, Spring Security, Validation.
- MySQL Connector/J.
- JWT bằng JJWT `0.11.5`.
- Spring Mail để gửi OTP và mã reset mật khẩu.
- Spring WebSocket.
- Lombok.
- Maven Wrapper (`mvnw.cmd` cho Windows).

### Mô hình giao tiếp

```text
Browser
  |
  | HTTP/JSON + Bearer JWT
  v
Next.js frontend :3000
  |
  | REST API
  v
Spring Boot backend :8080
  |        |        |
  |        |        +-- SMTP Gmail
  |        +----------- MySQL: bookish
  +-------------------- uploads/ và WebSocket
```

## Yêu cầu môi trường

Cài đặt các thành phần sau trước khi chạy:

- Windows 10/11.
- Git.
- Node.js phiên bản tương thích với Next.js 16, khuyến nghị Node.js 20 LTS trở lên.
- `pnpm` vì repository có `pnpm-lock.yaml`.
- JDK 21.
- MySQL 8.0 trở lên.
- Một tài khoản SMTP Gmail có App Password nếu cần đăng ký/xác thực email hoặc reset mật khẩu.
- Groq API key nếu muốn sử dụng chatbot AI.

Kiểm tra phiên bản:

```powershell
node --version
pnpm --version
java --version
mysql --version
```

## Cài đặt nhanh

### 1. Clone và mở repository

```powershell
git clone <URL_REPOSITORY>
cd BookStore_14
```

Nếu đã mở repository trong VS Code, bỏ qua bước clone.

### 2. Tạo database MySQL

Khởi động MySQL rồi tạo database rỗng:

```sql
CREATE DATABASE bookish
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

Import schema và dữ liệu mẫu từ thư mục gốc:

```powershell
mysql -u root -p bookish < Database/bookstore_data.sql
```

Hoặc dùng MySQL Workbench mở file `Database/bookstore_data.sql` và chạy toàn bộ script.

> File SQL có các lệnh `DROP TABLE IF EXISTS`. Chỉ import lại trên database phát triển/test vì có thể xóa dữ liệu hiện tại.

### 3. Cài dependency frontend

```powershell
cd bookstore-frontend
pnpm install
cd ..
```

### 4. Cấu hình backend

Mở:

`bookstore-backend/bookish/src/main/resources/application.properties`

Tối thiểu cần kiểm tra/cập nhật:

- Tài khoản và mật khẩu MySQL.
- `upload.dir` phải trỏ tới thư mục upload có thể ghi.
- `server.url` phải khớp URL backend.
- SMTP username/password.
- `groq.api.key` nếu dùng chatbot.

### 5. Chạy hai ứng dụng

Mở hai terminal riêng biệt. Chạy backend trước:

```powershell
cd bookstore-backend/bookish
.\mvnw.cmd spring-boot:run
```

Lệnh trên được ghi với Maven Wrapper của Windows. Nếu terminal không xử lý được ký tự `.` như trên, dùng:

```powershell
cd bookstore-backend/bookish
cmd /c mvnw.cmd spring-boot:run
```

Chạy frontend ở terminal thứ hai:

```powershell
cd bookstore-frontend
pnpm dev
```

Mở trình duyệt tại:

- Frontend: <http://localhost:3000>
- Backend: <http://localhost:8080>

Frontend lấy URL backend từ biến `NEXT_PUBLIC_API_URL`; nếu biến này không tồn tại, giá trị mặc định là `http://localhost:8080`.

## Cấu hình

### Backend hiện tại

Các giá trị mặc định đang được đọc từ `bookstore-backend/bookish/src/main/resources/application.properties`:

| Thuộc tính | Giá trị mặc định | Mục đích |
|---|---|---|
| `spring.datasource.url` | `jdbc:mysql://localhost:3306/bookish` | Kết nối MySQL |
| `spring.datasource.username` | `root` | User MySQL |
| `spring.datasource.password` | Cấu hình cục bộ | Mật khẩu MySQL |
| `server.port` | `8080` | Cổng REST API |
| `server.url` | `http://localhost:8080` | URL sinh link upload |
| `upload.dir` | Đường dẫn local | Nơi lưu ảnh |
| `spring.servlet.multipart.max-file-size` | `5MB` | Giới hạn mỗi file |
| `spring.servlet.multipart.max-request-size` | `5MB` | Giới hạn request upload |
| `spring.mail.*` | SMTP Gmail | Gửi email OTP/reset |
| `app.verification.code-expiry-minutes` | `10` | Thời hạn mã xác thực |
| `groq.api.key` | Cấu hình cục bộ | Chatbot AI |

### Frontend

Có thể đặt URL API khi chạy frontend:

PowerShell:

```powershell
$env:NEXT_PUBLIC_API_URL="http://localhost:8080"
pnpm dev
```

Khi dùng file `.env.local` trong `bookstore-frontend`:

```env
NEXT_PUBLIC_API_URL=http://localhost:8080
```

Sau khi thay đổi biến môi trường, cần khởi động lại Next.js dev server.

### Cấu hình production khuyến nghị

Không dùng password, API key, SMTP credential hoặc đường dẫn local cố định trong source code. Nên chuyển sang biến môi trường/secret manager, ví dụ:

```properties
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
server.url=${SERVER_URL:http://localhost:8080}
upload.dir=${UPLOAD_DIR:uploads}
groq.api.key=${GROQ_API_KEY}
spring.mail.username=${MAIL_USERNAME}
spring.mail.password=${MAIL_PASSWORD}
app.mail.from=${MAIL_FROM}
```

## Chạy dự án

### Development

Backend:

```powershell
cd bookstore-backend/bookish
.\mvnw.cmd spring-boot:run
```

Frontend:

```powershell
cd bookstore-frontend
pnpm dev
```

### Build backend

```powershell
cd bookstore-backend/bookish
.\mvnw.cmd clean package
```

File JAR sau khi build nằm trong `target/`. Chạy JAR:

```powershell
java -jar target/bookstore-0.0.1-SNAPSHOT.jar
```

Tên JAR thực tế có thể thay đổi theo version trong `pom.xml`.

### Build và chạy frontend production

```powershell
cd bookstore-frontend
pnpm build
pnpm start
```

## Tài khoản và phân quyền

Backend tạo JWT sau khi đăng nhập thành công. Frontend gửi token qua header:

```http
Authorization: Bearer <JWT>
```

Các authority đang được sử dụng:

| Quyền | Phạm vi |
|---|---|
| Người dùng đã đăng nhập | Hồ sơ, wishlist, đổi trả, đánh giá và các nghiệp vụ cá nhân |
| `STAFF` | Quản lý sách, tác giả, danh mục, người dùng, đơn hàng, khuyến mãi, đổi trả và báo cáo theo rule backend |
| `ADMIN` | Toàn bộ phạm vi quản trị |

Đăng ký mới yêu cầu xác thực email. Nếu email chưa được xác thực, login sẽ bị từ chối và người dùng phải nhập OTP gửi qua email.

## Danh mục API

Base URL mặc định: `http://localhost:8080`.

Các endpoint dưới đây là các nhóm route được khai báo trong controller. Chi tiết request/response nằm trong các DTO ở `bookstore-backend/bookish/src/main/java/com/bookish/bookish/dto`.

| Nhóm | Base path | Chức năng chính |
|---|---|---|
| Auth | `/auth` | Login, register, logout, verify email, resend OTP, đổi email, quên/reset mật khẩu |
| Sách | `/books` | Danh sách phân trang, sách mới, bán chạy, tìm kiếm, lọc, CRUD quản trị |
| Tác giả | `/authors` | Danh sách, phân trang, CRUD |
| Danh mục | `/categories` | Danh sách, phân trang, CRUD |
| Khách hàng | `/customers` | Danh sách quản trị, CRUD hồ sơ, đổi mật khẩu |
| Nhân viên | `/staff` | Xem và tạo tài khoản nhân viên |
| Avatar | `/users/{id}/avatar` | Upload/xóa ảnh đại diện dạng multipart |
| Giỏ hàng | `/api/cart` | Xem giỏ, thêm, cập nhật, xóa item và xóa toàn bộ |
| Đơn hàng | `/api/orders` | Checkout, xem danh sách/chi tiết, hủy, xác nhận thanh toán/giao hàng/đã nhận |
| Quản trị đơn | `/api/admin/orders` | Cập nhật trạng thái, bulk confirm, bulk ship, phân trang |
| Khuyến mãi | `/promotions` | CRUD, validate mã, danh sách áp dụng checkout |
| Wishlist | `/api/wishlist` | Xem, thêm/xóa sách, kiểm tra và đếm số lượng |
| Đánh giá | `/api/reviews` | Xem review, điểm trung bình, kiểm tra điều kiện, tạo review |
| Đổi trả | `/api/returns` | Tạo/xem/hủy yêu cầu, cập nhật thông tin ngân hàng |
| Quản trị đổi trả | `/api/admin/returns` | Xem, duyệt, từ chối, đánh dấu đã nhận hàng và hoàn tiền |
| Vận chuyển | `/api/shipping` | Tính phí vận chuyển |
| Upload | `/upload` | Upload ảnh sản phẩm hoặc ảnh dùng trong hệ thống |
| Thông báo | `/api/notifications` | Danh sách, số chưa đọc, đánh dấu đã đọc |
| Chatbot | `/api/chatbot` | Gửi câu hỏi và xem cache chatbot |
| Thống kê | `/api/admin/stats` | Tổng quan, doanh thu, ngày, sách bán chạy, danh mục, tồn kho thấp, trạng thái đơn |
| Webhook | `/api/webhook/sepay` | Nhận callback thanh toán từ SePay |

Một số nhóm public gồm đọc sách/tác giả/danh mục, auth, ảnh upload và các endpoint đọc review. Các route wishlist, đổi trả, review ghi dữ liệu, avatar và route quản trị yêu cầu JWT theo `SecurityConfig`.

## Cơ sở dữ liệu

Database mặc định có tên `bookish`, dùng MySQL và được cấu hình với `spring.jpa.hibernate.ddl-auto=none`; nghĩa là Hibernate không tự tạo schema. Cần import dump trước khi chạy backend.

Các nhóm bảng chính trong `Database/bookstore_data.sql`:

- Catalog: `books`, `authors`, `categories`, `book_authors`, `book_categories`.
- Người dùng: `users` và các trường role/email verification/avatar.
- Mua hàng: `carts`, `cart_items`, `orders`, `order_items`.
- Khuyến mãi: `promotions`, `promotion_usage`, `order_promotions`.
- Tương tác: `reviews`, `wishlists`, `notifications`.
- Đổi trả: `return_requests` và thông tin liên quan.
- Chatbot/log nghiệp vụ theo các entity tương ứng trong backend.

Dump SQL có sẵn dữ liệu mẫu cho việc phát triển giao diện và kiểm thử luồng mua hàng.

## Cấu trúc thư mục

```text
BookStore_14/
├── README.md
├── Database/
│   └── bookstore_data.sql
├── bookstore-backend/
│   └── bookish/
│       ├── pom.xml
│       ├── mvnw / mvnw.cmd
│       ├── src/main/java/com/bookish/bookish/
│       │   ├── config/       # CORS, Security, upload, WebSocket
│       │   ├── controller/   # REST controllers
│       │   ├── dto/          # Request/response objects
│       │   ├── entity/       # JPA entities và enum
│       │   ├── exception/     # Error code và global handler
│       │   ├── mapper/       # Entity-to-response mapper
│       │   ├── repository/   # Spring Data repositories
│       │   ├── security/     # JWT filter và utility
│       │   └── service/      # Business logic
│       ├── src/main/resources/
│       │   └── application.properties
│       ├── src/test/         # Test backend
│       └── uploads/          # Ảnh upload local
└── bookstore-frontend/
    ├── app/
    │   ├── (main)/           # Màn hình khách hàng
    │   └── admin/            # Màn hình quản trị
    ├── components/           # Component dùng chung và admin
    ├── hooks/                # Custom hooks
    ├── lib/
    │   ├── api.ts            # API client và base URL
    │   ├── api/              # API client theo domain
    │   ├── store/            # Zustand stores
    │   └── types.ts          # TypeScript types
    ├── public/                # Banner và asset tĩnh
    ├── package.json
    ├── pnpm-lock.yaml
    └── next.config.mjs
```

Các route frontend đáng chú ý:

- `/`, `/shop`: trang chủ và cửa hàng.
- `/book/[id]`, `/author/[name]`: chi tiết sách và tác giả.
- `/cart`, `/checkout`, `/checkout/success`: giỏ hàng và checkout.
- `/login`, `/register`, `/verify-otp`, `/forgot-password`, `/reset-password`: xác thực tài khoản.
- `/orders/[id]`, `/profile`, `/wishlist`: khu vực cá nhân.
- `/admin`, `/admin/books`, `/admin/authors`, `/admin/categories`, `/admin/orders`, `/admin/promotions`, `/admin/reports`, `/admin/returns`, `/admin/users`: quản trị.

## Kiểm thử và build

### Backend

Chạy test bằng Maven Wrapper:

```powershell
cd bookstore-backend/bookish
.\mvnw.cmd test
```

Hiện source có test khởi động ứng dụng tại `src/test`. Các test tích hợp có thể cần MySQL và cấu hình SMTP phù hợp tùy phạm vi test.

### Frontend

Lint:

```powershell
cd bookstore-frontend
pnpm lint
```

Build kiểm tra production:

```powershell
pnpm build
```

`next.config.mjs` hiện đặt `typescript.ignoreBuildErrors=true`, vì vậy build Next.js có thể không chặn bởi lỗi TypeScript. Nên chạy `pnpm lint` và kiểm tra type riêng trong CI nếu cần chất lượng nghiêm ngặt.

## Luồng nghiệp vụ chính

### Đăng ký và xác thực email

1. Frontend gửi thông tin tới `POST /auth/register`.
2. Backend tạo user với `email_verified=false` và sinh OTP 6 chữ số.
3. Spring Mail gửi OTP tới email.
4. Frontend gửi email và OTP tới `POST /auth/verify-email`.
5. Backend đánh dấu email đã xác thực và trả JWT.
6. Login của user chưa xác thực bị từ chối.

### Mua hàng

1. Người dùng xem sách và thêm item vào `/api/cart`.
2. Frontend gửi `POST /api/orders/checkout` với sản phẩm, địa chỉ và thông tin checkout.
3. Backend kiểm tra tồn kho, khuyến mãi và phí vận chuyển.
4. Đơn hàng được tạo và frontend hiển thị trang thành công.
5. Thanh toán có thể được xác nhận qua endpoint đơn hàng hoặc webhook SePay.
6. Người dùng theo dõi và cập nhật trạng thái đơn trong trang orders.

### Đổi trả

1. Người dùng tạo yêu cầu tại `POST /api/returns`.
2. Có thể upload ảnh bằng `/upload/image` trước rồi gửi URL ảnh trong request đổi trả.
3. Admin/staff duyệt hoặc từ chối yêu cầu.
4. Khi hàng được nhận, admin đánh dấu đã trả hàng và hoàn tiền.
5. Người dùng có thể cập nhật thông tin ngân hàng hoặc hủy yêu cầu theo trạng thái.

## Upload ảnh và email

### Upload

- Backend phục vụ file tĩnh từ `/uploads/**`.
- Thư mục mặc định được cấu hình bởi `upload.dir`.
- Giới hạn file và request hiện là `5MB`.
- Avatar được lưu trong thư mục con `uploads/avatars/`.
- Khi deploy, cần tạo thư mục, cấp quyền ghi và dùng storage phù hợp nếu chạy nhiều instance.

### Email

Email dùng SMTP Gmail port `587` với STARTTLS. App Password nên được dùng thay cho mật khẩu Gmail chính. Nếu SMTP chưa cấu hình đúng, các luồng register/verify/reset có thể không hoàn tất.

## Realtime và thanh toán

- Backend bật WebSocket trong `WebSocketConfig` và có endpoint phục vụ thông báo đơn hàng.
- Frontend có `@stomp/stompjs` và hook `use-order-notification` để nhận cập nhật realtime.
- Webhook SePay nhận tại `POST /api/webhook/sepay`.
- Khi chạy local, webhook từ bên ngoài cần một public tunnel hoặc môi trường staging có URL public.
- Không nên để webhook permit toàn bộ mà không có cơ chế xác thực/chữ ký khi triển khai production; cần kiểm tra cơ chế xác minh của nhà cung cấp thanh toán.

## Xử lý sự cố

### Frontend không gọi được backend

1. Kiểm tra backend đang chạy ở `http://localhost:8080`.
2. Kiểm tra `NEXT_PUBLIC_API_URL`.
3. Kiểm tra CORS trong backend.
4. Xem tab Network của trình duyệt để phân biệt lỗi CORS, 401/403 hay 500.

### Không đăng ký được tài khoản

1. Kiểm tra MySQL có database `bookish` và bảng `users`.
2. Kiểm tra SMTP username, App Password và STARTTLS.
3. Kiểm tra log backend có lỗi gửi email hay không.
4. Kiểm tra email chưa tồn tại trong database.

### Ảnh không hiển thị

1. Kiểm tra `upload.dir` tồn tại và có quyền ghi.
2. Kiểm tra backend đang phục vụ `/uploads/**`.
3. Kiểm tra `server.url` khớp host/port hiện tại.
4. Kiểm tra URL ảnh trong database không còn trỏ tới đường dẫn máy khác.

### Lỗi database khi khởi động

- Đảm bảo MySQL đang chạy.
- Đảm bảo database tên `bookish` đã được tạo.
- Kiểm tra username/password trong `application.properties`.
- Import lại `Database/bookstore_data.sql` trên database development nếu schema chưa đầy đủ.

## Lưu ý bảo mật

- Không commit password MySQL, SMTP password, Groq API key, JWT secret hoặc token webhook.
- Cấu hình hiện tại trong `application.properties` có thông tin credential dạng plaintext. Các credential đó cần được thay/thu hồi và chuyển sang biến môi trường trước khi public repository hoặc deploy.
- Không dùng tài khoản MySQL `root` trong production; tạo user riêng với quyền tối thiểu.
- Bật HTTPS khi triển khai thật.
- Giới hạn CORS theo domain frontend thay vì cho phép rộng.
- Kiểm tra chữ ký/xác thực webhook SePay trước khi cập nhật trạng thái thanh toán.
- Giới hạn MIME type, kích thước và tên file upload; không cho phép upload file thực thi.
- Dùng secret riêng cho từng môi trường và xoay secret nếu từng bị lộ.
- Không dùng dữ liệu dump production trong môi trường phát triển nếu chưa ẩn danh thông tin cá nhân.

## License

Repository hiện chưa khai báo license riêng. Không tự ý phân phối hoặc sử dụng thương mại nếu chưa có sự cho phép của chủ sở hữu dự án.
