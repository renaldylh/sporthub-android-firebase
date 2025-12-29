# Dokumentasi Lengkap: Banyumas SportHub

## Daftar Isi
1. [Cara Menjalankan Project](#cara-menjalankan-project)
2. [Arsitektur Sistem](#arsitektur-sistem)
3. [Struktur File Backend](#struktur-file-backend)
4. [Alur Kerja Backend](#alur-kerja-backend)
5. [Mengapa Firebase dan Node.js?](#mengapa-firebase-dan-nodejs)

---

## Cara Menjalankan Project

### Prasyarat
- Node.js v18+ (download: https://nodejs.org)
- Flutter SDK 3.0+ (download: https://flutter.dev)
- Git

### Langkah 1: Clone/Siapkan Project
```bash
cd c:\xampp\htdocs\sporthub
```

### Langkah 2: Jalankan Backend
```bash
# Masuk folder backend
cd backend

# Install dependencies
npm install

# Jalankan server development
npm run dev
```

**Output yang diharapkan:**
```
✅ Firebase Realtime Database connected
🚀 Banyumas SportHub API listening on http://localhost:5000
📋 Health check: http://localhost:5000/api/health
🔥 Using Firebase Realtime Database
🖼️  Using ImgBB for image storage
```

### Langkah 3: Seed Data (Buat Akun Admin & User)
```bash
# Di terminal baru (backend tetap jalan)
cd c:\xampp\htdocs\sporthub\backend
node src/scripts/firebase-seed.js
```

**Akun yang dibuat:**
| Role | Email | Password |
|------|-------|----------|
| Admin | admin@sporthub.com | password123 |
| User | user@sporthub.com | password123 |

### Langkah 4: Jalankan Flutter App
```bash
# Buka terminal baru
cd c:\xampp\htdocs\sporthub\frontend

# Install dependencies Flutter
flutter pub get

# Jalankan di emulator
flutter run
```

### Langkah 5: Login
1. Pilih "Masuk sebagai Admin" atau "Masuk sebagai Pengguna"
2. Gunakan akun dari tabel di atas

---

## Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                               │
│         (Android/iOS/Web - User Interface)                       │
│                                                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Login Page  │  │ Admin Pages │  │ User Pages  │              │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘              │
│         │                │                │                      │
│         └────────────────┴────────────────┘                      │
│                          │                                       │
│                  ┌───────┴───────┐                               │
│                  │ API Client    │ ← Mengirim HTTP Request       │
│                  │ (api_client.dart)                             │
│                  └───────┬───────┘                               │
└──────────────────────────┼───────────────────────────────────────┘
                           │
                           │ HTTP/REST API
                           │ (JSON)
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      BACKEND NODE.JS                             │
│                    (server.js - Express)                         │
│                                                                   │
│  Menerima Request → Proses Logic → Kirim Response                │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                        ROUTES                                │ │
│  │  /api/auth    → authRoutes    → authController              │ │
│  │  /api/products→ productRoutes → productController           │ │
│  │  /api/orders  → orderRoutes   → orderController             │ │
│  │  /api/venues  → venueRoutes   → venueController             │ │
│  │  /api/bookings→ bookingRoutes → bookingController           │ │
│  │  /api/events  → eventRoutes   → eventController             │ │
│  │  /api/users   → userRoutes    → userController              │ │
│  │  /api/communities → communityRoutes → communityController   │ │
│  │  /api/dashboard   → dashboardRoutes → dashboardController   │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                           │                                       │
│                           ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                       SERVICES                               │ │
│  │  Berisi business logic & interaksi dengan database          │ │
│  │  userService, productService, orderService, dll             │ │
│  └─────────────────────────────────────────────────────────────┘ │
└──────────────────────────┬───────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FIREBASE REALTIME DATABASE                    │
│              (Cloud Database - Gratis)                           │
│                                                                   │
│  /users       → Data pengguna (email, nama, role, password)     │
│  /products    → Data produk marketplace                          │
│  /orders      → Data pesanan                                      │
│  /venues      → Data tempat olahraga                              │
│  /bookings    → Data pemesanan venue                              │
│  /events      → Data event olahraga                               │
│  /communities → Data komunitas                                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         IMGBB                                    │
│              (Image Hosting - Gratis)                            │
│                                                                   │
│  Upload gambar produk, venue, event, dll                         │
│  Return URL gambar yang bisa diakses publik                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Struktur File Backend

```
backend/
├── server.js                 ← Entry point, konfigurasi Express
├── package.json              ← Dependencies & scripts
├── .env                      ← Environment variables (rahasia!)
├── sporthub-d04b4-firebase.json ← Firebase credentials (rahasia!)
│
└── src/
    ├── config/
    │   ├── firebase.js       ← Koneksi ke Firebase Database
    │   └── imgbb.js          ← Service upload gambar ke ImgBB
    │
    ├── controllers/          ← Menerima request, kirim response
    │   ├── authController.js
    │   ├── productController.js
    │   ├── orderController.js
    │   ├── venueController.js
    │   ├── bookingController.js
    │   ├── eventController.js
    │   ├── userController.js
    │   ├── communityController.js
    │   └── dashboardController.js
    │
    ├── routes/               ← Definisi endpoint API
    │   ├── authRoutes.js
    │   ├── productRoutes.js
    │   ├── orderRoutes.js
    │   ├── venueRoutes.js
    │   ├── bookingRoutes.js
    │   ├── eventRoutes.js
    │   ├── userRoutes.js
    │   ├── communityRoutes.js
    │   └── dashboardRoutes.js
    │
    ├── services/             ← Business logic & akses database
    │   ├── userService.js
    │   ├── productService.js
    │   ├── orderService.js
    │   ├── venueService.js
    │   ├── bookingService.js
    │   ├── eventService.js
    │   ├── communityService.js
    │   └── dashboardService.js
    │
    ├── middleware/           ← Pengecekan sebelum request diproses
    │   └── authMiddleware.js ← Verifikasi JWT token
    │
    └── scripts/              ← Script utility
        └── firebase-seed.js  ← Membuat data awal
```

### Penjelasan Setiap Layer:

#### 1. `server.js` - Entry Point
```javascript
// Inisialisasi Express app
const app = express();

// Middleware
app.use(cors());          // Izinkan request dari Flutter
app.use(express.json());  // Parse JSON body

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
// ... dst

// Start server
app.listen(5000);
```

#### 2. Routes - Definisi Endpoint
```javascript
// routes/productRoutes.js
router.get('/', productController.getAll);      // GET /api/products
router.get('/:id', productController.getById);  // GET /api/products/123
router.post('/', auth, productController.create); // POST /api/products
router.put('/:id', auth, productController.update); // PUT /api/products/123
router.delete('/:id', auth, productController.delete); // DELETE /api/products/123
```

#### 3. Controllers - Handle Request/Response
```javascript
// controllers/productController.js
const getAll = async (req, res) => {
  try {
    const products = await productService.getProducts();
    res.json({ products });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
```

#### 4. Services - Business Logic
```javascript
// services/productService.js
const getProducts = async () => {
  const products = await getAll('products');  // Ambil dari Firebase
  products.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  return products;
};
```

#### 5. Config - Koneksi Database
```javascript
// config/firebase.js
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: process.env.FIREBASE_DATABASE_URL
});

const db = admin.database();
```

---

## Alur Kerja Backend

### Contoh: User Login

```
1. FLUTTER mengirim request:
   POST http://localhost:5000/api/auth/login
   Body: { "email": "user@sporthub.com", "password": "password123" }

2. SERVER.JS menerima request, forward ke routes:
   app.use('/api/auth', authRoutes);

3. AUTH ROUTES mengarahkan ke controller:
   router.post('/login', authController.login);

4. AUTH CONTROLLER memproses:
   - Ambil email & password dari request body
   - Panggil userService.getUserByEmail(email)
   - Bandingkan password dengan bcrypt
   - Generate JWT token jika valid
   - Kirim response

5. USER SERVICE query ke Firebase:
   - db.ref('users').orderByChild('email').equalTo(email)
   - Return user data

6. RESPONSE kembali ke Flutter:
   { 
     "user": { "id": "...", "email": "...", "name": "...", "role": "user" },
     "token": "eyJhbG..." 
   }

7. FLUTTER simpan token dan navigasi ke halaman user
```

### Contoh: Admin Tambah Produk

```
1. FLUTTER (admin) mengirim request:
   POST http://localhost:5000/api/products
   Headers: { "Authorization": "Bearer eyJhbG..." }
   Body: { "name": "Bola", "price": 150000, "stock": 10 }

2. AUTH MIDDLEWARE cek token:
   - Decode JWT token
   - Cek apakah valid & belum expired
   - Cek role === 'admin' (jika perlu)
   - Jika valid, lanjut ke controller

3. PRODUCT CONTROLLER:
   - Terima data dari body
   - Panggil productService.createProduct(data)

4. PRODUCT SERVICE:
   - Generate UUID untuk ID baru
   - Simpan ke Firebase: db.ref('products/' + id).set(data)
   - Return produk yang dibuat

5. RESPONSE:
   { "id": "abc123", "name": "Bola", "price": 150000, ... }
```

---

## Mengapa Firebase dan Node.js?

### Mengapa TIDAK pakai Database Lokal (MySQL)?

| Aspek | MySQL Lokal | Firebase |
|-------|-------------|----------|
| **Instalasi** | Perlu install MySQL server | Tidak perlu install apapun |
| **Akses dari HP** | Hanya di jaringan yang sama | Dari mana saja (internet) |
| **Backup** | Manual | Otomatis oleh Google |
| **Skalabilitas** | Terbatas spek komputer | Auto-scale |
| **Biaya** | Gratis tapi butuh server | Gratis (sampai limit tertentu) |
| **Deploy** | Rumit (perlu VPS/hosting) | Sudah cloud |

**Alasan utama: AKSESIBILITAS**
- MySQL lokal = APP hanya bisa dipakai di jaringan WiFi yang sama
- Firebase = APP bisa dipakai dari mana saja (berbeda kota, negara, dll)

### Mengapa Pakai Node.js Backend?

#### Keuntungan:
1. **Kontrol penuh** atas business logic
2. **Keamanan** - Firebase credentials tidak ada di APK
3. **Validasi** - Server memastikan data yang masuk valid
4. **Transformasi data** - Bisa modifikasi data sebelum disimpan/dikirim
5. **Rate limiting** - Bisa batasi request untuk mencegah abuse
6. **Logging** - Bisa track semua aktivitas

#### Kekurangan:
1. **Perlu hosting** - Harus deploy ke server (Render.com, dll)
2. **Cold start** - Server tidur jika tidak ada request (free tier)
3. **Maintenance** - Perlu update & monitor

### Perbandingan Arsitektur

```
OPSI A: Flutter → Backend Node.js → Firebase (SAAT INI)
✅ Lebih aman (credentials di server)
✅ Kontrol penuh
✅ Bisa tambah fitur kompleks (payment gateway, notifikasi, dll)
❌ Perlu hosting backend

OPSI B: Flutter → Firebase langsung (ALTERNATIF)
✅ Tidak perlu hosting
✅ Lebih cepat (tidak ada perantara)
✅ Lebih sederhana
❌ Firebase credentials ada di APK (bisa di-reverse engineer)
❌ Business logic di client (kurang aman)
```

### Kapan Pakai yang Mana?

| Skenario | Rekomendasi |
|----------|-------------|
| Aplikasi kecil/personal | Firebase langsung |
| Aplikasi dengan data sensitif | Pakai Backend |
| Butuh integrasi payment | Pakai Backend |
| Butuh kirim email/notifikasi | Pakai Backend |
| Prototype/MVP cepat | Firebase langsung |
| Aplikasi produksi serius | Pakai Backend |

---

## Ringkasan

```
TEKNOLOGI YANG DIGUNAKAN:

┌─────────────────────────────────────────┐
│ FRONTEND: Flutter                       │
│ - Cross-platform (Android, iOS, Web)   │
│ - State management: Provider            │
│ - HTTP client: http package             │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ BACKEND: Node.js + Express              │
│ - RESTful API                           │
│ - JWT untuk autentikasi                 │
│ - Bcrypt untuk hash password            │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│ DATABASE: Firebase Realtime Database    │
│ - NoSQL (JSON-based)                    │
│ - Real-time sync                        │
│ - Gratis sampai 1GB                     │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ IMAGE STORAGE: ImgBB                    │
│ - Unlimited upload                      │
│ - CDN untuk akses cepat                 │
│ - Gratis                                │
└─────────────────────────────────────────┘
```
