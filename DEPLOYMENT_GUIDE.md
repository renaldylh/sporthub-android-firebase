# Tutorial Deploy Banyumas SportHub ke Produksi

Panduan lengkap dari menjalankan project sampai APK bisa dipakai di mana saja (beda WiFi/jaringan).

## Arsitektur Produksi

```
┌─────────────────────────────────────────────────────────────────┐
│                     Flutter APK (di HP user)                    │
└─────────────────────────────┬───────────────────────────────────┘
                              │ HTTPS (Internet)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              Backend Node.js di Render.com (GRATIS)             │
│              URL: https://sporthub-api.onrender.com              │
└──────────────┬──────────────────────────────────────┬───────────┘
               │                                      │
               ▼                                      ▼
┌──────────────────────────┐         ┌────────────────────────────┐
│ Firebase Realtime DB     │         │ ImgBB (gratis)             │
│ (sudah dikonfigurasi)    │         │ (sudah dikonfigurasi)      │
└──────────────────────────┘         └────────────────────────────┘
```

---

## LANGKAH 1: Persiapan File untuk Deploy

### 1.1 Buat file `render.yaml` di folder backend

```bash
cd backend
```

Buat file `render.yaml`:
```yaml
services:
  - type: web
    name: sporthub-api
    env: node
    plan: free
    buildCommand: npm install
    startCommand: npm start
    envVars:
      - key: NODE_ENV
        value: production
      - key: PORT
        value: 5000
```

### 1.2 Update `package.json` (pastikan ada script start)

```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  }
}
```

### 1.3 Buat file `.gitignore` di folder backend

```
node_modules/
.env
uploads/
*.log
```

> ⚠️ **PENTING**: File `.env` dan `sporthub-d04b4-firebase.json` TIDAK boleh di-upload ke Git publik!

---

## LANGKAH 2: Deploy Backend ke Render.com (GRATIS)

### 2.1 Buat Akun Render
1. Buka https://render.com
2. Klik **Sign Up** → Pilih **GitHub** atau **Email**
3. Verifikasi email

### 2.2 Push Project ke GitHub (Private Repo)
```bash
cd c:\xampp\htdocs\sporthub\backend

# Inisialisasi Git
git init

# Buat .gitignore agar credentials aman
echo "node_modules/" > .gitignore
echo ".env" >> .gitignore
echo "uploads/" >> .gitignore

# Add dan commit
git add .
git commit -m "Initial commit - SportHub Backend"

# Push ke GitHub (buat repo private dulu di github.com)
git remote add origin https://github.com/USERNAME/sporthub-backend.git
git branch -M main
git push -u origin main
```

### 2.3 Deploy di Render Dashboard
1. Login ke https://dashboard.render.com
2. Klik **New** → **Web Service**
3. Pilih **Connect a repository** → Pilih repo `sporthub-backend`
4. Konfigurasi:
   - **Name**: `sporthub-api`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
5. Klik **Advanced** → **Add Environment Variables**:

   | Key | Value |
   |-----|-------|
   | `PORT` | `5000` |
   | `JWT_SECRET` | `sporthub-secret-key-change-in-production` |
   | `FIREBASE_DATABASE_URL` | `https://sporthub-d04b4-default-rtdb.asia-southeast1.firebasedatabase.app` |
   | `IMGBB_API_KEY` | `7c39eba7c90b99b20651dded97f0ba4c` |

6. **PENTING**: Untuk Firebase credentials:
   - Klik **Add Secret File**
   - **Filename**: `sporthub-d04b4-firebase.json`
   - **Contents**: Copy isi file `sporthub-d04b4-firebase.json`
   
   Dan tambah environment variable:
   | Key | Value |
   |-----|-------|
   | `FIREBASE_SERVICE_ACCOUNT` | `./sporthub-d04b4-firebase.json` |

