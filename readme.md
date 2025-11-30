# APLIKASI TOKO KITA - CRUD FLUTTER

Nama: Jeskris Oktovianus Silahooy  
NIM: H1D023003  
Shift: A->C

---

## 1. PENGENALAN APLIKASI

Aplikasi Toko Kita adalah aplikasi mobile berbasis Flutter yang menerapkan sistem CRUD (Create, Read, Update, Delete) untuk manajemen data produk. Aplikasi ini terintegrasi dengan REST API berbasis CodeIgniter 4 dan menggunakan arsitektur Bloc Pattern untuk business logic.

Fitur Utama:
- Registrasi user baru
- Login dengan token authentication
- Tambah produk (Create)
- Lihat daftar produk (Read)
- Edit produk (Update)
- Hapus produk (Delete)

---

## 2. DEPENDENCIES

pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  http: ^0.13.4
  shared_preferences: ^2.0.11
```

Package yang digunakan:
- http ^0.13.4 - Untuk HTTP request ke REST API
- shared_preferences ^2.0.11 - Untuk menyimpan token di local storage

---

## 3. STRUKTUR PROJECT

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

## 4. IMPLEMENTASI HELPERS

### A. user_info.dart

Menangani penyimpanan dan pengambilan token dari SharedPreferences.

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

Fungsi:
- setToken() - Simpan token setelah login berhasil
- getToken() - Ambil token untuk setiap request ke API
- logout() - Hapus semua data saat logout

### B. app_exception.dart

Custom exception untuk error handling.

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

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}
```

### C. api.dart

Menangani semua HTTP request dengan Bearer Token.

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

### D. api_url.dart

Menyimpan endpoint API.

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

---

## 5. IMPLEMENTASI BLOC

### A. registrasi_bloc.dart

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

### B. login_bloc.dart

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

### C. logout_bloc.dart

```dart
import 'package:tokokita/helpers/user_info.dart';

class LogoutBloc {
  static Future logout() async {
    await UserInfo().logout();
  }
}
```

### D. produk_bloc.dart

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

## 6. PROSES LOGIN

### Step 1: Halaman Login (login_page.dart)

Screenshot Halaman Login:

<img width="429" height="872" alt="iPhone-13-PRO-localhost (25)" src="https://github.com/user-attachments/assets/38b475f7-71d3-4164-a8b4-a53ddffdddb1" />

Penjelasan: Halaman login menampilkan form dengan gradient background indigo-purple, input field email dan password, serta button LOGIN.

