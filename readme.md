# Aplikasi Toko Kita - CRUD Flutter dengan REST API

Nama: Jeskris Oktovianus Silahooy (H1D023003)

---

## Dependencies

File: pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  http: ^0.13.4
  shared_preferences: ^2.0.11
```

Jalankan: `flutter pub get`

---

## Struktur Project

```
lib/
├── main.dart
├── helpers/
│   ├── user_info.dart
│   ├── app_exception.dart
│   ├── api.dart
│   └── api_url.dart
├── bloc/
│   ├── registrasi_bloc.dart
│   ├── login_bloc.dart
│   ├── logout_bloc.dart
│   └── produk_bloc.dart
├── model/
│   ├── login.dart
│   ├── registrasi.dart
│   └── produk.dart
├── ui/
│   ├── login_page.dart
│   ├── registrasi_page.dart
│   ├── produk_page.dart
│   ├── produk_form.dart
│   └── produk_detail.dart
└── widget/
    ├── success_dialog.dart
    └── warning_dialog.dart
```

---

## Implementasi Helpers

### 1. user_info.dart

Menangani penyimpanan dan pengambilan token serta user ID menggunakan SharedPreferences.

```dart
import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  Future setToken(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString("token", value);
  }

  Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("token");
  }

  Future setUserID(int value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setInt("userID", value);
  }

  Future<int?> getUserID() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt("userID");
  }

  Future logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }
}
```

**Fungsi:**
- setToken() - Menyimpan token
- getToken() - Mengambil token
- setUserID() - Menyimpan user ID
- getUserID() - Mengambil user ID
- logout() - Menghapus semua data

---

### 2. app_exception.dart

Mendefinisikan custom exception classes untuk error handling.

```dart
class AppException implements Exception {
  final _message;
  final _prefix;
  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class UnprocessableEntityException extends AppException {
  UnprocessableEntityException([message])
      : super(message, "Unprocessable Entity: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}
```

---

### 3. api.dart

Menangani semua HTTP request (GET, POST, PUT, DELETE) dengan Bearer Token.

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tokokita/helpers/user_info.dart';
import 'app_exception.dart';

class Api {
  Future<dynamic> post(dynamic url, dynamic data) async {
    var token = await UserInfo().getToken();
    var responseJson;
    try {
      final response = await http.post(Uri.parse(url),
          body: data,
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> get(dynamic url) async {
    var token = await UserInfo().getToken();
    var responseJson;
    try {
      final response = await http.get(Uri.parse(url),
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> put(dynamic url, dynamic data) async {
    var token = await UserInfo().getToken();
    var responseJson;
    try {
      final response = await http.put(Uri.parse(url), body: data, headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json"
      });
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> delete(dynamic url) async {
    var token = await UserInfo().getToken();
    var responseJson;
    try {
      final response = await http.delete(Uri.parse(url),
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return response;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 422:
        throw InvalidInputException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
```

---

### 4. api_url.dart

Menyimpan semua URL endpoint API.

```dart
class ApiUrl {
  static const String baseUrl = 'http://10.99.4.182:8080/tokokita/public';

  static const String registrasi = baseUrl + '/registrasi';
  static const String login = baseUrl + '/login';
  static const String listProduk = baseUrl + '/produk';
  static const String createProduk = baseUrl + '/produk';

  static String updateProduk(int id) {
    return baseUrl + '/produk/' + id.toString();
  }

  static String showProduk(int id) {
    return baseUrl + '/produk/' + id.toString();
  }

  static String deleteProduk(int id) {
    return baseUrl + '/produk/' + id.toString();
  }
}
```

Catatan: Ubah IP address sesuai dengan server lokal Anda.

---

## Implementasi Bloc

### 1. registrasi_bloc.dart

Menangani proses registrasi user.

```dart
import 'dart:convert';
import 'package:tokokita/helpers/api.dart';
import 'package:tokokita/helpers/api_url.dart';
import 'package:tokokita/model/registrasi.dart';

class RegistrasiBloc {
  static Future<Registrasi> registrasi({
    String? nama,
    String? email,
    String? password
  }) async {
    String apiUrl = ApiUrl.registrasi;
    var body = {"nama": nama, "email": email, "password": password};
    var response = await Api().post(apiUrl, body);
    var jsonObj = json.decode(response.body);
    return Registrasi.fromJson(jsonObj);
  }
}
```

---

### 2. login_bloc.dart

Menangani proses login user.

```dart
import 'dart:convert';
import 'package:tokokita/helpers/api.dart';
import 'package:tokokita/helpers/api_url.dart';
import 'package:tokokita/model/login.dart';

class LoginBloc {
  static Future<Login> login({
    String? email,
    String? password
  }) async {
    String apiUrl = ApiUrl.login;
    var body = {"email": email, "password": password};
    var response = await Api().post(apiUrl, body);
    var jsonObj = json.decode(response.body);
    return Login.fromJson(jsonObj);
  }
}
```

---

### 3. logout_bloc.dart

Menangani proses logout user.

```dart
import 'package:tokokita/helpers/user_info.dart';

class LogoutBloc {
  static Future logout() async {
    await UserInfo().logout();
  }
}
```

---

### 4. produk_bloc.dart

Menangani CRUD produk.

```dart
import 'dart:convert';
import 'package:tokokita/helpers/api.dart';
import 'package:tokokita/helpers/api_url.dart';
import 'package:tokokita/model/produk.dart';

class ProdukBloc {
  static Future<List<Produk>> getProduks() async {
    String apiUrl = ApiUrl.listProduk;
    var response = await Api().get(apiUrl);
    var jsonObj = json.decode(response.body);
    List<dynamic> listProduk = (jsonObj as Map<String, dynamic>)['data'];
    List<Produk> produks = [];
    for (int i = 0; i < listProduk.length; i++) {
      produks.add(Produk.fromJson(listProduk[i]));
    }
    return produks;
  }

  static Future addProduk({Produk? produk}) async {
    String apiUrl = ApiUrl.createProduk;
    var body = {
      "kode_produk": produk!.kodeProduk,
      "nama_produk": produk.namaProduk,
      "harga": produk.hargaProduk.toString()
    };
    var response = await Api().post(apiUrl, body);
    var jsonObj = json.decode(response.body);
    return jsonObj['status'];
  }

  static Future updateProduk({required Produk produk}) async {
    String apiUrl = ApiUrl.updateProduk(int.parse(produk.id!));
    var body = {
      "kode_produk": produk.kodeProduk,
      "nama_produk": produk.namaProduk,
      "harga": produk.hargaProduk.toString()
    };
    var response = await Api().put(apiUrl, jsonEncode(body));
    var jsonObj = json.decode(response.body);
    return jsonObj['status'];
  }

  static Future<bool> deleteProduk({int? id}) async {
    String apiUrl = ApiUrl.deleteProduk(id!);
    var response = await Api().delete(apiUrl);
    var jsonObj = json.decode(response.body);
    return (jsonObj as Map<String, dynamic>)['data'];
  }
}
```

---

## Implementasi UI Pages

### 1. login_page.dart

Halaman login dengan form email dan password.

Fitur:
- Form input email dan password
- Validasi email dan password
- Loading state saat login
- Link ke halaman registrasi
- Auto-login jika token masih valid

[SCREENSHOT LOGIN PAGE]

---

### 2. registrasi_page.dart

Halaman registrasi dengan form lengkap.

Fitur:
- Form input nama, email, password, konfirmasi password
- Validasi lengkap (minimal 3 karakter untuk nama, 6 untuk password)
- Loading indicator saat registrasi
- Success dialog yang navigate ke login page
- Password visibility toggle

[SCREENSHOT REGISTRASI PAGE]

---

### 3. produk_page.dart

Halaman list produk dengan fitur CRUD.

Fitur:
- Menampilkan list produk dari API
- FutureBuilder untuk loading state
- Button tambah produk di AppBar
- Logout di drawer
- Item produk clickable untuk detail

[SCREENSHOT PRODUCT LIST PAGE]

---

### 4. produk_form.dart

Halaman form untuk tambah dan edit produk.

Fitur:
- Form input kode produk, nama, dan harga
- Validasi input
- Dynamic button (SIMPAN untuk tambah, UBAH untuk edit)
- Loading state
- Pre-fill data untuk edit mode

[SCREENSHOT FORM TAMBAH PRODUK]

[SCREENSHOT FORM EDIT PRODUK]

---

### 5. produk_detail.dart

Halaman detail produk dengan edit dan delete.

Fitur:
- Menampilkan detail produk
- Format harga dengan Rp
- Button EDIT untuk buka form edit
- Button HAPUS dengan confirmation dialog
- Delete request ke API

[SCREENSHOT PRODUCT DETAIL]

[SCREENSHOT CONFIRM DELETE]

---

## Implementasi Widget Dialog

### 1. success_dialog.dart

Dialog untuk menampilkan pesan sukses.

```dart
import 'package:flutter/material.dart';

class Consts {
  Consts._();
  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}

class SuccessDialog extends StatelessWidget {
  final String? description;
  final VoidCallback? okClick;

  const SuccessDialog({Key? key, this.description, this.okClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(top: 66.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "SUKSES",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
          const SizedBox(height: 12.0),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
          const SizedBox(height: 24.0),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                okClick!();
              },
              child: const Text("OK"),
            ),
          )
        ],
      ),
    );
  }
}
```

---

### 2. warning_dialog.dart

Dialog untuk menampilkan pesan error atau warning.

```dart
import 'package:flutter/material.dart';

class Consts {
  Consts._();
  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}

class WarningDialog extends StatelessWidget {
  final String? description;
  final VoidCallback? okClick;

  const WarningDialog({Key? key, this.description, this.okClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(top: 66.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel,
              color: Colors.red,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "GAGAL",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.red),
          ),
          const SizedBox(height: 12.0),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
          const SizedBox(height: 24.0),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          )
        ],
      ),
    );
  }
}
```

---

## Cara Menjalankan

### Setup Server CodeIgniter 4

```bash
cd project-ci4
php spark serve --host 10.99.4.182 --port 8080
```

### Setup Flutter Application

1. Update API URL di file `lib/helpers/api_url.dart`:
   ```dart
   static const String baseUrl = 'http://10.99.4.182:8080/tokokita/public';
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run application:
   
   Web (Chrome):
   ```bash
   flutter run -d chrome --web-browser-flag "--disable-web-security"
   ```
   
   Web (Edge):
   ```bash
   flutter run -d edge
   ```
   
   Emulator/Device:
   ```bash
   flutter run
   ```

---

## Testing

### Test Login
1. Buka aplikasi
2. Masukkan email: admin@test.com
3. Masukkan password: admin123
4. Klik LOGIN
5. Seharusnya navigate ke halaman Product List

### Test Registrasi
1. Klik "Registrasi"
2. Isi form dengan data baru
3. Klik DAFTAR
4. Seharusnya muncul success dialog
5. Klik OK untuk kembali ke login

### Test CRUD Produk

CREATE:
1. Klik tombol Tambah di AppBar
2. Isi form kode, nama, harga
3. Klik SIMPAN
4. Seharusnya kembali ke list produk

READ:
1. Lihat list produk di halaman utama
2. Klik salah satu item

UPDATE:
1. Klik item untuk buka detail
2. Klik EDIT
3. Ubah data produk
4. Klik UBAH
5. Seharusnya kembali ke list dengan data terupdate

DELETE:
1. Klik item untuk buka detail
2. Klik HAPUS
3. Confirm dengan klik YA
4. Seharusnya kembali ke list dan produk sudah dihapus

---

## Screenshot

### Halaman Login

Menampilkan form login dengan email dan password.

![Login Page]

---

### Halaman Registrasi

Form registrasi untuk membuat akun baru dengan validasi lengkap.

![Registrasi Page]

---

### Halaman List Produk

Menampilkan daftar semua produk dengan tombol tambah di AppBar.

![Product List Page]

---

### Halaman Tambah Produk

Form untuk menambah produk baru dengan input kode, nama, dan harga.

![Form Tambah Produk]

---

### Halaman Detail Produk

Menampilkan detail lengkap produk dengan tombol edit dan hapus.

![Product Detail]

---

### Halaman Edit Produk

Form untuk mengubah data produk yang sudah ada.

![Form Edit Produk]

---

### Dialog Konfirmasi Hapus

Dialog konfirmasi sebelum menghapus produk.

![Confirm Delete Dialog]

---

### Dialog Sukses

Dialog yang tampil setelah operasi berhasil dilakukan.

![Success Dialog]

---

### Dialog Error

Dialog yang tampil ketika terjadi kesalahan.

![Error Dialog]

---