7. Klik **Create Web Service**
8. Tunggu deploy selesai (sekitar 2-5 menit)
9. Catat URL yang diberikan, contoh: `https://sporthub-api.onrender.com`

### 2.4 Test Backend di Render
Buka browser: `https://sporthub-api.onrender.com/api/health`

Jika berhasil:
```json
{
  "status": "ok",
  "message": "Banyumas SportHub API is running with Firebase"
}
```

---

## LANGKAH 3: Update Flutter App dengan URL Produksi

### 3.1 Update Default URL di api_client.dart

Edit file `frontend/lib/services/api_client.dart`:

```dart
// Ubah default URL ke URL Render
static const String _defaultEmulatorUrl = 'https://sporthub-api.onrender.com/api';
static const String _defaultWebUrl = 'https://sporthub-api.onrender.com/api';
```

Atau biarkan default dan pengguna bisa set sendiri di Settings.

---

## LANGKAH 4: Build APK Release

### 4.1 Persiapan Android Signing Key

```bash
cd frontend

# Buat keystore untuk signing APK
keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Isi informasi yang diminta (password, nama, organisasi, dll).

### 4.2 Buat file `key.properties`

Buat file `frontend/android/key.properties`:
```properties
storePassword=password_anda
keyPassword=password_anda
keyAlias=upload
storeFile=upload-keystore.jks
```

### 4.3 Update `build.gradle`

Edit `frontend/android/app/build.gradle`:

Tambah di bagian atas (sebelum `android {`):
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Di dalam `android {`, tambah:
```groovy
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

### 4.4 Build APK

```bash
cd frontend

# Get dependencies
flutter pub get

# Build APK Release
flutter build apk --release
```

### Lokasi APK:
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```

---

## LANGKAH 5: Distribusi APK

### Opsi 1: Share Langsung
Copy file `app-release.apk` dan share via:
- Google Drive
- WhatsApp
- Telegram
- Email

### Opsi 2: Upload ke Firebase App Distribution
1. Buka Firebase Console → App Distribution
2. Upload APK
3. Invite testers via email

### Opsi 3: Publish ke Play Store (berbayar $25 sekali)
1. Daftar Google Play Console
2. Upload APK/AAB
3. Isi informasi aplikasi
4. Submit untuk review

---

## LANGKAH 6: Cara Penggunaan APK

### Untuk End User:
1. Download dan install APK
2. Buka aplikasi
3. Jika perlu, klik ⚙️ (Settings) dan masukkan:
   - `sporthub-api.onrender.com` (tanpa https://)
4. Test koneksi
5. Login dengan:
   - **Admin**: admin@sporthub.com / password123
   - **User**: user@sporthub.com / password123

---

## Ringkasan Biaya

| Service | Biaya |
|---------|-------|
| Firebase Realtime DB | **GRATIS** (Spark Plan) |
| ImgBB Image Hosting | **GRATIS** |
| Render.com Hosting | **GRATIS** (Free tier) |
| **TOTAL** | **GRATIS** |

> ⚠️ **Catatan Render Free Tier**: Server akan "tidur" jika tidak ada request selama 15 menit. Request pertama setelah tidur akan lambat (30-60 detik) karena cold start.

---

## Troubleshooting

### 1. Error "Connection refused"
- Pastikan URL benar (tidak ada typo)
- Cek apakah server Render sudah running

### 2. Error "timeout"
- Server Render mungkin sedang cold start, tunggu 30-60 detik

### 3. Error "Invalid credentials"
- Pastikan email dan password benar
- Jalankan ulang seed script jika data hilang

---

## Quick Commands Summary

```bash
# === BACKEND ===
cd c:\xampp\htdocs\sporthub\backend

# Development (lokal)
npm run dev

# Seed database
node src/scripts/firebase-seed.js

# === FRONTEND ===
cd c:\xampp\htdocs\sporthub\frontend

# Run di emulator
flutter run

# Build APK release
flutter build apk --release
```
