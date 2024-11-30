import 'dart:async';
import 'package:flutter_background/flutter_background.dart';
import 'package:location_tracker_jet_blue/service/stomp_client_service.dart';

class BackgroundTaskManager {
  Timer? _timer;
  final StompClientService stompService = StompClientService();


  Future<void> initialize() async {
    bool success = await FlutterBackground.initialize(
      androidConfig: FlutterBackgroundAndroidConfig(
        notificationTitle: "Konum Takip Çalışıyor",
        notificationText: "Uygulama arka planda çalışıyor.",
        notificationImportance: AndroidNotificationImportance.normal,
        notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'),
        enableWifiLock: true,
      ),
    );

    if (success) {
      await FlutterBackground.enableBackgroundExecution();
      _startBackgroundLogging();
    }
  }

  void _startBackgroundLogging() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      print("Uygulama arka planda çalışıyor: ${DateTime.now()}");
    });

    // stompService.initialize(
    //   'wss://location-d22e0369f042.herokuapp.com/ws',
    //       (frame) => sendPing(),
    // );
  }

  // void sendPing(){
  //   stompService.sendPing();
  // }

  Future<void> stop() async {
    await FlutterBackground.disableBackgroundExecution();
    _stopBackgroundLogging();
  }

  void _stopBackgroundLogging() {
    _timer?.cancel();
    _timer = null;
  }
}
