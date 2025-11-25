# 🛍️ Dumbmerch Backend

Backend service untuk aplikasi **Dumbmerch**, dikembangkan sebagai project bootcamp **Dumbways Indonesia**.  
Repo ini berisi API untuk autentikasi, manajemen produk, dan transaksi, yang langsung bisa dijalankan menggunakan **Docker Compose**.

---

## 🚀 Tech Stack
- **Golang (Go)** → Backend utama
- **PostgreSQL** → Database
- **GORM** → ORM untuk Go
- **JWT Authentication** → Sistem login & proteksi API
- **Docker Compose** → Containerization & deployment

---

## ▶️ Cara Menjalankan

1. Clone repository:
   ```bash
   git clone https://github.com/abimsyaefulloh/be-dumbmerch.git
   cd be-dumbmerch
   ```
2. Jalankan dengan Docker Compose:
   ```bash
   docker-compose up -d
   ```
3. Service akan otomatis berjalan di:
   ```bash
   - Backend API: http://localhost:5000
   - Database: localhost:5432
   ```
4. Author  
   Bootcamp Project – Dumbways Indonesia
