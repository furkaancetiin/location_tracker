import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<void> checkAndRequestPermissions() async {
    try {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            await Geolocator.openLocationSettings();
            return;
          }

          if (await Permission.notification.isDenied) {
            PermissionStatus notificationPermission = await Permission.notification.request();
            if(notificationPermission == PermissionStatus.denied){
              print('Notification izni reddedildi.');
              return;
            }
          }

          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
              print('Konum izni reddedildi.');
              return;
            }
          }

          if (permission == LocationPermission.deniedForever) {
            print('Konum izni kalıcı olarak reddedildi.');
            return;
          }

          if(permission != LocationPermission.always){
            print("Always izni gerekli. İzin isteme...");
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.always) {
            print("Always izni başarıyla alındı.");
          } else {
            print("Always izni alınamadı.");
          }
        } catch (e) {
          print('Konum alma hatası: $e');
          return null;
        }
  }


  Future<Map<String, dynamic>?> getCurrentLocation() async{
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }
}
