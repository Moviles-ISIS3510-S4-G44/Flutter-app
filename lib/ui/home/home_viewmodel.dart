import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  final List<String> listings = [
    'Listing 1',
    'Listing 2',
    'Listing 3',
  ];

  bool isLoading = false;
}