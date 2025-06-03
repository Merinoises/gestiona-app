// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/models/usuario.dart';

LoginResponse loginResponseFromJson(String str, List<Pool> allPools) =>
    LoginResponse.fromJson(json.decode(str) as Map<String, dynamic>, allPools);

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  bool ok;
  Usuario usuario;
  String token;

  LoginResponse({required this.ok, required this.usuario, required this.token});

  factory LoginResponse.fromJson(
    Map<String, dynamic> json,
    List<Pool> allPools,
  ) => LoginResponse(
    ok: json["ok"],
    usuario: Usuario.fromJson(json["usuario"], allPools),
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "usuario": usuario.toJson(),
    "token": token,
  };
}
