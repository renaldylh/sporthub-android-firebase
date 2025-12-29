# Dokumentasi Alur Frontend-Backend: Banyumas SportHub

Dokumen ini menjelaskan secara detail bagaimana **Flutter (Frontend)** dan **Node.js (Backend)** berkomunikasi untuk setiap fitur dalam aplikasi.

---

## Daftar Isi

1. [Konsep Dasar Koneksi](#1-konsep-dasar-koneksi)
2. [Autentikasi (Login & Register)](#2-autentikasi-login--register)
3. [Manajemen Produk (Marketplace)](#3-manajemen-produk-marketplace)
4. [Manajemen Order](#4-manajemen-order)
5. [Manajemen Venue](#5-manajemen-venue)
6. [Manajemen Booking](#6-manajemen-booking)
7. [Manajemen Event](#7-manajemen-event)
8. [Manajemen Komunitas](#8-manajemen-komunitas)
9. [Dashboard Admin](#9-dashboard-admin)
10. [Upload Gambar](#10-upload-gambar)

---

## 1. Konsep Dasar Koneksi

### Arsitektur Komunikasi

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              FLUTTER APP                                     │
│                                                                              │
│  ┌─────────────┐     ┌─────────────────┐     ┌─────────────────────┐        │
│  │   UI PAGE   │────>│    SERVICE      │────>│    API CLIENT       │        │
│  │ (tampilan)  │     │ (business logic)│     │ (kirim HTTP request)│        │
│  └─────────────┘     └─────────────────┘     └──────────┬──────────┘        │
└──────────────────────────────────────────────────────────┼───────────────────┘
                                                           │
                                                           │ HTTP REQUEST
                                                           │ (GET/POST/PUT/DELETE)
                                                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                             BACKEND NODE.JS                                  │
│                                                                              │
│  ┌─────────────┐     ┌─────────────────┐     ┌─────────────────────┐        │
│  │   ROUTES    │────>│   CONTROLLER    │────>│      SERVICE        │        │
│  │ (endpoint)  │     │ (handle request)│     │ (akses database)    │        │
│  └─────────────┘     └─────────────────┘     └──────────┬──────────┘        │
└──────────────────────────────────────────────────────────┼───────────────────┘
                                                           │
                                                           │ FIREBASE SDK
                                                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FIREBASE REALTIME DATABASE                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

### File Kunci di Flutter (Frontend)

| File | Lokasi | Fungsi |
|------|--------|--------|
| `api_client.dart` | `lib/services/` | Kirim HTTP request ke backend |
| `auth_service.dart` | `lib/services/` | Logic autentikasi |
| `product_service.dart` | `lib/services/` | Logic produk |
| `venue_service.dart` | `lib/services/` | Logic venue |
| `booking_service.dart` | `lib/services/` | Logic booking |
| `order_service.dart` | `lib/services/` | Logic order |
| `event_service.dart` | `lib/services/` | Logic event |
| `community_service.dart` | `lib/services/` | Logic komunitas |

### File Kunci di Node.js (Backend)

| File | Lokasi | Fungsi |
|------|--------|--------|
| `server.js` | `backend/` | Entry point, konfigurasi Express |
| `firebase.js` | `src/config/` | Koneksi ke Firebase |
| `authRoutes.js` | `src/routes/` | Definisi endpoint auth |
| `authController.js` | `src/controllers/` | Handle request auth |
| `userService.js` | `src/services/` | Akses data user di Firebase |

---

## 2. Autentikasi (Login & Register)

### 2.1 Login User

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ FLUTTER: User klik tombol "Login"                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  login_user_page.dart                                                        │
│  ┌──────────────────────────────────────────────────────────┐               │
│  │ ElevatedButton(                                          │               │
│  │   onPressed: () async {                                  │               │
│  │     final result = await AuthService().login(            │               │
│  │       emailController.text,                              │               │
│  │       passwordController.text,                           │               │
│  │     );                                                   │               │
│  │     if (result['user']['role'] == 'user') {             │               │
│  │       Navigator.pushNamed(context, '/user');             │               │
│  │     }                                                    │               │
│  │   },                                                     │               │
│  │ )                                                        │               │
│  └──────────────────────────────────────────────────────────┘               │
│                                      │                                       │
│                                      ▼                                       │
│  auth_service.dart                                                           │
│  ┌──────────────────────────────────────────────────────────┐               │
│  │ Future<Map> login(String email, String password) async { │               │
│  │   final response = await ApiClient.instance.post(        │               │
│  │     '/auth/login',                                       │               │
│  │     {'email': email, 'password': password},              │               │
│  │   );                                                     │               │
│  │   ApiClient.instance.updateToken(response['token']);     │               │
│  │   return response;                                       │               │
│  │ }                                                        │               │
│  └──────────────────────────────────────────────────────────┘               │
│                                      │                                       │
│                                      ▼                                       │
│  api_client.dart                                                             │
│  ┌──────────────────────────────────────────────────────────┐               │
│  │ POST http://10.0.2.2:5000/api/auth/login                 │               │
│  │ Body: {"email": "user@sporthub.com", "password": "..."}  │               │
│  └──────────────────────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       │ HTTP POST
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ BACKEND: Menerima dan memproses request                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  server.js                                                                   │
│  ┌──────────────────────────────────────────────────────────┐               │
│  │ app.use('/api/auth', authRoutes);                        │               │
│  │ // Request diarahkan ke authRoutes                       │               │
│  └──────────────────────────────────────────────────────────┘               │
│                                      │                                       │
│                                      ▼                                       │
│  authRoutes.js                                                               │
│  ┌──────────────────────────────────────────────────────────┐               │
│  │ router.post('/login', authController.login);             │               │
│  │ // Panggil fungsi login di controller                    │               │
│  └──────────────────────────────────────────────────────────┘               │
│                                      │                                       │
│                                      ▼                                       │
│  authController.js                                                           │
│  ┌──────────────────────────────────────────────────────────┐               │
│  │ const login = async (req, res) => {                      │               │
│  │   const { email, password } = req.body;                  │               │
│  │                                                          │               │
│  │   // 1. Cari user di database                            │               │
│  │   const user = await getUserByEmail(email);              │               │
│  │   if (!user) return res.status(401).json({...});         │               │
│  │                                                          │               │
│  │   // 2. Verifikasi password                              │               │
│  │   const isValid = await bcrypt.compare(password,         │               │
│  │                                        user.passwordHash);│               │
│  │   if (!isValid) return res.status(401).json({...});      │               │
│  │                                                          │               │
│  │   // 3. Generate JWT token                               │               │
│  │   const token = jwt.sign({ id: user.id, role: user.role },│              │
│  │                          JWT_SECRET, { expiresIn: '7d' });│               │
│  │                                                          │               │
│  │   // 4. Kirim response                                   │               │
│  │   res.json({ user: sanitize(user), token });             │               │
│  │ };                                                       │               │
│  └──────────────────────────────────────────────────────────┘               │
│                                      │                                       │
│                                      ▼                                       │
│  userService.js                                                              │
│  ┌──────────────────────────────────────────────────────────┐               │
│  │ const getUserByEmail = async (email) => {                │               │
│  │   const users = await queryByChild('users', 'email',     │               │
│  │                                    email);               │               │
│  │   return users[0] || null;                               │               │
│  │ };                                                       │               │
│  └──────────────────────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       │ Query
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ FIREBASE: Data user                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  {                                                                           │
│    "users": {                                                                │
│      "abc123": {                                                             │
│        "email": "user@sporthub.com",                                         │
│        "name": "User SportHub",                                              │
│        "role": "user",                                                       │
│        "passwordHash": "$2a$10$hashedpassword..."                            │
│      }                                                                       │
│    }                                                                         │
│  }                                                                           │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       │ Response
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ RESPONSE: Kembali ke Flutter                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│  {                                                                           │
│    "user": {                                                                 │
│      "id": "abc123",                                                         │
│      "email": "user@sporthub.com",                                           │
│      "name": "User SportHub",                                                │
│      "role": "user"                                                          │
│    },                                                                        │
│    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."                        │
│  }                                                                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Register User

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
register_page.dart
     │
     │ Klik "Daftar"
     ▼
auth_service.dart
register(name, email, password)
     │
     │ POST /api/auth/register
     │ Body: {name, email, password}
     ▼
                            authRoutes.js
                            router.post('/register', ...)
                                 │
                                 ▼
                            authController.js
                            - Validasi input
                            - Cek email sudah ada?
                            - Hash password
                            - Buat user baru
                                 │
                                 ▼
                            userService.js
                            createUser({email, password, name})
                                 │
                                 │ db.ref('users/'+id).set(...)
                                 ▼
                                                            /users/newId123
                                                            {
                                                              email: "...",
                                                              name: "...",
                                                              passwordHash: "...",
                                                              role: "user"
                                                            }
```

---

## 3. Manajemen Produk (Marketplace)

### 3.1 Lihat Semua Produk

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
marketplace_page.dart
initState() → loadProducts()
     │
     ▼
product_service.dart
getProducts()
     │
     │ GET /api/products
     ▼
                            productRoutes.js
                            router.get('/', getAll)
                                 │
                                 ▼
                            productController.js
                            const products = await 
                              productService.getProducts()
                            res.json({ products })
                                 │
                                 ▼
                            productService.js
                            getAll('products')
                                 │
                                 │ db.ref('products').once('value')
                                 ▼
                                                            /products
                                                            {
                                                              "prod1": {...},
                                                              "prod2": {...}
                                                            }

RESPONSE:
{
  "products": [
    { "id": "prod1", "name": "Bola Futsal", "price": 250000, ... },
    { "id": "prod2", "name": "Jersey Nike", "price": 450000, ... }
  ]
}
```

### 3.2 Admin Tambah Produk

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
add_product_page.dart
     │
     │ Klik "Simpan"
     ▼
product_service.dart
createProduct({name, price, stock, ...})
     │
     │ POST /api/products
     │ Headers: Authorization: Bearer <token>
     │ Body: {name, price, stock, description, imageUrl}
     ▼
                            authMiddleware.js
                            - Decode JWT token
                            - Cek valid & tidak expired
                            - req.user = decoded user
                                 │
                                 ▼
                            productRoutes.js
                            router.post('/', auth, create)
                                 │
                                 ▼
                            productController.js
                            productService.createProduct(req.body)
                                 │
                                 ▼
                            productService.js
                            const id = uuidv4()
                            create('products', id, {...})
                                 │
                                 │ db.ref('products/'+id).set(...)
                                 ▼
                                                            /products/newProdId
                                                            {
                                                              name: "Bola Voli",
                                                              price: 200000,
                                                              stock: 15,
                                                              ...
                                                            }
```

### 3.3 Admin Edit Produk

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
edit_product_page.dart
     │
     │ PUT /api/products/{id}
     │ Body: {name, price, stock, ...}
     ▼
                            productRoutes.js
                            router.put('/:id', auth, update)
                                 │
                                 ▼
                            productService.js
                            update('products', id, {...})
                                 │
                                 │ db.ref('products/'+id).update(...)
                                 ▼
                                                            /products/{id}
                                                            {
                                                              name: "Bola Voli Updated",
                                                              ...
                                                            }
```

### 3.4 Admin Hapus Produk

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
product_list_page.dart
     │
     │ DELETE /api/products/{id}
     ▼
                            productRoutes.js
                            router.delete('/:id', auth, delete)
                                 │
                                 ▼
                            productService.js
                            remove('products', id)
                                 │
                                 │ db.ref('products/'+id).remove()
                                 ▼
                                                            /products/{id}
                                                            (DELETED)
```

---

## 4. Manajemen Order

### 4.1 User Buat Pesanan

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
cart_page.dart → checkout
     │
     │ POST /api/orders
     │ Body: {
     │   items: [{productId, name, price, quantity}],
     │   totalAmount: 500000,
     │   shippingAddress: "Jl. ..."
     │ }
     ▼
                            orderRoutes.js
                            router.post('/', auth, create)
                                 │
                                 ▼
                            orderController.js
                            - req.user.id dari token
                            - createOrder({userId: req.user.id, ...})
                                 │
                                 ▼
                            orderService.js
                            - Generate order ID
                            - Set expiresAt (10 jam)
                            - Simpan order + items
                                 │
                                 │ db.ref('orders/'+orderId).set(...)
                                 ▼
                                                            /orders/ord123
                                                            {
                                                              userId: "abc123",
                                                              items: [...],
                                                              totalAmount: 500000,
                                                              status: "pending",
                                                              expiresAt: "..."
                                                            }
```

### 4.2 User Lihat Order Sendiri

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
my_orders_page.dart
     │
     │ GET /api/orders/my
     │ Headers: Authorization: Bearer <token>
     ▼
                            orderRoutes.js
                            router.get('/my', auth, getMyOrders)
                                 │
                                 ▼
                            orderService.js
                            getOrdersByUser(req.user.id)
                                 │
                                 │ Query where userId == req.user.id
                                 ▼
                                                            Return only user's orders
```

### 4.3 Admin Lihat Semua Order

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
admin/orders_page.dart
     │
     │ GET /api/orders
     │ Headers: Authorization: Bearer <admin_token>
     ▼
                            orderRoutes.js
                            router.get('/', auth, getAll)
                                 │
                                 ▼
                            orderService.js
                            getOrders() // All orders
                                 │
                                 │ db.ref('orders').once('value')
                                 ▼
                                                            Return ALL orders
```

### 4.4 Admin Update Status Order

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
order_detail_page.dart
     │
     │ PATCH /api/orders/{id}
     │ Body: { status: "paid" }
     ▼
                            orderRoutes.js
                            router.patch('/:id', auth, updateStatus)
                                 │
                                 ▼
                            orderService.js
                            updateOrderStatus(id, "paid")
                                 │
                                 │ db.ref('orders/'+id).update({status: "paid"})
                                 ▼
                                                            /orders/{id}
                                                            { status: "paid", ... }
```

---

## 5. Manajemen Venue

### 5.1 Lihat Daftar Venue

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
venues_page.dart
     │
     │ GET /api/venues
     ▼
                            venueRoutes.js
                            router.get('/', getAll)
                                 │
                                 ▼
                            venueService.js
                            getVenues()
                                 │
                                 │ db.ref('venues').once('value')
                                 ▼
                                                            /venues
                                                            {
                                                              "ven1": {
                                                                name: "Lapangan Futsal A",
                                                                type: "futsal",
                                                                pricePerHour: 100000
                                                              }
                                                            }
```

### 5.2 Admin CRUD Venue

```
POST   /api/venues         → createVenue()    → db.ref('venues/'+id).set()
GET    /api/venues/{id}    → getVenueById()   → db.ref('venues/'+id).once()
PUT    /api/venues/{id}    → updateVenue()    → db.ref('venues/'+id).update()
DELETE /api/venues/{id}    → deleteVenue()    → db.ref('venues/'+id).remove()
```

---

## 6. Manajemen Booking

### 6.1 User Buat Booking

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
booking_form_page.dart
     │
     │ POST /api/bookings
     │ Body: {
     │   venueId: "ven1",
     │   bookingDate: "2024-01-15",
     │   startTime: "09:00",
     │   endTime: "11:00",
     │   notes: "..."
     │ }
     ▼
                            bookingRoutes.js
                            router.post('/', auth, create)
                                 │
                                 ▼
                            bookingService.js
                            - userId dari token
                            - Hitung totalPrice
                            - createBooking({...})
                                 │
                                 │ db.ref('bookings/'+id).set(...)
                                 ▼
                                                            /bookings/book123
                                                            {
                                                              venueId: "ven1",
                                                              userId: "abc123",
                                                              bookingDate: "2024-01-15",
                                                              startTime: "09:00",
                                                              endTime: "11:00",
                                                              totalPrice: 200000,
                                                              status: "pending"
                                                            }
```

### 6.2 Admin Approve/Reject Booking

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
admin/booking_detail.dart
     │
     │ PATCH /api/bookings/{id}
     │ Body: { status: "approved", adminNotes: "Silakan datang tepat waktu" }
     ▼
                            bookingService.js
                            updateBookingStatus(id, "approved", adminNotes)
                                 │
                                 │ db.ref('bookings/'+id).update({...})
                                 ▼
                                                            /bookings/{id}
                                                            { status: "approved", ... }
```

### 6.3 User Cancel Booking

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
my_bookings_page.dart
     │
     │ PATCH /api/bookings/{id}/cancel
     ▼
                            bookingService.js
                            cancelBooking(id, req.user.id)
                            - Cek booking milik user ini?
                            - Cek status masih "pending"?
                            - Update status ke "cancelled"
                                 │
                                 ▼
                                                            /bookings/{id}
                                                            { status: "cancelled" }
```

---

## 7. Manajemen Event

### 7.1 Lihat Daftar Event

```
GET /api/events → eventService.findAll() → db.ref('events').once('value')
```

### 7.2 Admin CRUD Event

```
POST   /api/events         → eventService.create()   → db.ref('events/'+id).set()
PUT    /api/events/{id}    → eventService.update()   → db.ref('events/'+id).update()
DELETE /api/events/{id}    → eventService.delete()   → db.ref('events/'+id).remove()
```

---

## 8. Manajemen Komunitas

### 8.1 Lihat Daftar Komunitas

```
GET /api/communities → communityService.getCommunities() → db.ref('communities').once()
```

### 8.2 Admin CRUD Komunitas

```
POST   /api/communities         → createCommunity()    → db.ref('communities/'+id).set()
PUT    /api/communities/{id}    → updateCommunity()    → db.ref('communities/'+id).update()
DELETE /api/communities/{id}    → deleteCommunity()    → db.ref('communities/'+id).remove()
```

---

## 9. Dashboard Admin

### 9.1 Load Statistik Dashboard

```
FLUTTER                          BACKEND                         FIREBASE
───────                          ───────                         ────────
admin/dashboard_page.dart
     │
     │ GET /api/dashboard/stats
     ▼
                            dashboardRoutes.js
                            router.get('/stats', auth, getStats)
                                 │
                                 ▼
                            dashboardService.js
                            - Fetch all users, products, orders
                            - Hitung total users
                            - Hitung total products
                            - Hitung total orders
                            - Hitung total revenue
                            - Ambil 5 order terbaru
                            - Ambil produk low stock
                            - Group orders by status
                            - Hitung monthly revenue
                                 │
                                 ▼
RESPONSE:
{
  "totalUsers": 150,
  "totalProducts": 45,
  "totalOrders": 230,
  "totalRevenue": 15000000,
  "recentOrders": [...],
  "lowStockProducts": [...],
  "ordersByStatus": [
    { "status": "pending", "count": 10 },
    { "status": "paid", "count": 50 }
  ],
  "monthlyRevenue": [...]
}
```

---

## 10. Upload Gambar

### 10.1 Upload Gambar Produk/Venue/Event

```
FLUTTER                          BACKEND                         IMGBB
───────                          ───────                         ─────
image_picker → pilih gambar
     │
     │ POST /api/upload
     │ Content-Type: multipart/form-data
     │ Body: image file
     ▼
                            server.js
                            multer (memory storage)
                            upload.single('image')
                                 │
                                 ▼
                            imgbb.js
                            uploadImage(req.file.buffer)
                            - Convert to base64
                            - POST ke api.imgbb.com
                                 │
                                 ▼
                                                            IMGBB Server
                                                            Simpan gambar
                                                            Return URL

RESPONSE:
{
  "message": "Image uploaded successfully",
  "imageUrl": "https://i.ibb.co/abc123/image.jpg"
}

Flutter kemudian menggunakan imageUrl ini saat create/update produk:
POST /api/products
Body: { name: "...", imageUrl: "https://i.ibb.co/abc123/image.jpg" }
```

---

## Ringkasan Endpoint API

| Method | Endpoint | Auth? | Fungsi |
|--------|----------|-------|--------|
| POST | /api/auth/register | No | Register user baru |
| POST | /api/auth/login | No | Login user |
| GET | /api/auth/profile | Yes | Get profil user |
| GET | /api/products | No | List semua produk |
| POST | /api/products | Admin | Tambah produk |
| PUT | /api/products/:id | Admin | Edit produk |
| DELETE | /api/products/:id | Admin | Hapus produk |
| GET | /api/orders | Admin | List semua order |
| GET | /api/orders/my | User | Order milik user |
| POST | /api/orders | User | Buat order |
| PATCH | /api/orders/:id | Admin | Update status order |
| GET | /api/venues | No | List venue |
| POST | /api/venues | Admin | Tambah venue |
| PUT | /api/venues/:id | Admin | Edit venue |
| DELETE | /api/venues/:id | Admin | Hapus venue |
| GET | /api/bookings | Admin | List semua booking |
| POST | /api/bookings | User | Buat booking |
| PATCH | /api/bookings/:id | Admin | Approve/reject |
| GET | /api/events | No | List event |
| POST | /api/events | Admin | Tambah event |
| GET | /api/communities | No | List komunitas |
| POST | /api/communities | Admin | Tambah komunitas |
| GET | /api/dashboard/stats | Admin | Statistik dashboard |
| POST | /api/upload | Yes | Upload gambar |
| GET | /api/users | Admin | List users |
