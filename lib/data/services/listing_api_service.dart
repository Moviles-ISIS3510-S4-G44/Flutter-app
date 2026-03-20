import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';

class ListingApiService {
  final http.Client _httpClient;
  final String _baseUrl;

  ListingApiService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client(),
      _baseUrl = AppConfig.apiBaseUrl;

  Future<http.Response> getListings() async {
    return _httpClient.get(Uri.parse('$_baseUrl/listings'));
  }
}
