# BỘ CÂU HỎI - TRẢ LỜI BẢO VỆ ĐỒ ÁN
## Ứng dụng giao đồ ăn (Delivery Apps)

> Tài liệu tổng hợp các câu hỏi **nền tảng** mà hội đồng thường đặt ra khi bảo vệ đồ án, kèm gợi ý trả lời ngắn gọn. Bộ câu hỏi tập trung vào hiểu biết tổng quan, không đi quá sâu vào chi tiết kỹ thuật. Mục tiêu là giúp em hiểu **bản chất** của hệ thống mình đã xây.

---

## MỤC LỤC
1. [Câu hỏi tổng quan đề tài](#1-câu-hỏi-tổng-quan-đề-tài)
2. [Câu hỏi về kiến trúc hệ thống](#2-câu-hỏi-về-kiến-trúc-hệ-thống)
3. [Câu hỏi về công nghệ sử dụng](#3-câu-hỏi-về-công-nghệ-sử-dụng)
4. [Câu hỏi về cơ sở dữ liệu](#4-câu-hỏi-về-cơ-sở-dữ-liệu)
5. [Câu hỏi về xác thực & phân quyền](#5-câu-hỏi-về-xác-thực--phân-quyền)
6. [Câu hỏi về các chức năng chính](#6-câu-hỏi-về-các-chức-năng-chính)
7. [Câu hỏi về Realtime](#7-câu-hỏi-về-realtime)
8. [Câu hỏi về bản đồ & vị trí](#8-câu-hỏi-về-bản-đồ--vị-trí)
9. [Câu hỏi về Flutter](#9-câu-hỏi-về-flutter)
10. [Câu hỏi mở / nhận xét chung](#10-câu-hỏi-mở--nhận-xét-chung)

---

## 1. CÂU HỎI TỔNG QUAN ĐỀ TÀI

### Q1.1: Đề tài của em là gì?
**Trả lời:** Em xây dựng một ứng dụng giao đồ ăn (food delivery) tương tự GrabFood / ShopeeFood. Ứng dụng có 3 vai trò:
- **USER (Khách hàng)**: tìm nhà hàng, đặt món, theo dõi đơn.
- **RESTAURANT (Nhà hàng)**: quản lý menu, xác nhận đơn.
- **SHIPPER (Tài xế)**: nhận đơn, giao hàng.

### Q1.2: Vì sao em chọn đề tài này?
**Trả lời:** Đây là bài toán thực tế gần gũi với cuộc sống và có nhiều thử thách kỹ thuật như: xác thực người dùng, đặt đơn nhiều bước, cập nhật thời gian thực, tính phí theo khoảng cách, phân quyền theo vai trò. Triển khai đề tài giúp em chạm vào hầu hết các vấn đề của một hệ thống thực tế.

### Q1.3: Phạm vi đề tài? Người dùng mục tiêu?
**Trả lời:** Phạm vi là một **MVP (Minimum Viable Product)** trên nền tảng **mobile (Android/iOS)**. Đối tượng là 3 nhóm người dùng nêu trên. Em chưa làm trang admin web vì giới hạn thời gian.

### Q1.4: Hệ thống của em có gì khác so với app thương mại?
**Trả lời:** Em không kỳ vọng vượt trội. Điểm em chú trọng là:
1. Kiến trúc Client - Server rõ ràng, tách biệt.
2. Cập nhật trạng thái đơn realtime thay vì polling.
3. Có hỗ trợ tuỳ chọn món (size, topping) giống menu thật.

---

## 2. CÂU HỎI VỀ KIẾN TRÚC HỆ THỐNG

### Q2.1: Mô tả kiến trúc tổng thể của hệ thống?
**Trả lời:** Hệ thống theo mô hình **Client - Server**:

```
┌────────────────┐    REST API (HTTPS)    ┌──────────────────┐
│  Flutter App   │ ─────────────────────► │ Node.js + Express│
│   (Client)     │ ◄───────────────────── │   (Backend)      │
└───────┬────────┘                        └──────────┬───────┘
        │                                            │
        │  Realtime (WebSocket)                      │  Prisma ORM
        │  + Storage (Upload ảnh)                    │
        ▼                                            ▼
┌─────────────────────────────────────────────────────────┐
│   Supabase (PostgreSQL + Realtime + Storage)            │
│   + Firebase Auth (xác thực)                            │
└─────────────────────────────────────────────────────────┘
```

- **Client**: Flutter app chạy trên điện thoại.
- **Server**: Node.js + Express xử lý logic nghiệp vụ.
- **Database**: PostgreSQL trên Supabase.
- **Auth**: Firebase Authentication.

### Q2.2: Vì sao em tách backend riêng mà không cho Flutter gọi thẳng database?
**Trả lời:** Có 3 lý do chính:
1. **Tập trung logic nghiệp vụ** ở backend (tính phí, validate đơn) — không để client tự tính.
2. **Bảo mật**: client không có quyền trực tiếp với DB, mọi thao tác đều qua backend đã xác thực.
3. **Dễ thay đổi**: sau này đổi DB không phải sửa app.

### Q2.3: Em chia code Flutter theo nguyên tắc gì?
**Trả lời:** Em chia theo **Feature-First** (theo tính năng):
```
lib/
├── core/         (phần dùng chung: services, models, providers)
└── features/
    ├── user/     (chức năng cho khách hàng)
    ├── restaurant/(chức năng cho nhà hàng)
    └── shipper/  (chức năng cho tài xế)
```
Cách chia này giúp mỗi vai trò người dùng tự chứa code riêng, dễ tìm và mở rộng.

### Q2.4: Backend của em tổ chức như thế nào?
**Trả lời:** Theo pattern **Router → Controller → Model**:
- `routers/`: định nghĩa URL endpoint + middleware.
- `controllers/`: chứa logic xử lý.
- `prisma/schema.prisma`: định nghĩa model dữ liệu.
- `middleware/`: hàm xác thực và phân quyền.

---

## 3. CÂU HỎI VỀ CÔNG NGHỆ SỬ DỤNG

### Q3.1: Em dùng những công nghệ chính nào?
**Trả lời:**

| Phần | Công nghệ |
|---|---|
| Mobile Client | **Flutter / Dart** |
| Backend | **Node.js + Express** |
| Database | **PostgreSQL** (qua Supabase) |
| ORM | **Prisma** |
| Xác thực | **Firebase Authentication** |
| Realtime | **Supabase Realtime** |
| Storage ảnh | **Supabase Storage** |
| Email OTP | **Nodemailer (Gmail SMTP)** |
| Bản đồ | **OpenStreetMap** (`flutter_map`) |
| State Flutter | **Provider** |

### Q3.2: Vì sao chọn Flutter mà không phải React Native hay Native?
**Trả lời:**
- So với **Native**: Flutter cho phép viết 1 codebase chạy cả Android và iOS, tiết kiệm thời gian.
- So với **React Native**: Flutter render bằng engine riêng nên UI mượt và nhất quán hơn giữa 2 hệ điều hành.

### Q3.3: Vì sao chọn Node.js cho backend?
**Trả lời:**
- Node.js xử lý bất đồng bộ (async I/O) tốt — phù hợp app nhiều request đồng thời.
- Hệ sinh thái npm phong phú, học và triển khai nhanh.
- JavaScript là ngôn ngữ phổ biến, dễ tìm tài liệu.

### Q3.4: Supabase là gì?
**Trả lời:** Supabase là một nền tảng **Backend-as-a-Service** mã nguồn mở, cung cấp:
- **Database PostgreSQL** thật sự (quan hệ).
- **Realtime** qua WebSocket.
- **Storage** lưu file.

Trong project em dùng Supabase cho cả 3 chức năng đó.

### Q3.5: Tại sao dùng cả Firebase và Supabase?
**Trả lời:** Mỗi bên mạnh ở một mảng:
- **Firebase Auth**: dễ tích hợp Phone OTP, Google Sign-In, SDK Flutter ổn định.
- **Supabase**: cung cấp **PostgreSQL quan hệ** (Firebase chỉ có Firestore là NoSQL) — phù hợp hơn với schema có nhiều quan hệ như đơn hàng - món - option.

Em chấp nhận dùng 2 SDK để lấy điểm mạnh của cả hai.

### Q3.6: Prisma là gì?
**Trả lời:** Prisma là một **ORM (Object-Relational Mapping)** — công cụ ánh xạ giữa code và database. Lợi ích:
- Định nghĩa schema 1 lần ở file `schema.prisma`, Prisma tự sinh code truy vấn.
- Có **type-safe** (kiểm tra kiểu dữ liệu khi viết code).
- Hỗ trợ **migration** (tự sinh file SQL khi đổi schema).

---

## 4. CÂU HỎI VỀ CƠ SỞ DỮ LIỆU

### Q4.1: Em dùng database gì? Vì sao?
**Trả lời:** Em dùng **PostgreSQL** — một database quan hệ. Lý do:
- Dữ liệu của em có nhiều quan hệ (user - đơn - món - option) → cần DB quan hệ.
- PostgreSQL hỗ trợ kiểu **Decimal** (để lưu tiền chính xác) và **JSON** (để lưu options).

### Q4.2: Hệ thống của em có những bảng chính nào?
**Trả lời:** Các bảng chính:
- `users` — người dùng (cả 3 role chung 1 bảng, phân biệt qua trường `role`).
- `restaurants` — thông tin nhà hàng.
- `shippers` — thông tin tài xế.
- `foods` — món ăn của nhà hàng.
- `orders` — đơn hàng.
- `order_items` — chi tiết từng món trong đơn.
- `addresses` — địa chỉ giao của user.
- `cart_items` — giỏ hàng.
- `favorites` — món yêu thích.
- `categories` — danh mục món.

### Q4.3: Em vẽ sơ đồ quan hệ chính như thế nào?
**Trả lời:**
```
users ──┬── 1:N ── addresses
        ├── 1:1 ── shippers
        ├── 1:N ── restaurants
        └── 1:N ── orders

restaurants ── 1:N ── foods
orders ── 1:N ── order_items
orders ── N:1 ── shippers
```

### Q4.4: Tại sao em gộp 3 vai trò người dùng vào 1 bảng `users`?
**Trả lời:** Vì 3 vai trò có chung các thông tin cơ bản (tên, email, phone, uid). Em dùng trường `role` (enum: USER / RESTAURANT / SHIPPER) để phân biệt. Thông tin đặc thù như "biển số xe" của shipper được lưu ở bảng riêng `shippers` liên kết với `users`.

### Q4.5: Vì sao tiền được lưu kiểu `Decimal` mà không phải `Float`?
**Trả lời:** Float (số thực) bị sai số khi cộng/nhân (ví dụ `0.1 + 0.2 = 0.30000000000000004`). Tiền tệ cần chính xác tuyệt đối nên dùng `Decimal`.

### Q4.6: Trạng thái đơn hàng có những giá trị nào?
**Trả lời:** Em định nghĩa enum gồm 5 trạng thái:
- **PENDING**: vừa đặt, chưa được nhà hàng xác nhận.
- **CONFIRMED**: nhà hàng đã xác nhận.
- **DELIVERING**: đang giao (shipper đã lấy hàng).
- **COMPLETED**: đã hoàn thành.
- **CANCELLED**: đã huỷ.

### Q4.7: Khi nhà hàng đổi giá món, đơn cũ có bị thay đổi giá theo không?
**Trả lời:** **Không.** Vì khi tạo đơn, em đã sao chép (snapshot) giá món vào `order_items.price`. Đổi giá ở `foods.price` chỉ ảnh hưởng đơn mới sau đó.

---

## 5. CÂU HỎI VỀ XÁC THỰC & PHÂN QUYỀN

### Q5.1: Người dùng đăng nhập bằng cách nào?
**Trả lời:** Hệ thống hỗ trợ 3 cách:
1. **Email + Mật khẩu** (qua Firebase Auth).
2. **Google Sign-In**.
3. **Số điện thoại + OTP** (qua Firebase Phone Auth, gửi SMS).

Ngoài ra, khi đăng ký mới có thêm bước **OTP qua email** để xác minh email.

### Q5.2: Sau khi đăng nhập, hệ thống nhận biết user qua đâu?
**Trả lời:** Sau khi đăng nhập, Firebase trả về một **ID Token** (dạng JWT). Token này:
- Được lưu vào **flutter_secure_storage** (mã hoá ở thiết bị).
- Mỗi request đến backend đính kèm trong header `Authorization: Bearer <token>`.
- Backend gọi Firebase Admin SDK verify token → lấy `uid` → tra DB lấy user.

### Q5.3: JWT là gì? Vì sao dùng?
**Trả lời:** **JWT (JSON Web Token)** là một chuỗi token có chữ ký số, chứa thông tin user (vd `uid`). Lợi ích:
- Backend có thể verify chữ ký mà không cần lưu session ở server.
- Tự động hết hạn sau 1 giờ.
- Không cần truyền password mỗi request.

### Q5.4: Phân biệt Authentication và Authorization?
**Trả lời:**
- **Authentication (xác thực)**: trả lời câu hỏi "Bạn là ai?" — verify token.
- **Authorization (phân quyền)**: trả lời câu hỏi "Bạn được phép làm gì?" — kiểm tra role.

Trong project, em có 2 middleware tách biệt: `authenticate` (xác thực) và `authorize([roles])` (phân quyền).

### Q5.5: Làm sao biết user là USER, RESTAURANT hay SHIPPER?
**Trả lời:** Trong bảng `users` có trường `role` (enum). Sau khi authenticate xong, backend đã có `req.user.role`, dùng để kiểm tra ở middleware `authorize`.

### Q5.6: Tại sao chọn Firebase Auth mà không tự build hệ thống auth?
**Trả lời:**
- Firebase đã xử lý sẵn: refresh token, hết hạn, reset password, gửi SMS OTP.
- Không phải lưu password ở DB của mình → giảm rủi ro lộ password.
- Tích hợp Google Sign-In có sẵn.

---

## 6. CÂU HỎI VỀ CÁC CHỨC NĂNG CHÍNH

### Q6.1: Mô tả ngắn gọn luồng đặt hàng?
**Trả lời:**
1. **User** chọn món → thêm vào giỏ hàng.
2. Tại trang giỏ hàng → chọn địa chỉ giao + phương thức thanh toán → bấm "Đặt".
3. Backend tạo đơn với trạng thái `PENDING`, tính phí ship theo khoảng cách.
4. **Nhà hàng** thấy đơn → xác nhận → chuẩn bị xong.
5. **Shipper** thấy đơn (qua realtime) → nhận đơn → lấy hàng → giao.
6. Đơn chuyển sang `COMPLETED`.

### Q6.2: Giỏ hàng được lưu ở đâu?
**Trả lời:** Lưu ở **database** (bảng `cart_items`), không lưu local. Lý do: đồng bộ giữa nhiều thiết bị, không mất khi user log out / cài lại app.

### Q6.3: Chức năng "yêu thích" hoạt động ra sao?
**Trả lời:** Bảng `favorites` có cặp `(user_uid, food_id)` là unique — đảm bảo một user chỉ favorite một món 1 lần. Khi bấm tim, hệ thống toggle: nếu đã có thì xoá, chưa có thì thêm.

### Q6.4: Món ăn có thể có nhiều tuỳ chọn (size, topping) — em xử lý thế nào?
**Trả lời:** Em dùng 3 bảng:
- `foods` — món chính.
- `food_option_groups` — nhóm tuỳ chọn (vd "Size", "Topping"), có loại SINGLE (chọn 1) hoặc MULTIPLE (chọn nhiều).
- `food_options` — từng option cụ thể (vd S/M/L), mỗi option có giá phụ thu.

Khi đặt đơn, các option được sao chép vào `order_items.selected_options` (kiểu JSON) để giữ nguyên giá tại thời điểm đặt.

### Q6.5: Tìm kiếm nhà hàng / món hoạt động như thế nào?
**Trả lời:** Em dùng `ILIKE` của PostgreSQL (so khớp không phân biệt hoa thường) qua Prisma:
```js
prisma.foods.findMany({ where: { name: { contains: query, mode: 'insensitive' } } })
```
Đủ dùng với lượng dữ liệu của đồ án.

### Q6.6: Upload ảnh món / avatar hoạt động ra sao?
**Trả lời:**
1. User chọn ảnh bằng `image_picker`.
2. Ảnh được upload lên **Supabase Storage** (bucket `images`).
3. Supabase trả về URL public.
4. URL được gửi cho backend lưu vào DB (`avatar_url`, `image_url`).

### Q6.7: Có những vai trò nào được thực hiện thao tác gì trên đơn?
**Trả lời:**
| Vai trò | Thao tác |
|---|---|
| **USER** | Tạo đơn, huỷ đơn |
| **RESTAURANT** | Xác nhận đơn, đánh dấu đã chuẩn bị xong |
| **SHIPPER** | Nhận đơn, lấy hàng, hoàn thành, cập nhật GPS |

---

## 7. CÂU HỎI VỀ REALTIME

### Q7.1: Realtime trong project hoạt động ra sao?
**Trả lời:** Em dùng **Supabase Realtime** — cơ chế là PostgreSQL ghi nhận thay đổi, đẩy ra qua **WebSocket** cho client:
1. Client kết nối WebSocket và đăng ký (subscribe) bảng `orders`.
2. Mỗi khi có INSERT/UPDATE/DELETE trên bảng `orders`, Supabase đẩy thông báo về client.
3. Client cập nhật UI ngay lập tức (không cần refresh).

### Q7.2: Tại sao dùng Realtime mà không gọi API định kỳ (polling)?
**Trả lời:**
- **Polling** tốn băng thông (gọi nhiều lần kể cả không có thay đổi), độ trễ ít nhất bằng interval.
- **Realtime (WebSocket)** chỉ gửi khi có sự kiện, độ trễ rất thấp.

### Q7.3: WebSocket khác HTTP như thế nào?
**Trả lời:**
- **HTTP**: client phải gửi request mới nhận được response (1 lần / request).
- **WebSocket**: kết nối 2 chiều, persistent — server có thể chủ động đẩy dữ liệu xuống client bất cứ lúc nào.

### Q7.4: Realtime của em đang theo dõi bảng nào?
**Trả lời:** Bảng `orders`. Khi đơn được tạo / cập nhật trạng thái → tất cả client liên quan (user, nhà hàng, shipper) đều được thông báo ngay.

### Q7.5: Có chức năng push notification không?
**Trả lời:** Hiện tại chỉ có **in-app notification** (hiển thị toast trong app khi nhận realtime). Chưa tích hợp push notification cho khi app đóng (cần FCM - Firebase Cloud Messaging) — đây là hướng mở rộng.

---

## 8. CÂU HỎI VỀ BẢN ĐỒ & VỊ TRÍ

### Q8.1: Em dùng bản đồ gì?
**Trả lời:** **OpenStreetMap** (qua package `flutter_map`). Lý do: miễn phí, không cần API key như Google Maps.

### Q8.2: Tính khoảng cách giữa 2 điểm như thế nào?
**Trả lời:** Em dùng **công thức Haversine** — tính khoảng cách giữa 2 điểm trên mặt cầu (Trái Đất). Đây là khoảng cách "đường chim bay", không phải khoảng cách đường thật.

### Q8.3: Em dùng Haversine để làm gì?
**Trả lời:** 2 mục đích:
1. **Tính phí ship**: phí = max($1, khoảng cách * $1/km).
2. **Lọc đơn cho shipper**: chỉ hiện đơn trong bán kính **15km** từ vị trí shipper.

### Q8.4: Vị trí của user / shipper lấy từ đâu?
**Trả lời:** Lấy từ **GPS điện thoại** qua package `geolocator`:
- Xin quyền truy cập vị trí.
- Gọi `getCurrentPosition()` → trả về `LatLng`.
- Shipper định kỳ gửi vị trí về backend để user thấy được vị trí đang giao.

### Q8.5: Em tìm địa chỉ (vd "123 Lê Lợi") như thế nào?
**Trả lời:** Dùng **Nominatim** — dịch vụ geocoding miễn phí của OpenStreetMap. Người dùng gõ tên đường → Nominatim trả về danh sách kết quả kèm toạ độ.

---

## 9. CÂU HỎI VỀ FLUTTER

### Q9.1: State management trong app em dùng gì?
**Trả lời:** Em dùng **Provider** (theo pattern ChangeNotifier). Đây là pattern chính thức Flutter team khuyên dùng, đơn giản và đủ cho quy mô đồ án.

### Q9.2: Các provider chính trong app?
**Trả lời:**
- `CartProvider` — giỏ hàng.
- `FavoriteProvider` — yêu thích.
- `UserAddressProvider` — địa chỉ đang chọn.
- `OrderRealtimeProvider` — danh sách đơn realtime.
- `ThemeProvider` — dark/light mode.

### Q9.3: Vì sao không dùng Bloc / Riverpod?
**Trả lời:**
- **Bloc**: nhiều boilerplate, phù hợp app rất lớn.
- **Riverpod**: API hơi lạ với người mới.
- **Provider**: đơn giản, đủ dùng. Em ưu tiên dễ đọc.

### Q9.4: Hot Reload là gì?
**Trả lời:** Là tính năng giúp khi sửa code Dart, app cập nhật ngay trên thiết bị mà không phải build lại — giúp lập trình nhanh hơn rất nhiều.

### Q9.5: Cross-platform của Flutter có ưu điểm gì?
**Trả lời:** 1 codebase chạy được cả Android và iOS — tiết kiệm khoảng 50% thời gian so với viết native riêng cho từng nền tảng.

---

## 10. CÂU HỎI MỞ / NHẬN XÉT CHUNG

### Q10.1: Hệ thống của em deploy ở đâu?
**Trả lời:**
- **Backend**: deploy trên **AWS EC2** (IP `54.254.237.65:3000`).
- **Database + Realtime + Storage**: chạy trên cloud của **Supabase**.
- **App mobile**: build APK / IPA thủ công, chưa publish lên CH Play / App Store.

### Q10.2: Hệ thống có an toàn (security) không?
**Trả lời:** Có các lớp bảo vệ cơ bản:
1. **Xác thực**: token Firebase được verify ở backend, client không thể giả mạo.
2. **Phân quyền**: middleware kiểm tra role trước mỗi API quan trọng.
3. **Chống SQL Injection**: Prisma dùng parameterized query mặc định.
4. **Token lưu mã hoá**: dùng `flutter_secure_storage` (Keystore / Keychain).

### Q10.3: Hệ thống còn gì chưa làm được?
**Trả lời:**
- Chưa có **thanh toán online** (VNPay, Momo) — hiện chỉ COD.
- Chưa có **đánh giá / review** đầy đủ cho món và shipper.
- Chưa có **push notification** khi app đóng.
- Chưa có **admin dashboard web**.
- Chưa có **chat** giữa user và shipper.
- Chưa viết **test tự động**.

### Q10.4: Hướng phát triển tiếp theo?
**Trả lời:**
1. Tích hợp thanh toán online.
2. Thêm push notification (FCM).
3. Làm trang admin web cho quản trị.
4. Thêm chat user - shipper.
5. Tối ưu thuật toán phân phối đơn cho shipper.
6. Viết unit test + integration test.

### Q10.5: Nếu có nhiều user cùng dùng, hệ thống có chịu được không?
**Trả lời:** Với quy mô MVP em đang chạy thì OK. Nếu lên hàng nghìn / triệu user thì cần:
- Tăng số instance backend (load balancer).
- Tăng connection pool của DB.
- Thêm cache (Redis) cho data đọc nhiều.
- CDN cho ảnh.

### Q10.6: Em học được gì sau đồ án này?
**Trả lời:**
- Cách thiết kế kiến trúc client - server tách biệt rõ ràng.
- Hiểu sâu hơn về realtime và sự khác biệt với polling.
- Hiểu về authentication / authorization, JWT.
- Cách phối hợp nhiều dịch vụ (Firebase + Supabase + EC2).
- Trade-off giữa "làm nhanh" và "làm chỉn chu" — biết được mình cần cải thiện gì cho production.

### Q10.7: Vì sao em chọn kiến trúc này mà không dùng monolith hoặc microservice?
**Trả lời:**
- **Microservice**: phức tạp, cần nhiều service riêng — quá tải so với quy mô đồ án.
- **Monolith** (như em làm): 1 backend duy nhất, dễ phát triển nhanh, đủ tốt cho MVP.
- Khi hệ thống lớn lên có thể tách dần thành các service nhỏ.

### Q10.8: Em nghĩ điểm mạnh nhất của project là gì?
**Trả lời:** Em nghĩ là **luồng đặt đơn end-to-end thực tế** — từ lúc user thêm giỏ, đặt đơn, nhà hàng xác nhận, shipper nhận đơn và giao — đều được hiện thực hoá đầy đủ với realtime update. Đó là phần em đầu tư nhiều nhất và phản ánh đúng nghiệp vụ một app delivery thực sự.

---

## PHỤ LỤC: BỘ THUẬT NGỮ NỀN TẢNG

| Thuật ngữ | Ý nghĩa ngắn gọn |
|---|---|
| **Client - Server** | Mô hình ứng dụng tách biệt phần giao diện (client) và phần xử lý (server). |
| **REST API** | Quy ước giao tiếp client - server qua HTTP, dùng method (GET/POST/PATCH/DELETE) + đường dẫn tài nguyên. |
| **JWT** | JSON Web Token — token có chữ ký, mang thông tin user. |
| **ORM** | Object-Relational Mapping — công cụ ánh xạ giữa class trong code và bảng trong DB. |
| **Middleware** | Hàm xử lý request trước khi đến controller (vd xác thực, log). |
| **WebSocket** | Giao thức kết nối 2 chiều persistent — khác HTTP chỉ request/response 1 lần. |
| **Realtime** | Khả năng server đẩy dữ liệu mới về client ngay khi có thay đổi. |
| **Haversine** | Công thức tính khoảng cách giữa 2 điểm trên mặt cầu (đường chim bay). |
| **Provider (Flutter)** | Pattern quản lý state, dùng `ChangeNotifier`. |
| **Hot Reload** | Tính năng Flutter giúp xem thay đổi UI ngay không cần restart app. |
| **Migration** | File thay đổi schema database, áp dụng theo thứ tự. |
| **CRUD** | Create - Read - Update - Delete: 4 thao tác cơ bản với dữ liệu. |
| **Token** | Chuỗi xác thực mà client gửi kèm mỗi request để chứng minh danh tính. |
| **Backend-as-a-Service** | Dịch vụ cung cấp sẵn DB, auth, storage qua cloud (vd Firebase, Supabase). |

---

> **MẸO TRẢ LỜI:**
> 1. **Hiểu bản chất** quan trọng hơn học thuộc.
> 2. Câu nào không chắc → trả lời theo hiểu biết + nói thêm "thầy cô có thể bổ sung giúp em".
> 3. Khi nói về điểm yếu của project → luôn kèm "hướng cải thiện".
> 4. Vẽ sơ đồ ra giấy / bảng nếu được — luôn ấn tượng hơn nói suông.
> 5. Trả lời ngắn gọn 30-60 giây cho 1 câu, không lan man.
> 6. Đừng dùng thuật ngữ mình không hiểu — nếu không chắc, hãy diễn đạt bằng từ đơn giản hơn.
