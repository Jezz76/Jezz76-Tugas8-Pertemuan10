class Login {
  int? code;
  bool? status;
  String? token;
  int? userId;
  String? userEmail;

  Login({this.code, this.status, this.token, this.userId, this.userEmail});
  factory Login.fromJson(Map<String, dynamic> json) {
    if (json['code'] == 200) {
      return Login(
        code: json['code'],
        status: json['status'],
        token: json['token'],
        userId: json['userId'],
        userEmail: json['userEmail'],
      );
    } else {
      return Login(code: json['code'], status: json['status']);
    }
  }
}
