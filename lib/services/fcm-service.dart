// fcm_service.dart
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gestiona_app/global/environment.dart';

class FcmService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GetStorage _storage = GetStorage();
  final _http = GetConnect();

  /// Pide permisos solo en iOS
  Future<void> requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  /// Obtiene y registra el token en tu backend
  Future<void> registerToken() async {
    final String? token = await _messaging.getToken();
    final String? jwt = _storage.read<String>('token');
    if (token != null && jwt != null) {
      await _http.post(
        '${Environment.apiUrl}/fcm-token',
        jsonEncode({'fcm-token': token}),
        headers: {'Content-Type': 'application/json', 'x-token': jwt},
      );
    }
  }
}
