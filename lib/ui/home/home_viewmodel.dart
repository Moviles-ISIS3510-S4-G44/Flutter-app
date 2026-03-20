import 'package:flutter/foundation.dart';
import '../../models/listings/listing_summary.dart';

class HomeViewModel extends ChangeNotifier {
  bool isLoading = false;
  final List<ListingSummary> featuredListings = [];
  final List<ListingSummary> recentListings = [];

}