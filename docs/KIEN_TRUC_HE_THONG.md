# TÀI LIỆU KIẾN TRÚC HỆ THỐNG
## Ứng dụng giao đồ ăn (Delivery Apps)

> Tài liệu mô tả chi tiết kiến trúc tổng thể của hệ thống ứng dụng giao đồ ăn, bao gồm: kiến trúc tổng thể, cấu trúc client, cấu trúc backend, cơ sở dữ liệu, luồng giao tiếp, bảo mật và các dịch vụ ngoài.

---

## MỤC LỤC
1. [Tổng quan hệ thống](#1-tổng-quan-hệ-thống)
2. [Kiến trúc tổng thể (High-level Architecture)](#2-kiến-trúc-tổng-thể-high-level-architecture)
3. [Kiến trúc Client (Flutter)](#3-kiến-trúc-client-flutter)
4. [Kiến trúc Backend (Node.js + Express)](#4-kiến-trúc-backend-nodejs--express)
5. [Cơ sở dữ liệu](#5-cơ-sở-dữ-liệu)
6. [Luồng xác thực & phân quyền](#6-luồng-xác-thực--phân-quyền)
7. [Luồng giao tiếp client - server](#7-luồng-giao-tiếp-client---server)
8. [Realtime & Notification](#8-realtime--notification)
9. [Lưu trữ ảnh (Storage)](#9-lưu-trữ-ảnh-storage)
10. [Triển khai (Deployment)](#10-triển-khai-deployment)
11. [Tổng kết các dịch vụ ngoài](#11-tổng-kết-các-dịch-vụ-ngoài)

---

## 1. TỔNG QUAN HỆ THỐNG

Hệ thống là một ứng dụng giao đồ ăn (food delivery) mobile chạy trên Android/iOS, gồm **3 vai trò người dùng (role)** trên cùng một codebase:

| Role | Quyền và chức năng chính |
|---|---|
| **USER** | Tìm kiếm nhà hàng/món, đặt món, theo dõi đơn, đánh giá |
| **RESTAURANT** | Quản lý menu, xác nhận/chuẩn bị đơn, theo dõi doanh thu |
| **SHIPPER** | Nhận đơn trong bán kính 15km, cập nhật GPS, hoàn thành đơn |

Toàn bộ hệ thống hoạt động trên mô hình **Client - Server tách biệt**, dữ liệu lưu tập trung trên cloud, đồng bộ realtime qua WebSocket.

---

## 2. KIẾN TRÚC TỔNG THỂ (HIGH-LEVEL ARCHITECTURE)

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          CLIENT (Flutter App)                            │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────┐    │
│  │ Feature USER     │  │ Feature SHIPPER  │  │ Feature RESTAURANT   │    │
│  └────────┬─────────┘  └────────┬─────────┘  └──────────┬───────────┘    │
│           │                     │                       │                │
│           └─────────────────────┼───────────────────────┘                │
│                                 │                                        │
│  ┌──────────────────────────────▼───────────────────────────────────┐    │
│  │            CORE (services, providers, models, router)            │    │
│  │  - BackendService (HTTP client)                                  │    │
│  │  - SupabaseService (Realtime + Storage)                          │    │
│  │  - FirebaseAuthService (Auth SDK)                                │    │
│  │  - Providers (Cart, Favorite, Address, OrderRealtime, Theme)     │    │
│  └────────────┬───────────────────┬────────────────────┬─────────────┘    │
└───────────────┼───────────────────┼────────────────────┼─────────────────┘
                │                   │                    │
       HTTPS / REST           WebSocket /         HTTPS (file upload
       (JSON + Bearer)        Realtime channel    + getPublicUrl)
                │                   │                    │
┌───────────────▼─────────────┐ ┌──▼────────────────┐ ┌─▼────────────────┐
│  BACKEND (Node.js+Express)  │ │ Supabase Realtime │ │ Supabase Storage │
│  EC2 — IP 54.254.237.65:3000│ │ (Postgres LR/WS)  │ │ Bucket "images"  │
│                             │ └──────┬────────────┘ └──────────────────┘
│  Middleware:                │        │
│  - authenticate (verify     │        │
│    Firebase ID Token)       │        │
│  - authorize([roles])       │        │
│                             │        │
│  Controllers (MVC):         │        │
│  - auth, orders, foods,     │        │
│    shippers, restaurants,   │        │
│    cart, favorites, ...     │        │
│                             │        │
│  ORM: Prisma Client         │        │
└──────────────┬──────────────┘        │
               │                       │
               ▼                       ▼
┌────────────────────────────────────────────────────────────────┐
│      Supabase Postgres (Cloud) — Single source of truth        │
│  Tables: users, restaurants, foods, orders, order_items,       │
│          shippers, addresses, cart_items, favorites,           │
│          categories, food_option_groups, food_options          │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│              External services (chỉ liên quan đến client)      │
│  - Firebase Auth   (Phone OTP, Google Sign-In, Email/Password) │
│  - OpenStreetMap   (tile map + Nominatim search địa chỉ)       │
│  - Nodemailer SMTP (gửi OTP qua Gmail, gọi từ backend)         │
└────────────────────────────────────────────────────────────────┘
```

### Đặc điểm chính

1. **Single backend, single database** — toàn bộ business logic đặt trên Node.js, dữ liệu lưu trên Postgres của Supabase.
2. **Client làm việc với 3 lớp hạ tầng**:
   - Backend REST API (đặt hàng, lấy dữ liệu, cập nhật trạng thái).
   - Supabase Realtime (lắng nghe thay đổi bảng `orders`).
   - Supabase Storage (upload ảnh, lấy public URL).
3. **Xác thực**: dùng Firebase ID Token (JWT), được verify ở server qua Firebase Admin SDK.
4. **Phân quyền**: middleware ở backend kiểm tra role được lưu trong DB.

---

## 3. KIẾN TRÚC CLIENT (FLUTTER)

### 3.1. Tổ chức thư mục

Tổ chức theo nguyên tắc **Feature-First** (module hoá theo nghiệp vụ thay vì theo lớp):

```
lib/
├── main.dart                  ← entry point, khởi tạo Firebase + Supabase
├── core/                      ← phần dùng chung cho mọi feature
│   ├── common/                ← màu sắc, util chung
│   ├── constants/             ← hằng số (endpoint, key, role)
│   ├── models/                ← data class (UserModel, OrderModel, ...)
│   ├── providers/             ← ChangeNotifier dùng chung (theme, realtime)
│   ├── router/                ← AppRouter, AuthGuard
│   ├── services/              ← BackendService, SupabaseService,
│   │                            FirebaseAuthService, AuthRepository
│   └── widgets/               ← widget tái sử dụng
└── features/
    ├── user/
    │   ├── home/              ← màn hình chính, danh mục, restaurant
    │   ├── cart/              ← giỏ hàng + provider
    │   ├── favorites/         ← yêu thích + provider
    │   ├── order/             ← đặt đơn, theo dõi đơn
    │   └── profile/           ← đăng nhập, đăng ký, profile
    ├── restaurant/
    │   ├── screen/            ← dashboard, quản lý món, đơn hàng
    │   └── widget/
    └── shipper/
        ├── screen/            ← dashboard, đơn khả dụng, đang giao
        └── widget/
```

### 3.2. Các tầng (Layer) trong client

```
┌─────────────────────────────────────────────────────┐
│  Presentation Layer (Screen + Widget)               │
│  - Stateless/Stateful widget                        │
│  - Sử dụng context.watch / Consumer<Provider>       │
└────────────────────────┬────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────┐
│  State Management Layer (Provider — ChangeNotifier) │
│  - CartProvider, FavoriteProvider                   │
│  - UserAddressProvider, OrderRealtimeProvider       │
│  - ThemeProvider                                    │
└────────────────────────┬────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────┐
│  Service Layer                                      │
│  - BackendService (singleton, gọi HTTP REST)        │
│  - SupabaseService (Realtime + Storage)             │
│  - FirebaseAuthService (gọi Firebase SDK)           │
│  - AuthRepository (lưu token vào secure storage)    │
└────────────────────────┬────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────┐
│  Data / Model Layer                                 │
│  - Data class với fromJson/toJson                   │
└─────────────────────────────────────────────────────┘
```

### 3.3. State Management — Provider

Dùng pattern **ChangeNotifier + Provider** với `MultiProvider` gắn ở `MyApp`:

```dart
MultiProvider(providers: [
  ChangeNotifierProvider(create: (_) => UserAddressProvider()),
  ChangeNotifierProvider(create: (_) => CartProvider()),
  ChangeNotifierProvider(create: (_) => FavoriteProvider()),
  ChangeNotifierProvider(create: (_) => OrderRealtimeProvider()),
])
```

| Provider | Vai trò |
|---|---|
| `UserAddressProvider` | Địa chỉ giao hàng đang chọn |
| `CartProvider` | Giỏ hàng (đồng bộ với backend `/api/cart`) |
| `FavoriteProvider` | Danh sách món yêu thích |
| `OrderRealtimeProvider` | Danh sách đơn, cập nhật realtime từ Supabase |
| `ThemeProvider` | Dark/Light mode |

### 3.4. Routing

- Dùng **`Navigator.pushReplacement`** trực tiếp (không dùng `go_router` cho điều hướng chính dù package có sẵn).
- Class `AppRouter.routeAfterLogin()` chịu trách nhiệm điều hướng theo role:
  - `USER` → `MainScreen`
  - `RESTAURANT` → `RestaurantMainScreen`
  - `SHIPPER` → `ShipperMainScreen`

---

## 4. KIẾN TRÚC BACKEND (NODE.JS + EXPRESS)

### 4.1. Tổ chức thư mục

```
backend/
├── package.json
├── prisma/
│   ├── schema.prisma         ← định nghĩa data model
│   ├── migrations/           ← file SQL migration
│   └── seed.js
└── src/
    ├── server.js             ← entry point, mount router
    ├── config/
    │   ├── prisma.js         ← export Prisma Client instance
    │   ├── supabase.js       ← Supabase Admin client (nếu cần)
    │   └── mailer.js         ← Nodemailer transporter
    ├── middleware/
    │   └── auth.js           ← authenticate + authorize
    ├── routers/              ← khai báo route + middleware
    └── controllers/          ← logic xử lý nghiệp vụ
```

### 4.2. Mô hình tổ chức code — Pattern MVC biến thể

```
Request
   │
   ▼
┌─────────────────────┐
│  Router             │   ← định nghĩa URL, gắn middleware
│  (express.Router)   │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Middleware:        │   ← authenticate (verify token)
│  authenticate +     │   ← authorize([roles]) (check role)
│  authorize          │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Controller         │   ← business logic
│  (function async)   │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Prisma Client      │   ← ORM query DB
│  (Model layer)      │
└─────────┬───────────┘
          │
          ▼
   Postgres (Supabase)
```

### 4.3. Danh sách endpoint chính

| Resource | Endpoint prefix | Vai trò |
|---|---|---|
| Auth | `/api/auth` | OTP (gửi/verify cho email), đăng nhập, lấy `/me` |
| User | `/api/user` | Tạo user, lấy/sửa profile |
| Foods | `/api/foods` | CRUD món ăn (RESTAURANT) + đọc (USER) |
| Restaurants | `/api/restaurants` | Đăng ký NH, lấy profile NH, đổi trạng thái mở/đóng |
| Orders | `/api/orders` | Tạo đơn, các thao tác chuyển trạng thái theo role |
| Shippers | `/api/shippers` | Đăng ký shipper, lấy profile, dashboard |
| Categories | `/api/categories` | Danh mục món ăn |
| Addresses | `/api/addresses` | Quản lý địa chỉ giao hàng |
| Cart | `/api/cart` | Giỏ hàng (đồng bộ với DB) |
| Favorites | `/api/favorites` | Toggle món yêu thích |
| Search | `/api/search` | Tìm món, tìm nhà hàng theo món |

### 4.4. Middleware

**`authenticate`** (`src/middleware/auth.js`):
1. Đọc header `Authorization: Bearer <id_token>`.
2. Gọi `admin.auth().verifyIdToken(idToken)` → trả về `uid`.
3. Query DB lấy user theo `uid` → gắn `{id, uid, role}` vào `req.user`.

**`authorize(roles)`**:
- Trả về middleware kiểm tra `req.user.role ∈ roles`. Sai → 403.

Cách dùng:
```js
router.post('/', authenticate, authorize(['USER']), createOrder);
router.patch('/:id/accept', authenticate, authorize(['SHIPPER']), acceptOrder);
```

### 4.5. Middlewares toàn cục (ở `server.js`)
- `express.json()` — parse body JSON.
- CORS middleware tự viết — cho phép tất cả origin (development).
- Request logging — log mỗi request kèm timestamp.
- 404 handler.
- Global error handler — log + trả về `{error, stack}` (stack chỉ ở `NODE_ENV=development`).

---

## 5. CƠ SỞ DỮ LIỆU

### 5.1. Hệ quản trị
- **PostgreSQL** chạy trên **Supabase Cloud**.
- Backend dùng **Prisma ORM 5** (type-safe, migration tự động).
- Kết nối qua 2 URL: `DATABASE_URL` (pooled) và `DIRECT_URL` (cho migration).

### 5.2. Sơ đồ ER (Entity Relationship) — rút gọn

```
                ┌──────────┐
                │  users   │
                └────┬─────┘
                     │ 1
       ┌─────────────┼──────────────┬──────────────┬─────────────┐
       │             │              │              │             │
       │ N           │ 1:1          │ N            │ N           │ N
       ▼             ▼              ▼              ▼             ▼
  ┌─────────┐  ┌─────────┐   ┌─────────────┐  ┌─────────┐  ┌─────────┐
  │addresses│  │shippers │   │ restaurants │  │ orders  │  │favorites│
  └─────────┘  └─────────┘   └──────┬──────┘  └────┬────┘  └─────────┘
                                    │ 1            │ 1
                                    │              │
                                    │ N            │ N
                                    ▼              ▼
                               ┌─────────┐   ┌─────────────┐
                               │  foods  │   │ order_items │
                               └────┬────┘   └─────────────┘
                                    │ 1
                                    │ N
                                    ▼
                          ┌─────────────────────┐
                          │ food_option_groups  │
                          └──────────┬──────────┘
                                     │ 1
                                     │ N
                                     ▼
                              ┌──────────────┐
                              │ food_options │
                              └──────────────┘
```

### 5.3. Mô tả các bảng chính

| Bảng | Mục đích | Khoá quan trọng |
|---|---|---|
| `users` | Tài khoản người dùng (cả 3 role) | `id`, `uid` (Firebase UID), `email` |
| `addresses` | Địa chỉ giao của user | `user_uid` (FK) |
| `shippers` | Profile mở rộng của tài xế | `user_uid` (FK, unique), `license_plate` (unique) |
| `restaurants` | Profile nhà hàng | `user_uid` (FK), `latitude/longitude` |
| `foods` | Món ăn | `restaurant_id`, `category_id`, `price` (Decimal 10,2) |
| `food_option_groups` | Nhóm option của món (size, topping...) | `food_id`, `selection_type` (SINGLE/MULTIPLE) |
| `food_options` | Từng option cụ thể | `group_id`, `price` |
| `orders` | Đơn hàng | `user_uid`, `restaurant_id`, `shipper_id`, `status` (enum) |
| `order_items` | Chi tiết món trong đơn | `order_id`, `food_id`, `selected_options` (JSON) |
| `cart_items` | Giỏ hàng (lưu DB, không phải local) | `user_uid`, `food_id`, `restaurant_id` |
| `favorites` | Món yêu thích | `(user_uid, food_id)` unique |
| `categories` | Danh mục món | `name` unique |

### 5.4. Các enum

```prisma
enum user_role     { USER, RESTAURANT, SHIPPER }
enum order_status  { PENDING, CONFIRMED, DELIVERING, COMPLETED, CANCELLED }
enum selection_type { SINGLE, MULTIPLE }
```

### 5.5. Quyết định thiết kế nổi bật

- **`uid` (String Firebase UID)** làm foreign key, không phải `id` auto-increment — vì khi xác thực token đã có sẵn `uid`, không cần query thêm để lấy `id`.
- **`Decimal(10,2)`** cho tiền — không dùng `Float` để tránh sai số.
- **`selected_options` lưu JSON** — snapshot giá option tại thời điểm đặt, không ảnh hưởng đơn cũ khi nhà hàng đổi giá.
- **Cart lưu trong DB** (không local) — đảm bảo đồng bộ giữa nhiều thiết bị.

---

## 6. LUỒNG XÁC THỰC & PHÂN QUYỀN

### 6.1. Sơ đồ luồng xác thực

```
┌─────────────┐                                ┌───────────────┐
│   Flutter   │                                │ Firebase Auth │
│   Client    │                                │   (Cloud)     │
└──────┬──────┘                                └───────┬───────┘
       │  1. signIn(email,password) / Google / Phone   │
       │ ────────────────────────────────────────────► │
       │                                               │
       │  2. trả User + ID Token (JWT, sống 1h)        │
       │ ◄──────────────────────────────────────────── │
       │
       │  3. Lưu token vào flutter_secure_storage
       │     (Keystore Android / Keychain iOS)
       │
       │  4. Mỗi request kèm                  ┌─────────────────┐
       │     "Authorization: Bearer <token>"  │     Backend     │
       │ ───────────────────────────────────► │   (Node.js)     │
       │                                      └────────┬────────┘
       │                                               │ 5. verifyIdToken()
       │                                               │ ────────► Firebase Admin
       │                                               │ ◄──────── trả uid
       │                                               │
       │                                               │ 6. prisma.users.findUnique
       │                                               │    by uid → req.user
       │                                               │
       │                                               │ 7. authorize check role
       │                                               │
       │                                               │ 8. controller chạy logic
       │  9. JSON response                             │
       │ ◄──────────────────────────────────────────── │
```

### 6.2. Các phương thức đăng nhập / đăng ký

| Phương thức | Cách hoạt động |
|---|---|
| **Email + Password** | Firebase Auth `createUserWithEmailAndPassword` / `signInWithEmailAndPassword` |
| **Google Sign-In** | `google_sign_in` lấy idToken → đưa cho Firebase |
| **Phone OTP** | `verifyPhoneNumber` (Firebase gửi SMS) — chủ yếu để link số phone vào tài khoản |
| **Pre-register Email OTP** | Backend gửi OTP qua Nodemailer (Gmail SMTP), lưu OTP tạm trong RAM (Map), expire 5 phút |

### 6.3. Phân quyền

- Server đọc `req.user.role` (đã lấy từ DB sau khi verify token).
- Mỗi route gắn middleware `authorize(['USER'])`, `authorize(['SHIPPER'])`, `authorize(['RESTAURANT', 'ADMIN'])`...

---

## 7. LUỒNG GIAO TIẾP CLIENT - SERVER

### 7.1. Giao thức
- **HTTP/1.1 + JSON** (REST API).
- Endpoint backend: `http://54.254.237.65:3000/api/...`
- Mọi response thành công trả `200 OK` (hoặc `201` cho create), JSON body.
- Lỗi → status `4xx/5xx`, body `{ "error": "<message>" }`.

### 7.2. Ví dụ luồng đặt hàng

```
USER → Flutter:
  - Chọn món, thêm option → CartProvider.addToCart()
  - POST /api/cart                      (lưu cart vào DB)

Tại trang Checkout:
  - Bấm "Đặt hàng"
  - POST /api/orders {restaurant_id, items[], address, lat, lng, payment_method}

BACKEND:
  - authenticate → authorize(['USER'])
  - Loop items → lấy giá thật từ DB (chống fake giá)
  - Cộng giá option
  - Tính delivery_fee = max(1, round(haversine(...) * 10) / 10)
  - prisma.orders.create({...,  order_items: { create: [...] }})  ← nested write
  - Trả order với status PENDING

SUPABASE REALTIME:
  - Postgres ghi nhận INSERT row mới
  - Logical Replication push WAL → Supabase Realtime
  - Tất cả client đang subscribe channel "public/orders" nhận payload

SHIPPER online:
  - OrderRealtimeProvider._handlePayload() → đẩy order vào list
  - UI rebuild → shipper thấy đơn mới
  - Bấm Nhận → PATCH /api/orders/:id/accept
    - Backend check race: nếu status != CONFIRMED hoặc shipper_id != null → 409
    - Update shipper_id

RESTAURANT:
  - PATCH /api/orders/:id/confirm  (CONFIRMED)
  - PATCH /api/orders/:id/ready    (DELIVERING)

SHIPPER:
  - PATCH /api/orders/:id/location  (gửi GPS định kỳ)
  - PATCH /api/orders/:id/complete  (COMPLETED)
```

---

## 8. REALTIME & NOTIFICATION

### 8.1. Cơ chế Supabase Realtime

Bản chất: **PostgreSQL Logical Replication → WebSocket**.

```
   Backend (Prisma)
        │
        │ INSERT / UPDATE / DELETE
        ▼
   Postgres (Supabase)
        │
        │ ghi vào WAL (Write-Ahead Log)
        ▼
   Logical Replication slot
        │
        ▼
   Supabase Realtime server
        │
        │ WebSocket push payload {eventType, new, old}
        ▼
   Flutter clients (đang subscribe channel)
```

### 8.2. Subscribe ở client

`SupabaseService.subscribeOrders(...)`:

```dart
client.channel('public').onPostgresChanges(
  event: PostgresChangeEvent.all,
  schema: 'public',
  table: 'orders',
  callback: (payload) => onPayload({
    'eventType': payload.eventType.name,
    'new': payload.newRecord,
    'old': payload.oldRecord,
  }),
).subscribe();
```

### 8.3. Reference counting (tránh leak channel)

`OrderRealtimeProvider`:
- Mỗi widget cần realtime gọi `subscribe()` (tăng `_refCount`).
- Khi dispose gọi `unsubscribe()` (giảm `_refCount`).
- Channel chỉ thực sự đóng khi `_refCount == 0`.

### 8.4. Notification trong app

- Widget `GlobalOrderNotification` (bọc toàn app trong `MaterialApp.builder`) hiển thị toast khi có payload mới.
- Hiện chưa tích hợp **FCM (Firebase Cloud Messaging)** để push notification khi app đóng.

---

## 9. LƯU TRỮ ẢNH (STORAGE)

### 9.1. Supabase Storage — Bucket `images`

Client gọi trực tiếp Supabase (không qua backend):

```dart
SupabaseService.uploadImage(file, fileName, folder: 'foods');
// 1. Upload file vào path: <folder>/<timestamp>_<fileName>
// 2. Lấy public URL
// 3. Trả URL cho backend lưu vào DB (avatar_url, image_url)
```

Các folder dùng:
- `foods/` — ảnh món ăn
- `restaurants/` — ảnh nhà hàng
- `avatars/` — avatar người dùng

### 9.2. Tại sao client gọi trực tiếp?
- Tiết kiệm băng thông backend (không phải proxy file).
- Supabase trả URL public ngay → backend chỉ cần lưu string URL.
- Anon key của Supabase được phép upload theo policy đã cấu hình.

---

## 10. TRIỂN KHAI (DEPLOYMENT)

| Thành phần | Nơi triển khai | Ghi chú |
|---|---|---|
| Backend Node.js | **AWS EC2** — `54.254.237.65:3000` | Dev: `nodemon`; Prod: `node src/server.js` |
| Postgres DB | **Supabase Cloud** | Có pooler (connection pooling) sẵn |
| Realtime | **Supabase Cloud** | Bật replication cho bảng `orders` |
| Storage | **Supabase Storage** | Bucket `images` public |
| Firebase Auth | **Firebase (Google Cloud)** | Project ID: `fooddelivery-f00aa` |
| Email SMTP | **Gmail SMTP** (Nodemailer) | EMAIL_USER/EMAIL_PASS từ .env |
| Map tile | **OpenStreetMap** | Không cần API key |
| Geocoding | **Nominatim (OSM)** | Endpoint public, có rate limit |
| Mobile app | Build APK / IPA thủ công | Chưa publish CH Play / App Store |

---

## 11. TỔNG KẾT CÁC DỊCH VỤ NGOÀI

```
┌────────────────────────────────────────────────────────────────────┐
│                            EXTERNAL SERVICES                       │
├──────────────────┬─────────────────────────────────────────────────┤
│ Firebase Auth    │ Xác thực: Email/Pass, Google, Phone OTP         │
│ Supabase DB      │ Lưu dữ liệu (Postgres)                          │
│ Supabase Realtime│ Đồng bộ trạng thái đơn (WebSocket)              │
│ Supabase Storage │ Lưu ảnh, trả public URL                         │
│ Nodemailer/Gmail │ Gửi OTP email khi đăng ký                       │
│ OpenStreetMap    │ Hiển thị bản đồ                                 │
│ Nominatim        │ Tìm địa chỉ theo từ khóa                        │
└──────────────────┴─────────────────────────────────────────────────┘
```

### Vì sao mix Firebase + Supabase?

| Yếu tố | Firebase | Supabase |
|---|---|---|
| Database | Firestore (NoSQL) — không tốt cho quan hệ đơn-món-option | Postgres quan hệ chặt |
| Auth | Phone OTP miễn phí, SDK Flutter ổn | Có nhưng cấu hình Phone phức tạp hơn |
| Realtime | Firestore listener | Postgres Logical Replication → WS |
| Storage | Firebase Storage | Supabase Storage |

→ **Firebase chỉ dùng cho Auth**, **Supabase dùng cho mọi thứ liên quan dữ liệu**.

---

## PHỤ LỤC: NGUYÊN TẮC TÍNH KHOẢNG CÁCH (HAVERSINE)

Công thức Haversine tính khoảng cách giữa 2 điểm trên mặt cầu (Trái Đất, R = 6371 km):

```
a = sin²(Δφ/2) + cos φ1 · cos φ2 · sin²(Δλ/2)
c = 2 · atan2(√a, √(1-a))
d = R · c
```

Dùng cho:
1. **Tính phí ship**: `delivery_fee = max(1, round(d_km * 10) / 10)`.
2. **Lọc đơn cho shipper**: chỉ trả đơn có `d_km ≤ 15`.

Hạn chế: khoảng cách đường chim bay, chưa tính lộ trình đường thật.

---

## PHỤ LỤC: THUẬT NGỮ

| Thuật ngữ | Ý nghĩa |
|---|---|
| **REST API** | Giao thức client-server qua HTTP với method + URL tài nguyên |
| **JWT / ID Token** | Token có chữ ký, mang `uid` của user |
| **ORM** | Object-Relational Mapping (Prisma) — map class với bảng DB |
| **Middleware** | Hàm xử lý request trước controller |
| **WebSocket** | Kết nối 2 chiều persistent, dùng cho realtime |
| **Haversine** | Công thức khoảng cách đường chim bay trên mặt cầu |
| **Race condition** | Lỗi do 2+ request thao tác 1 dữ liệu cùng lúc |
| **Logical Replication** | Cơ chế Postgres đẩy WAL ra ngoài, base của Supabase Realtime |
| **Provider (Flutter)** | Pattern quản lý state dùng ChangeNotifier |
