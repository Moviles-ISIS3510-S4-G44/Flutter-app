import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';

class ListingApiService {
  final http.Client _httpClient = http.Client();
  final String _baseUrl = AppConfig.apiBaseUrl;

  Future<http.Response> getListings() async {
    return _httpClient.get(Uri.parse('$_baseUrl/listings'));
  }
}