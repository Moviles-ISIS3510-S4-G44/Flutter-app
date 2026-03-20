import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/services/connectivity_service.dart';

class ConnectivityModel extends ChangeNotifier {
  final ConnectivityService _service;

  ConnectivityStatus _status = ConnectivityStatus.offline;
  ConnectivityStatus get status => _status;

  bool get isOnline => _status == ConnectivityStatus.online;

  StreamSubscription? _subscription;

  ConnectivityModel(this._service) {
    _init();
  }

  void _init() {
    _subscription = _service.statusStream.listen((status) {
      _status = status;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}