import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class StompClientService {
  late StompClient stompClient;

  void initialize(String url, Function(StompFrame frame) onConnect, StompWebSocketErrorCallback onWebSocketError) {
    stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: onConnect,
        onWebSocketError: onWebSocketError,
        reconnectDelay: Duration(seconds: 5),
      ),
    );

    stompClient.activate();
  }

  void sendMessage(String destination, String body) {
    stompClient.send(
      destination: destination,
      body: body,
    );
  }

  void subscribe(String destination, Function(StompFrame message) callback) {
    stompClient.subscribe(
      destination: destination,
      callback: callback,
    );
  }

  void deactivate() {
    stompClient.deactivate();
  }
}
