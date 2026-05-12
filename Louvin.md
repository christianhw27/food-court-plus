# Dokumentasi Integrasi Louvin Payment Gateway

Dokumentasi ini berisi panduan lengkap untuk mengintegrasikan layanan pembayaran Louvin, baik menggunakan API secara langsung maupun menggunakan SDK JavaScript yang tersedia.

## Quick Start (Memulai Cepat)

1. **Buat Project di Dashboard**, Masuk ke Dashboard, pilih menu Proyek, lalu klik Buat Proyek. Anda akan mendapatkan API key unik yang dimulai dengan prefix `lv_`.
2. **Buat Transaksi**, Gunakan endpoint API untuk menginisiasi pembayaran.
3. **Terima Notifikasi**, Atur Webhook URL di pengaturan proyek. Louvin akan mengirimkan HTTP POST setiap kali status transaksi berubah.

### Contoh Pembuatan Transaksi (Fetch API)

```javascript
const res = await fetch("https://api.louvin.dev/create-transaction", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "x-api-key": "lv_your_api_key_here",
  },
  body: JSON.stringify({
    amount: 50000,
    payment_type: "qris",
    customer_name: "John Doe",
  }),
});

const data = await res.json();
// data.payment.qr_string: tampilkan sebagai QR code ke pelanggan
// data.payment.va_number: tampilkan nomor VA ke pelanggan
```

---

## Louvin SDK

Louvin menyediakan SDK JavaScript ringan untuk integrasi yang lebih cepat. SDK ini bekerja tanpa dependency tambahan dan dapat berjalan di lingkungan browser maupun Node.js.

### Instalasi

Anda dapat menggunakan CDN atau modul ES untuk memuat SDK:

**Menggunakan CDN:**

```html
<script src="https://louvin.dev/sdk/louvin.min.js"></script>
```

**Menggunakan ES Module:**

```javascript
<script type="module">
  import {Louvin} from 'https://louvin.dev/sdk/louvin.js';
</script>
```

### Penggunaan SDK: Buat Pembayaran

```javascript
const louvin = new Louvin("lv_your_api_key");

const result = await louvin.createPayment({
  amount: 50000,
  payment_type: "qris",
  customer_name: "John Doe",
  description: "Order #123",
});

console.log(result.payment.qr_string);
console.log(result.transaction.id);
```

### Shortcut Methods (Metode Singkat)

SDK juga menyediakan metode cepat untuk jenis pembayaran spesifik:

```javascript
await louvin.createQRIS(50000, { customer_name: "John" });
await louvin.createBNI(100000);
await louvin.createBRI(100000);
await louvin.createPermata(100000);
await louvin.createCIMB(100000);
```

---

## Autentikasi

Setiap permintaan API wajib menyertakan API key di bagian header. API key ini bersifat rahasia dan bisa didapatkan melalui Dashboard pada bagian Detail Proyek.

| Header           | Nilai (Value)                              |
| ---------------- | ------------------------------------------ |
| **Content-Type** | `application/json`                         |
| **x-api-key**    | API key proyek Anda (dimulai dengan `lv_`) |

**Contoh Request menggunakan CURL:**

```bash
curl -X POST https://api.louvin.dev/create-transaction \
  -H "Content-Type: application/json" \
  -H "x-api-key: lv_your_api_key_here" \
  -d '{"amount": 50000, "payment_type": "qris"}'

```

> ⚠️ **PENTING:** Jangan mengekspos API key di sisi client (frontend) pada lingkungan produksi. Gunakan backend proxy untuk menjaga keamanan.

---

## Biaya Transaksi (Pricing)

Biaya layanan akan dihitung secara otomatis untuk setiap transaksi. Tidak ada biaya berlangganan bulanan atau biaya pendaftaran.

| Metode              | Fee           | Keterangan                 |
| ------------------- | ------------- | -------------------------- |
| **QRIS / E-Wallet** | 0.7% + Rp 400 | Minimal transaksi Rp 1.500 |
| **Virtual Account** | Rp 6.500      | Biaya flat per transaksi   |

