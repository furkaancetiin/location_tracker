import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:location_tracker_jet_blue/service/location_service.dart';
import 'package:location_tracker_jet_blue/service/location_task_handler.dart';
import 'package:location_tracker_jet_blue/service/stomp_client_service.dart';
import 'package:location_tracker_jet_blue/utils/upper_case_text_formatter.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final StompClientService stompService = StompClientService();
  final LocationService locationService = LocationService();

  String? licensePlate;
  bool isTracking = false;
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await locationService.checkAndRequestPermissions();
      _initService();
      _startService();
    });
  }

  void _initService() {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
        'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<ServiceRequestResult> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'XL Kargo Konum Takip',
        notificationText: 'Plaka bilgisi girildikten sonra konum bilgisi anlık olarak alınacaktır.',
        notificationIcon: null,
        callback: startCallback,
      );
    }
  }

  void _onReceiveTaskData(Object data) {
    //print('onReceiveTaskData:');
    if(data == "true"){
      setState(() {
        isTracking = true;
      });
    }
  }

  void onPressedFollowButton(TextEditingController _controller){
    setState(() {
      _isButtonDisabled = true;
    });
    String input = _controller.text;
    if (input.isNotEmpty) {
      FlutterForegroundTask.sendDataToTask(json.encode(input));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen geçerli bir plaka giriniz")),
      );
      setState(() {
        _isButtonDisabled = false;
      });
    }
  }

  @override
  void dispose() {
    stompService.deactivate();
    //FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'XL Kargo Konum Takip',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
        body: isTracking ? locationReceivingScreen() : appInitialScreen());
  }

  Widget appInitialScreen() {
    TextEditingController _controller = TextEditingController();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _controller,
            inputFormatters: [
              UpperCaseTextFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Araç Plakasını Giriniz',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.orange, // Kenarlık turuncu
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.orange, // Kenarlık turuncu
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.orange, // Kenarlık turuncu
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity, // Buton genişliği TextField kadar
            height: 50, // Sabit bir yükseklik
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isButtonDisabled ? Colors.grey : Colors.orange, // Turuncu renk
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Dikdörtgen
                ),
              ),
              onPressed: _isButtonDisabled ? null :  () => onPressedFollowButton(_controller),
              child: Text(
                'Takip Başlat',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget locationReceivingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: double.infinity),
        Image.asset('assets/animations/gps.gif'),
        SizedBox(height: 10,),// Yükleniyor ikonu
        Text(
          'Konum Bilgisi Gönderiliyor...',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
    );
  }
}
