import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  final _controller = StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((_) async {
      await checkConnection();
    });

    checkConnection();
  }

  Future<void> checkConnection() async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    _controller.add(
      hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline,
    );
  }

  Future<bool> get isOnline async {
    return await InternetConnection().hasInternetAccess;
  }

  void dispose() {
    _controller.close();
  }
}