### Contoh Perhitungan

Jika fitur `fee_on_customer` aktif (pengaturan default), maka biaya akan ditambahkan ke total pembayaran pelanggan. Merchant tetap menerima jumlah bersih (net amount).

| Contoh            | Amount  | Fee   | Pelanggan Bayar | Merchant Terima |
| ----------------- | ------- | ----- | --------------- | --------------- |
| QRIS Rp 50.000    | 50.000  | 750   | 50.750          | 50.000          |
| BNI VA Rp 100.000 | 100.000 | 6.500 | 106.500         | 100.000         |

---

## API Reference: Create Transaction

**Endpoint:** `POST /create-transaction`

### Request Body

| Parameter        | Tipe   | Wajib | Deskripsi                                |
| ---------------- | ------ | ----- | ---------------------------------------- |
| `amount`         | number | ✅    | Jumlah dalam Rupiah (Min: 1, QRIS: 1500) |
| `payment_type`   | string | ✅    | Kode metode pembayaran                   |
| `customer_name`  | string |       | Nama pelanggan                           |
| `customer_email` | string |       | Email pelanggan                          |
| `description`    | string |       | Deskripsi singkat transaksi              |
| `reference`      | string |       | ID unik dari sistem Anda (opsional)      |

### Format Respon: QRIS (201 Created)

```json
{
  "success": true,
  "transaction": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "amount": 50750,
    "fee": 750,
    "net_amount": 50000,
    "status": "pending",
    "reference": "550e8400-1711234567890-a1b2c3",
    "fee_on_customer": true,
    "created_at": "2026-03-09T10:30:00Z"
  },
  "payment": {
    "order_id": "550e8400-1711234567890-a1b2c3",
    "payment_type": "qris",
    "qr_string": "00020101021226...",
    "payment_number": "00020101021226...",
    "expired_at": "2026-03-09T10:45:00Z",
    "total_payment": 50750
  }
}
```

---

## Webhooks

Louvin akan mengirimkan data status transaksi ke URL yang Anda tentukan melalui metode HTTP POST.

### Payload Webhook

```json
{
  "event": "payment.settled",
  "data": {
    "transaction_id": "550e8400-e29b-41d4-a716-446655440000",
    "status": "settled",
    "net_amount": 50000
  }
}
```

### Event Types

- `payment.settled`: Pembayaran berhasil dikonfirmasi.
- `payment.failed`: Pembayaran gagal, ditolak, atau kedaluwarsa.
- `payment.pending`: Menunggu pembayaran dari pelanggan.

---

## Subscription (Pembayaran Berulang)

Fitur ini memungkinkan pembuatan paket langganan secara otomatis.

1. **Alur Kerja**: Merchant membuat Plan di dashboard, pelanggan melakukan subscribe, dan sistem akan mengirimkan email QRIS secara otomatis H-1 sebelum masa aktif berakhir.
2. **Otomasi**: Perpanjangan masa aktif dilakukan secara otomatis oleh sistem setelah pembayaran diterima.

### SDK Subscription

```javascript
const sub = await louvin.createSubscription({
  plan_id: "plan-uuid-from-dashboard",
  customer_email: "customer@example.com",
  customer_name: "John Doe",
});
```

---

## Error Handling

Jika terjadi kendala, API akan mengembalikan kode status HTTP tertentu beserta detail kesalahan dalam format JSON.

| Status  | Penyebab              | Solusi                                     |
| ------- | --------------------- | ------------------------------------------ |
| **400** | Parameter tidak valid | Periksa validasi input (misal: min amount) |
| **401** | API key tidak valid   | Pastikan header `x-api-key` sudah benar    |
| **404** | Data tidak ditemukan  | Periksa kembali ID transaksi yang dicari   |
| **500** | Server error          | Silakan hubungi tim support Louvin         |

---
