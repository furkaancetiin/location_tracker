import 'package:flutter/material.dart';
import 'ui/main_page.dart';

void main() {
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
      home: MainPage(), // Ana ekran olarak StompClientScreen kullanılır.
    );
  }
}
