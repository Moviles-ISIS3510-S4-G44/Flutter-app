import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/core/constants/api_constants.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class ApiProductRepository {
  Future<List<ListingSummary>> getAll() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/listings');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ListingSummary.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load listings');
    }
  }

  Future<List<ListingSummary>> search(String query) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/listings/search?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ListingSummary.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search listings');
    }
  }

  // filters products that have lat/lng for the map view
  Future<List<ListingSummary>> getWithLocation() async {
    final all = await getAll();
    return all.where((p) => p.latitude != null && p.longitude != null).toList();
  }

  Future<String> createProduct(Map<String, dynamic> data, {String? token}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/listings');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final respData = jsonDecode(response.body);
      return respData['id']?.toString() ?? 'unknown_id';
    } else {
      throw Exception('Failed to create listing: ${response.statusCode}');
    }
  }
}
