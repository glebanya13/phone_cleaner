import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStorage() async {
    // Try full access first (Android 11+)
    if (await Permission.manageExternalStorage.isGranted) return true;
    final r = await Permission.manageExternalStorage.request();
    if (r.isGranted) return true;

    // Fallback to media permissions
    final imgs = await Permission.photos.request();
    final vids = await Permission.videos.request();
    final audio = await Permission.audio.request();
    return imgs.isGranted || vids.isGranted || audio.isGranted;
  }

  static Future<bool> hasStorage() async {
    return await Permission.manageExternalStorage.isGranted ||
        await Permission.storage.isGranted;
  }

  static Future<void> openSettings() => openAppSettings();
}
