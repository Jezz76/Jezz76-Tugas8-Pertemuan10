# TokoGW - Aplikasi Manajemen Produk

Aplikasi Flutter untuk manajemen produk toko dengan fitur Login, Registrasi, dan CRUD Produk.

---

## 📱 Screenshot dan Penjelasan Kode

### 1. Halaman Login - Jes

![Screenshot Login](screenshots/login.png)

**Penjelasan Kode:**
```dart
// Validasi Email dengan Regex
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email harus diisi';
  }
  final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
  if (!regex.hasMatch(value.trim())) {
    return 'Email tidak valid';
  }
  return null;
}

// Routing ke Halaman Produk setelah Login
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const ProdukPage()),
);
```

**Fitur:**
- Validasi format email
- Password visibility toggle
- Loading state
- Redirect ke halaman produk

---

### 2. Halaman Registrasi - Jes

![Screenshot Registrasi](screenshots/registrasi.png)

**Penjelasan Kode:**
```dart
// Validasi Konfirmasi Password
validator: (value) {
  if (value == null || value != _passwordTextboxController.text) {
    return 'Konfirmasi Password tidak sama';
  }
  return null;
}

// Kembali ke Login setelah Registrasi
Navigator.pop(context);
```

**Fitur:**
- Form 4 field (nama, email, password, konfirmasi)
- Validasi password match
- Auto redirect ke login

---

### 3. Halaman List Produk - Jes

![Screenshot List Produk](screenshots/list_produk.png)

**Penjelasan Kode:**
```dart
// Format Currency
String _formatCurrency(int amount) {
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
}

// Navigasi ke Detail
InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProdukDetail(produk: produk),
      ),
    );
  },
  child: // ... card produk
)
```

**Fitur:**
- Statistik total produk & nilai
- Card produk dengan format currency
- Drawer menu dengan logout
- Navigasi ke tambah/detail produk

---

### 4. Halaman Tambah Produk - Jes

![Screenshot Tambah Produk](screenshots/tambah_produk.png)

**Penjelasan Kode:**
```dart
// Validasi Harga
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Harga harus diisi';
  }
  if (int.tryParse(value) == null) {
    return 'Harga harus berupa angka';
  }
  return null;
}
```

**Fitur:**
- Form 3 field (kode, nama, harga)
- Validasi semua field
- SnackBar notifikasi

---

### 5. Halaman Ubah Produk - Jes

![Screenshot Ubah Produk](screenshots/ubah_produk.png)

**Penjelasan Kode:**
```dart
// Auto-fill form untuk Edit
void isUpdate() {
  if (widget.produk != null) {
    setState(() {
      judul = "Ubah Produk - Jes";
      tombolSubmit = "UBAH";
      _kodeProdukTextboxController.text = widget.produk!.kodeProduk!;
      _namaProdukTextboxController.text = widget.produk!.namaProduk!;
      _hargaProdukTextboxController.text = 
          widget.produk!.hargaProduk.toString();
    });
  } else {
    judul = "Tambah Produk - Jes";
    tombolSubmit = "SIMPAN";
  }
}
```

**Fitur:**
- Form auto-fill data existing
- Mode dinamis (tambah/ubah)
- Update data produk

---

### 6. Halaman Detail Produk - Jes

![Screenshot Detail Produk](screenshots/detail_produk.png)

**Penjelasan Kode:**
```dart
// Widget Info Row dengan Icon
Widget _buildInfoRow({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ],
  );
}
```

**Fitur:**
- Info produk lengkap dengan icon berwarna
- Tombol Edit & Hapus
- Dialog konfirmasi hapus

---

### 7. Dialog Konfirmasi Hapus

![Screenshot Dialog Hapus](screenshots/dialog_hapus.png)

**Penjelasan Kode:**
```dart
void confirmHapus() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            child: const Text('BATAL'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('HAPUS'),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke list
            },
          ),
        ],
      );
    },
  );
}
```

**Fitur:**
- Konfirmasi sebelum hapus
- Pop 2x (dialog + detail page)

---

## 🔄 Flow Routing

```
[Login] → [Registrasi]
   ↓           ↓
   └──→ [List Produk] ←──┘
           ↓
   ┌───────┼────────┐
   ↓       ↓        ↓
[Tambah] [Detail] [Logout]
         ↓    ↓
      [Edit] [Hapus]
```

**Routing:**
- `Navigator.pushReplacement()` → Login ke List, Logout ke Login
- `Navigator.push()` → List ke Detail/Form
- `Navigator.pop()` → Registrasi ke Login, Form/Detail ke List

---

## 📁 Struktur File

```
lib/
├── main.dart                 # Entry point + Theme
├── model/
│   ├── produk.dart
│   ├── login.dart
│   └── registrasi.dart
└── ui/
    ├── login_page.dart
    ├── registrasi_page.dart
    ├── produk_page.dart
    ├── produk_form.dart
    └── produk_detail.dart
```

---

