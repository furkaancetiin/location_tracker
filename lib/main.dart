import 'package:flutter/material.dart';
import 'stomp_client_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter'ın gerekli altyapısını başlatır.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Konum Takip Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StompClientScreen(), // Ana ekran olarak StompClientScreen kullanılır.
    );
  }
}
