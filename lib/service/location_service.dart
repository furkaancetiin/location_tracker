import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<bool> checkAndRequestPermissions() async {
    try {
      PermissionStatus whileInUse = await Permission.locationWhenInUse.status;
      if(!whileInUse.isGranted){
        whileInUse = await Permission.locationWhenInUse.request();
        if(!whileInUse.isGranted){
          print('whileInUse konum izni reddedildi.');
          return false;
        }else if(whileInUse.isGranted){
          PermissionStatus isLocationAlways = await Permission.locationAlways.status;
          if (!isLocationAlways.isGranted) {
            isLocationAlways = await Permission.locationAlways.request();
            if (!isLocationAlways.isGranted) {
              print('Always konum izni reddedildi.');
              return false;
            }
          }
        }
      }

      if (await Permission.notification.isDenied) {
        PermissionStatus notificationPermission = await Permission.notification.request();
        if (notificationPermission == PermissionStatus.denied) {
          print('Notification izni reddedildi.');
          return false;
        }
      }

      if (Platform.isAndroid) {
        if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
          await FlutterForegroundTask.requestIgnoreBatteryOptimization();
        }
      }

      bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        await Geolocator.openLocationSettings();
      }
      return true;
    } catch (e) {
      print('İzin alma hatası: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }
}