Kode Form Login:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("LOGIN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    child: isLoading 
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("LOGIN"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
```

### Step 2: Input Email dan Password

a. User memasukkan email: jes@gmail.com

<img width="429" height="872" alt="iPhone-13-PRO-localhost (25)" src="https://github.com/user-attachments/assets/34fe20ae-27c8-4dc6-944d-0bc231f6a4ab" />

Penjelasan: User mengetik email di field email. Email disimpan di emailController.

b. User memasukkan password: jes123

<img width="429" height="872" alt="iPhone-13-PRO-localhost (25)" src="https://github.com/user-attachments/assets/4c60db94-144a-42db-b86d-ab527f63945b" />

Penjelasan: User mengetik password. Field password menggunakan obscureText: true sehingga karakter tidak terlihat, hanya dot.

### Step 3: Klik Button LOGIN

Kode Proses Login (_submit function):

```dart
void _submit() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    var login = await LoginBloc.login(
      email: emailController.text,
      password: passwordController.text,
    );

    await UserInfo().setToken(login.token ?? '');
    await UserInfo().setUserID(login.userID ?? 0);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => ProdukPage()),
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) {
        return WarningDialog(
          description: e.toString(),
        );
      },
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
```

Penjelasan:
1. Form di-validate dulu
2. Set isLoading = true untuk menampilkan loading spinner
3. Panggil LoginBloc.login() dengan email dan password
4. Server return token dan userID
5. Simpan token dan userID ke SharedPreferences
6. Navigate ke ProdukPage dengan pushReplacement


### Step 4: Navigate ke Halaman Produk

<img width="429" height="872" alt="iPhone-13-PRO-localhost (26)" src="https://github.com/user-attachments/assets/5d58ec96-ccf2-4b22-809c-83522b2fed1f" />

Penjelasan: Setelah klik OK, navigate ke ProdukPage menggunakan pushReplacement. Halaman login ditutup dan halaman produk ditampilkan.

---

## 7. PROSES REGISTRASI

### Step 1: Klik Link Registrasi

<img width="429" height="872" alt="iPhone-13-PRO-localhost (25)" src="https://github.com/user-attachments/assets/81bb1efa-d8cd-4d21-bf7d-b33734f4edfb" />

Penjelasan: Di halaman login, ada text "Belum punya akun? Registrasi di sini". User klik link ini.

### Step 2: Halaman Registrasi Terbuka

<img width="429" height="872" alt="iPhone-13-PRO-localhost (23)" src="https://github.com/user-attachments/assets/41d918d3-3e0a-4738-918f-8895c62f64b6" />

Kode Form Registrasi:

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        controller: namaController,
        decoration: InputDecoration(labelText: "Nama (minimal 3 karakter)"),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Nama tidak boleh kosong";
          }
          if (value.length < 3) {
            return "Nama minimal 3 karakter";
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: emailController,
        decoration: InputDecoration(labelText: "Email"),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Email tidak boleh kosong";
          }
          if (!value.contains("@")) {
            return "Email tidak valid";
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: passwordController,
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          labelText: "Password (minimal 6 karakter)",
          suffixIcon: IconButton(
            icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() => _passwordVisible = !_passwordVisible);
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Password tidak boleh kosong";
          }
          if (value.length < 6) {
            return "Password minimal 6 karakter";
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: confirmPasswordController,
        obscureText: true,
        decoration: InputDecoration(labelText: "Konfirmasi Password"),
        validator: (value) {
          if (value != passwordController.text) {
            return "Password tidak sama";
          }
          return null;
        },
      ),
      SizedBox(height: 24),
      ElevatedButton(
        onPressed: _submit,
        child: isLoading 
            ? CircularProgressIndicator(color: Colors.white)
            : Text("DAFTAR"),
      ),
    ],
  ),
)
```

Penjelasan Form:
- Nama: validasi minimal 3 karakter
- Email: validasi harus ada @
- Password: validasi minimal 6 karakter, ada toggle show/hide
- Konfirmasi Password: harus sama dengan password

### Step 3: Isi Form Registrasi

<img width="429" height="872" alt="iPhone-13-PRO-localhost (23)" src="https://github.com/user-attachments/assets/4689b2fb-3330-4977-933a-3a7a3d90fd25" />

Contoh data:
- Nama: jes
- Email: jes@gmail.com
- Password: jes123
- Konfirmasi: jes123

### Step 4: Klik Button DAFTAR

Kode Proses Registrasi:

```dart
void _submit() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    var registrasi = await RegistrasiBloc.registrasi(
      nama: namaController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    showDialog(
      context: context,
      builder: (context) {
        return SuccessDialog(
          description: "Registrasi berhasil! Silakan login.",
          okClick: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        );
      },
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) {
        return WarningDialog(
          description: e.toString(),
        );
      },
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
```

Penjelasan:
1. Validate form
2. Set isLoading = true
3. Panggil RegistrasiBloc.registrasi() dengan nama, email, password
4. Jika berhasil, tampilkan SuccessDialog
5. Klik OK, navigate ke LoginPage
6. Jika gagal, tampilkan WarningDialog dengan error message

### Step 5: Registrasi Berhasil

<img width="429" height="872" alt="iPhone-13-PRO-localhost (24)" src="https://github.com/user-attachments/assets/6cbde625-0176-4642-92ad-9973f9d0302a" />

### Step 7: Navigate ke Login

<img width="429" height="872" alt="iPhone-13-PRO-localhost (25)" src="https://github.com/user-attachments/assets/0eb38e4e-ad29-47ec-a293-2d3d39517fe4" />

Penjelasan: Setelah klik OK di success dialog, navigate ke LoginPage. User bisa login dengan akun yang baru didaftar.

---

## 8. PROSES CRUD PRODUK

### A. READ - Lihat Daftar Produk

#### Screenshot Halaman Produk List

<img width="429" height="872" alt="iPhone-13-PRO-localhost (26)" src="https://github.com/user-attachments/assets/53dccdab-898b-478a-82e8-ad27ebd09ce3" />

Penjelasan: Halaman menampilkan list produk dari API. Setiap item menampilkan kode produk, nama, dan harga.

