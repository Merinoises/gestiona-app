import 'package:flutter/material.dart';
import 'package:gestiona_app/global/environment.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionService extends GetConnect {
  final _endpoint = '${Environment.apiUrl}/app-version';

  /// Solo en Android
  Future<bool> checkAndUpdateIfAndroid() async {
    if (!GetPlatform.isAndroid) return false;

    // 1) Versión actual
    final info = await PackageInfo.fromPlatform();
    final current = Version.parse(info.version);

    // 2) Llamada con GetConnect
    final response = await get(_endpoint);
    if (response.statusCode != 200) {
      debugPrint('VersionService: error ${response.statusCode}');
      return false;
    }
    final data = response.body;
    final minReq = Version.parse(data['min_required_version']);
    final latest = Version.parse(data['latest_version']);

    // 3) Si es menor que la mínima, forzar update
    if (current < minReq) {
      await _showForceUpdateDialog();
      return true;
    } else if (current < latest) {
      final wants = await _showOptionalUpdateDialog();
      return wants;
    }
    return false;
  }

  Future<void> _showForceUpdateDialog() {
    return Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          // Redondeamos bordes y añadimos sombra
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 24,
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              '⚠️ ¡Actualización Obligatoria!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Debes actualizar la app para continuar.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: _openPlayStore,
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 106, 95),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Actualizar ahora',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<bool> _showOptionalUpdateDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        // Bordes redondeados y sombra
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 24,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            '🚀 ¡Nueva versión disponible!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Quieres actualizar para disfrutar de mejoras?',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Más tarde',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
              _openPlayStore();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 106, 95),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Actualizar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    ).then((value) => value ?? false);
  }

  Future<void> _openPlayStore() async {
    final pkg = (await PackageInfo.fromPlatform()).packageName;
    final marketUri = Uri.parse('market://details?id=$pkg');
    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri);
    } else {
      final webUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$pkg',
      );
      await launchUrl(webUri);
    }
  }
}
