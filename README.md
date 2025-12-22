# Banyumas SportHub

Platform digital terintegrasi untuk menghubungkan komunitas olahraga di Banyumas. Aplikasi ini menyediakan layanan pemesanan venue, marketplace produk olahraga, manajemen event, dan jejaring komunitas olahraga.

## Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────────────┐
│                        Frontend (Flutter)                       │
│           Cross-platform: Android, iOS, Web, Desktop            │
└─────────────────────────────────┬───────────────────────────────┘
                                  │ HTTP/REST
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Backend (Node.js + Express)                   │
│                         RESTful API                             │
└─────────────────────────────────┬───────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                          MySQL Database                         │
└─────────────────────────────────────────────────────────────────┘
```

## Fitur Utama

| Modul | Deskripsi |
|-------|-----------|
| **Autentikasi** | Register, login, manajemen profil pengguna |
| **Marketplace** | Jual beli produk olahraga dengan sistem order |
| **Venue Booking** | Pemesanan lapangan dan fasilitas olahraga |
| **Event** | Daftar dan pendaftaran event olahraga |
| **Komunitas** | Jejaring komunitas olahraga lokal |
| **Dashboard Admin** | Monitoring dan manajemen data terpusat |

## Teknologi

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MySQL
- **Authentication**: JWT (JSON Web Token)
- **File Upload**: Multer
- **Password Hashing**: bcryptjs

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences
- **Typography**: Google Fonts

## Instalasi

### Prasyarat
- Node.js v18+
- MySQL 8.0+
- Flutter SDK 3.0+
- XAMPP (opsional, untuk MySQL lokal)

### Setup Backend

1. Masuk ke direktori backend:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Konfigurasi environment variables. Buat file `.env`:
   ```env
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=banyumas_sporthub
   JWT_SECRET=your_jwt_secret_key
   PORT=5000
   ```

4. Jalankan migrasi dan seeding database:
   ```bash
   npm run db:setup
   ```

5. Jalankan server development:
   ```bash
   npm run dev
   ```

Server akan berjalan di `http://localhost:5000`

### Setup Frontend

1. Masuk ke direktori frontend:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## API Endpoints

### Authentication
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/auth/register` | Registrasi user baru |
| POST | `/api/auth/login` | Login user |

### Products
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/products` | Daftar semua produk |
| GET | `/api/products/:id` | Detail produk |
| POST | `/api/products` | Tambah produk baru |
| PUT | `/api/products/:id` | Update produk |
| DELETE | `/api/products/:id` | Hapus produk |

### Orders
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/orders` | Daftar order |
| POST | `/api/orders` | Buat order baru |
| PATCH | `/api/orders/:id` | Update status order |

### Venues
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/venues` | Daftar venue |
| POST | `/api/venues` | Tambah venue |
| PUT | `/api/venues/:id` | Update venue |
| DELETE | `/api/venues/:id` | Hapus venue |

### Bookings
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/bookings` | Daftar booking |
| POST | `/api/bookings` | Buat booking baru |
| PATCH | `/api/bookings/:id` | Update status booking |

### Events
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/events` | Daftar event |
| POST | `/api/events` | Tambah event |
| PUT | `/api/events/:id` | Update event |
| DELETE | `/api/events/:id` | Hapus event |

### Communities
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/communities` | Daftar komunitas |
| POST | `/api/communities` | Tambah komunitas |
| PUT | `/api/communities/:id` | Update komunitas |
| DELETE | `/api/communities/:id` | Hapus komunitas |

## Struktur Proyek

```
sporthub/
├── backend/
│   ├── server.js              # Entry point aplikasi
│   ├── package.json           # Dependencies dan scripts
│   ├── .env                   # Environment variables
│   ├── uploads/               # File uploads storage
│   └── src/
│       ├── config/            # Konfigurasi database
│       ├── controllers/       # Logic handler
│       ├── middleware/        # Auth middleware
│       ├── routes/            # Route definitions
│       ├── scripts/           # Migration dan seeding
│       └── services/          # Business logic
│
└── frontend/
    ├── pubspec.yaml           # Flutter dependencies
    ├── lib/
    │   ├── main.dart          # Entry point Flutter
    │   ├── app_theme.dart     # Theme configuration
    │   ├── models/            # Data models
    │   ├── pages/             # UI screens
    │   │   ├── admin/         # Admin pages
    │   │   ├── user/          # User pages
    │   │   └── login/         # Auth pages
    │   ├── providers/         # State management
    │   └── services/          # API services
    └── assets/                # Images dan resources
```

## Scripts

### Backend
```bash
npm start            # Jalankan production server
npm run dev          # Jalankan development server dengan hot reload
npm run migrate      # Jalankan database migration
npm run seed         # Jalankan database seeding
npm run db:setup     # Migrate + Seed sekaligus
```

### Frontend
```bash
flutter pub get      # Install dependencies
flutter run          # Debug mode
flutter build apk    # Build APK Android
flutter build ios    # Build iOS
flutter build web    # Build Web
```

## Lisensi

MIT License

---

**Banyumas SportHub** - Membangun ekosistem olahraga digital untuk masyarakat Banyumas.