Kode FutureBuilder:

```dart
FutureBuilder<List<Produk>>(
  future: ProdukBloc.getProduks(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text("Error: ${snapshot.error}"));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text("Tidak ada produk"));
    } else {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          Produk produk = snapshot.data![index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProdukDetail(produk: produk),
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: Text(produk.namaProduk ?? ""),
                subtitle: Text("Rp ${produk.hargaProduk}"),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.shopping_bag, color: Colors.white),
                ),
              ),
            ),
          );
        },
      );
    }
  },
)
```

Penjelasan:
- FutureBuilder memanggil ProdukBloc.getProduks()
- Jika loading, tampilkan loading spinner
- Jika ada error, tampilkan error message
- Jika ada data, tampilkan ListView dari daftar produk
- Setiap item clickable untuk buka detail produk

### B. CREATE - Tambah Produk

#### Step 1: Klik Button "Tambah Produk"

<img width="429" height="872" alt="iPhone-13-PRO-localhost (27)" src="https://github.com/user-attachments/assets/216cfebe-dde0-4d68-a76a-edb0de4e2284" />

Penjelasan: Di AppBar halaman produk list, ada button "Tambah Produk". User klik button ini untuk navigate ke form tambah produk.

Kode Button:

```dart
AppBar(
  title: Text("Daftar Produk"),
  actions: [
    ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProdukForm(),
          ),
        );
      },
      icon: Icon(Icons.add),
      label: Text("Tambah"),
    ),
  ],
)
```

#### Step 2: Halaman Form Tambah Produk

<img width="429" height="872" alt="iPhone-13-PRO-localhost (28)" src="https://github.com/user-attachments/assets/6a2c3b59-f716-445f-a7e9-ce88db89be37" />

Penjelasan: Form menampilkan 3 field input: kode produk, nama produk, dan harga.

