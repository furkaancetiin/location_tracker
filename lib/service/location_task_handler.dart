import 'dart:async';
import 'dart:convert';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:location_tracker_jet_blue/service/stomp_client_service.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'location_service.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  final StompClientService stompService = StompClientService();
  final LocationService locationService = LocationService();
  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // print('onStart(starter: ${starter.name})');
    // Timer.periodic(Duration(seconds: 3), (timer) {
    //   print('3 saniye geçti!');
    // });

    FlutterForegroundTask.updateService(
        notificationTitle: 'XL Kargo Konum Takip',
        notificationText: 'Plaka bilgisi girildikten sonra konum bilgisi anlık olarak alınacaktır.');
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    stompService.initialize('wss://location-d22e0369f042.herokuapp.com/ws',
            (frame) => onWebSocketConnect(frame, jsonDecode(data.toString())), onWebSocketError);
  }

  void onWebSocketError(dynamic error) {
        (dynamic error) => print('WebSocket Hatası: $error');
  }

  void onWebSocketConnect(StompFrame frame, String licensePlate) {
    bool isTracking = true;
    FlutterForegroundTask.updateService(
        notificationTitle: 'XL Kargo Konum Takip',
        notificationText: 'Konum bilgisi iletiliyor...');
    FlutterForegroundTask.sendDataToMain(jsonEncode(isTracking));

    stompService.subscribe('/topic/location', (message) async {
      print('Sunucudan mesaj alındı: ${message.body}');
      await sendLocationToServer(licensePlate);
    });

    stompService.subscribe(
      '/topic/messages',
          (message) async {
        print('Ping mesaj alındı: ${message.body}');
      },
    );
  }

  Future<void> sendLocationToServer(String licensePlate) async {
    final location = await locationService.getCurrentLocation();
    if (location != null) {
      Map<String, dynamic> locationData = {
        "licensePlate": licensePlate,
        "latitude": location['latitude'],
        "longitude": location['longitude'],
      };
      stompService.sendMessage('/app/location', json.encode(locationData));
      print('Konum bilgisi gönderildi: $locationData');
    }
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  // Called by eventAction in [ForegroundTaskOptions].
  // - nothing() : Not use onRepeatEvent callback.
  // - once() : Call onRepeatEvent only once.
  // - repeat(interval) : Call onRepeatEvent at milliseconds interval.
  @override
  void onRepeatEvent(DateTime timestamp) {
    print('onRepeatEvent');
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('onDestroy');
  }
}