import 'package:tokokita/model/login.dart';
import 'package:tokokita/model/produk.dart';
import 'package:tokokita/model/registrasi.dart';

class MockApi {
  // Mock data untuk users (simulasi database)
  static final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'nama': 'Admin',
      'email': 'admin@test.com',
      'password': 'admin123'
    },
    {
      'id': 2,
      'nama': 'Jes',
      'email': 'jes@test.com',
      'password': 'jes12345'
    },
  ];

  // Mock data untuk produk
  static final List<Map<String, dynamic>> _produk = [
    {
      'id': 1,
      'kode_produk': 'PRD001',
      'nama_produk': 'Laptop ASUS',
      'harga': 8000000
    },
    {
      'id': 2,
      'kode_produk': 'PRD002',
      'nama_produk': 'Mouse Wireless',
      'harga': 250000
    },
    {
      'id': 3,
      'kode_produk': 'PRD003',
      'nama_produk': 'Keyboard Mechanical',
      'harga': 1200000
    },
  ];

  // Simulasi registrasi
  static Future<Registrasi> registrasi(
      {String? nama, String? email, String? password}) async {
    await Future.delayed(Duration(seconds: 1));

    // Cek apakah email sudah terdaftar
    bool emailExists = _users.any((user) => user['email'] == email);
    if (emailExists) {
      throw Exception('Email sudah terdaftar');
    }

    // Tambah user baru
    int newId = _users.isEmpty ? 1 : (_users.last['id'] as int) + 1;
    _users.add({
      'id': newId,
      'nama': nama,
      'email': email,
      'password': password,
    });

    return Registrasi(
      code: 200,
      status: true,
      data: 'Registrasi berhasil',
    );
  }

  // Simulasi login
  static Future<Login> login({String? email, String? password}) async {
    await Future.delayed(Duration(seconds: 1));

    // Cari user dengan email dan password
    var user = _users.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) {
      return Login(
        code: 401,
        status: false,
      );
    }

    return Login(
      code: 200,
      status: true,
      token: 'mock_token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}',
      userId: user['id'],
      userEmail: user['email'],
    );
  }

  // Simulasi get list produk
  static Future<List<Produk>> getProduks() async {
    await Future.delayed(Duration(seconds: 1));

    List<Produk> produks = [];
    for (var p in _produk) {
      produks.add(Produk(
        id: p['id'].toString(),
        kodeProduk: p['kode_produk'],
        namaProduk: p['nama_produk'],
        hargaProduk: p['harga'],
      ));
    }
    return produks;
  }

  // Simulasi add produk
  static Future<bool> addProduk({
    String? kodeProduk,
    String? namaProduk,
    int? harga,
  }) async {
    await Future.delayed(Duration(seconds: 1));

    int newId = _produk.isEmpty ? 1 : (_produk.last['id'] as int) + 1;
    _produk.add({
      'id': newId,
      'kode_produk': kodeProduk,
      'nama_produk': namaProduk,
      'harga': harga,
    });

    return true;
  }

  // Simulasi update produk
  static Future<bool> updateProduk({
    int? id,
    String? kodeProduk,
    String? namaProduk,
    int? harga,
  }) async {
    await Future.delayed(Duration(seconds: 1));

    int index = _produk.indexWhere((p) => p['id'] == id);
    if (index == -1) {
      throw Exception('Produk tidak ditemukan');
    }

    _produk[index] = {
      'id': id,
      'kode_produk': kodeProduk,
      'nama_produk': namaProduk,
      'harga': harga,
    };

    return true;
  }

  // Simulasi delete produk
  static Future<bool> deleteProduk({int? id}) async {
    await Future.delayed(Duration(seconds: 1));

    int index = _produk.indexWhere((p) => p['id'] == id);
    if (index == -1) {
      throw Exception('Produk tidak ditemukan');
    }

    _produk.removeAt(index);
    return true;
  }
}
