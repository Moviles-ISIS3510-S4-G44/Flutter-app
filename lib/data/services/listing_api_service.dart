import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marketplace_flutter_application/config/app_config.dart';
import 'package:marketplace_flutter_application/data/dtos/listings/create_listing_request.dart';
import 'package:marketplace_flutter_application/data/dtos/listings/listing_dto.dart';

class ListingApiService {
  final http.Client _httpClient = http.Client();
  final String _baseUrl = AppConfig.apiBaseUrl;
  // Get all listings
  Future<List<ListingDto>> getListings() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/listings'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;

      return jsonList
          .map((json) => ListingDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      debugPrint(
        'Failed to load listings: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Failed to load listings');
    }
  }

  // Create a new listing
  Future<ListingDto> createListing(CreateListingRequest request) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/listings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create listing');
    }

    final Map<String, dynamic> decodedBody =
        jsonDecode(response.body) as Map<String, dynamic>;

    return ListingDto.fromJson(decodedBody);
  }
}