Kode Form Tambah:

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        controller: kodeController,
        decoration: InputDecoration(labelText: "Kode Produk"),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Kode tidak boleh kosong";
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: namaController,
        decoration: InputDecoration(labelText: "Nama Produk"),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Nama tidak boleh kosong";
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: hargaController,
        decoration: InputDecoration(labelText: "Harga"),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Harga tidak boleh kosong";
          }
          return null;
        },
      ),
      SizedBox(height: 24),
      ElevatedButton(
        onPressed: _submit,
        child: isLoading 
            ? CircularProgressIndicator(color: Colors.white)
            : Text("SIMPAN"),
      ),
    ],
  ),
)
```

#### Step 3: Isi Form

<img width="429" height="872" alt="iPhone-13-PRO-localhost (28)" src="https://github.com/user-attachments/assets/d60241ca-a5c0-4cde-b761-0c09463eea70" />

Contoh data:
- Kode: JKW001
- Nama: Mobil EsEMKA
- Harga: 20000000

#### Step 4: Klik Button SIMPAN

Kode Proses Tambah Produk:

```dart
void _submit() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    Produk produk = Produk(
      kodeProduk: kodeController.text,
      namaProduk: namaController.text,
      hargaProduk: int.parse(hargaController.text),
    );

    await ProdukBloc.addProduk(produk: produk);

    showDialog(
      context: context,
      builder: (context) {
        return SuccessDialog(
          description: "Produk berhasil ditambahkan!",
          okClick: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) {
        return WarningDialog(
          description: e.toString(),
        );
      },
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
```

Penjelasan:
1. Validate form
2. Buat object Produk dari input form
3. Panggil ProdukBloc.addProduk() dengan object Produk
4. Jika berhasil, tampilkan SuccessDialog
5. Klik OK, pop dialog dan pop page, kembali ke list produk
6. Data baru sudah ada di list

#### Step 5: Kembali ke List

<img width="429" height="872" alt="iPhone-13-PRO-localhost (29)" src="https://github.com/user-attachments/assets/e9e42a08-4c66-47b9-be0e-fa35ee08e5df" />

Penjelasan: Setelah klik OK di success dialog, navigate back ke halaman list. Produk baru sudah tampil di list.

### C. UPDATE - Edit Produk

#### Step 1: Buka Halaman Detail Produk

<img width="429" height="872" alt="iPhone-13-PRO-localhost (32)" src="https://github.com/user-attachments/assets/3a540711-a435-4d0d-bd2a-9aba1533bda4" />

Penjelasan: Dari list produk, user klik item produk untuk membuka detail. Di halaman detail, ada button EDIT.

#### Step 2: Klik Button EDIT

Kode Button EDIT:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProdukForm(produk: widget.produk),
      ),
    );
  },
  child: Text("EDIT"),
)
```

#### Step 3: Halaman Form Edit

<img width="429" height="872" alt="iPhone-13-PRO-localhost (31)" src="https://github.com/user-attachments/assets/007451d4-46d8-4ca8-8c53-68c6ccbcb8c6" />

Penjelasan: Form menampilkan data produk yang lama (sudah terisi). User bisa ubah data.

Kode Form Edit (pre-fill):

```dart
@override
void initState() {
  super.initState();
  if (widget.produk != null) {
    kodeController.text = widget.produk!.kodeProduk ?? "";
    namaController.text = widget.produk!.namaProduk ?? "";
    hargaController.text = widget.produk!.hargaProduk.toString();
    isEdit = true;
  }
}
```

#### Step 4: Ubah Data

<img width="429" height="872" alt="iPhone-13-PRO-localhost (32)" src="https://github.com/user-attachments/assets/4697420a-1df7-4d8f-88c4-929a4284e624" />

Contoh perubahan:
- Harga dari 5000000 menjadi 4800000

#### Step 5: Klik Button UBAH

Kode Proses Edit Produk:

```dart
void _submit() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    Produk produk = Produk(
      id: widget.produk!.id,
      kodeProduk: kodeController.text,
      namaProduk: namaController.text,
      hargaProduk: int.parse(hargaController.text),
    );

    await ProdukBloc.updateProduk(produk: produk);

    showDialog(
      context: context,
      builder: (context) {
        return SuccessDialog(
          description: "Produk berhasil diubah!",
          okClick: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) {
        return WarningDialog(
          description: e.toString(),
        );
      },
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
```

Penjelasan:
1. Validate form
2. Buat object Produk dengan ID yang sama (untuk identify produk mana yang di-edit)
3. Panggil ProdukBloc.updateProduk()
4. Jika berhasil, tampilkan SuccessDialog
5. Klik OK, pop 3 layer (dialog, form, detail) untuk kembali ke list
6. Data di list sudah ter-update


#### Step 6: Lihat Hasil Update

<img width="429" height="872" alt="iPhone-13-PRO-localhost (33)" src="https://github.com/user-attachments/assets/7108a153-f91e-49d5-9fe2-585c75a4a18b" />

### D. DELETE - Hapus Produk

#### Step 1: Buka Halaman Detail Produk

[INSERT SCREENSHOT: Halaman detail dengan button HAPUS]

#### Step 2: Klik Button HAPUS

Kode Button HAPUS:

```dart
ElevatedButton(
  onPressed: _showDeleteDialog,
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  child: Text("HAPUS"),
)
```

#### Step 3: Confirmation Dialog

[INSERT SCREENSHOT: Dialog konfirmasi "Yakin ingin menghapus?"]

Kode Confirmation Dialog:

```dart
void _showDeleteDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Konfirmasi"),
        content: Text("Yakin ingin menghapus produk ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("TIDAK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteProduk();
            },
            child: Text("YA"),
          ),
        ],
      );
    },
  );
}
```

#### Step 4: Klik YA untuk Confirm

[INSERT SCREENSHOT: Dialog hilang, loading spinner]

#### Step 5: Proses Hapus

Kode Proses Delete:

```dart
void _deleteProduk() async {
  try {
    setState(() {
      isLoading = true;
    });

    await ProdukBloc.deleteProduk(id: int.parse(widget.produk.id!));

    showDialog(
      context: context,
      builder: (context) {
        return SuccessDialog(
          description: "Produk berhasil dihapus!",
          okClick: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) {
        return WarningDialog(
          description: e.toString(),
        );
      },
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
```

Penjelasan:
1. Kirim DELETE request ke API dengan produk ID
2. Jika berhasil, tampilkan SuccessDialog
3. Klik OK, pop 3 layer untuk kembali ke list
4. Produk sudah hilang dari list

#### Step 6: Sukses Hapus

[INSERT SCREENSHOT: SuccessDialog "Produk berhasil dihapus"]

#### Step 7: List Ter-update

[INSERT SCREENSHOT: List produk tanpa item yang dihapus]

---
