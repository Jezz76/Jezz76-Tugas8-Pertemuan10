import 'dart:convert';
import 'package:tokokita/helpers/api.dart';
import 'package:tokokita/helpers/api_url.dart';
import 'package:tokokita/model/registrasi.dart';
import 'package:tokokita/services/mock_api.dart';

class RegistrasiBloc {
  static const bool useMockApi = true; // Ganti ke false jika sudah ada server

  static Future<Registrasi> registrasi(
      {String? nama, String? email, String? password}) async {
    // Jika useMockApi true, gunakan mock data
    if (useMockApi) {
      return await MockApi.registrasi(
        nama: nama,
        email: email,
        password: password,
      );
    }

    // Jika false, gunakan API server
    String apiUrl = ApiUrl.registrasi;
    var body = {"nama": nama, "email": email, "password": password};
    var response = await Api().post(apiUrl, body);
    var jsonObj = json.decode(response.body);
    return Registrasi.fromJson(jsonObj);
  }
}
