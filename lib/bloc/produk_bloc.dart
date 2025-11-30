import 'dart:convert';
import 'package:tokokita/helpers/api.dart';
import 'package:tokokita/helpers/api_url.dart';
import 'package:tokokita/model/produk.dart';
import 'package:tokokita/services/mock_api.dart';

class ProdukBloc {
  static const bool useMockApi = true; // Ganti ke false jika sudah ada server

  static Future<List<Produk>> getProduks() async {
    // Jika useMockApi true, gunakan mock data
    if (useMockApi) {
      return await MockApi.getProduks();
    }

    // Jika false, gunakan API server
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
    // Jika useMockApi true, gunakan mock data
    if (useMockApi) {
      return await MockApi.addProduk(
        kodeProduk: produk!.kodeProduk,
        namaProduk: produk.namaProduk,
        harga: produk.hargaProduk,
      );
    }

    // Jika false, gunakan API server
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
    // Jika useMockApi true, gunakan mock data
    if (useMockApi) {
      return await MockApi.updateProduk(
        id: int.parse(produk.id!),
        kodeProduk: produk.kodeProduk,
        namaProduk: produk.namaProduk,
        harga: produk.hargaProduk,
      );
    }

    // Jika false, gunakan API server
    String apiUrl = ApiUrl.updateProduk(int.parse(produk.id!));
    print(apiUrl);
    var body = {
      "kode_produk": produk.kodeProduk,
      "nama_produk": produk.namaProduk,
      "harga": produk.hargaProduk.toString()
    };
    print("Body : $body");
    var response = await Api().put(apiUrl, jsonEncode(body));
    var jsonObj = json.decode(response.body);
    return jsonObj['status'];
  }

  static Future<bool> deleteProduk({int? id}) async {
    // Jika useMockApi true, gunakan mock data
    if (useMockApi) {
      return await MockApi.deleteProduk(id: id);
    }

    // Jika false, gunakan API server
    String apiUrl = ApiUrl.deleteProduk(id!);
    var response = await Api().delete(apiUrl);
    var jsonObj = json.decode(response.body);
    return (jsonObj as Map<String, dynamic>)['data'];
  }
}
