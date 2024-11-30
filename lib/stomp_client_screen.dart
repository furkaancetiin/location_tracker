import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location_tracker_jet_blue/service/background_task_manager.dart';
import 'package:location_tracker_jet_blue/service/location_service.dart';
import 'package:location_tracker_jet_blue/service/stomp_client_service.dart';
import 'package:location_tracker_jet_blue/utils/upper_case_text_formatter.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class StompClientScreen extends StatefulWidget {
  @override
  _StompClientScreenState createState() => _StompClientScreenState();
}

class _StompClientScreenState extends State<StompClientScreen> {
  final StompClientService stompService = StompClientService();
  final LocationService locationService = LocationService();
  final BackgroundTaskManager backgroundTaskManager = BackgroundTaskManager();
  String? licensePlate;
  bool isTracking = false;
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    locationService.checkAndRequestLocationPermission();
    backgroundTaskManager.initialize();
  }

  void startWebSocket(String licensePlate) {
    stompService.initialize('wss://location-d22e0369f042.herokuapp.com/ws',
        (frame) => onWebSocketConnect(frame, licensePlate), onWebSocketError);
  }

  void onWebSocketConnect(StompFrame frame, String licensePlate) {
    setState(() {
      isTracking = true;
    });
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

  void onWebSocketError(dynamic error) {
    (dynamic error) => print('WebSocket Hatası: $error');
  }

  Future<void> sendLocationToServer(String licensePlate) async {
    final location = await locationService.getCurrentLocation();
    print(location);
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
        body: isTracking ? secondScreen() : firstScreen());
  }

  @override
  void dispose() {
    stompService.deactivate();
    backgroundTaskManager.stop();
    super.dispose();
  }

  void onPressedFollowButton(TextEditingController _controller){
    setState(() {
      _isButtonDisabled = true;
    });
    String input = _controller.text;
    if (input.isNotEmpty) {
      startWebSocket(input);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen geçerli bir plaka giriniz")),
      );
      setState(() {
        _isButtonDisabled = false;
      });
    }
  }

  Widget firstScreen() {
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

  Widget secondScreen() {
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
