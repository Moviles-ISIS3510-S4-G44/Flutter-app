import 'package:marketplace_flutter_application/data/dtos/search/intent_filters.dart';

abstract class IntentParser {
  Future<IntentFilters> parseIntent(String query);
}

