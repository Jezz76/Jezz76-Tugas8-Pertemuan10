import 'dart:convert';
import 'package:tokokita/helpers/api.dart';
import 'package:tokokita/helpers/api_url.dart';
import 'package:tokokita/model/login.dart';
import 'package:tokokita/services/mock_api.dart';

class LoginBloc {
  static const bool useMockApi = true; // Ganti ke false jika sudah ada server

  static Future<Login> login({String? email, String? password}) async {
    // Jika useMockApi true, gunakan mock data
    if (useMockApi) {
      return await MockApi.login(email: email, password: password);
    }

    // Jika false, gunakan API server
    String apiUrl = ApiUrl.login;
    var body = {"email": email, "password": password};
    var response = await Api().post(apiUrl, body);
    var jsonObj = json.decode(response.body);
    return Login.fromJson(jsonObj);
  }
}
