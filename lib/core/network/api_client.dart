import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl});
  final String baseUrl;

  Future<ApiResponse> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ApiResponse(data, response.statusCode);
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }

  Future<ApiResponse> post(String endpoint, {dynamic data}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return ApiResponse(responseData, response.statusCode);
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  Future<ApiResponse> patch(String endpoint, {dynamic data}) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return ApiResponse(responseData, response.statusCode);
    } else {
      throw Exception('Failed to patch data: ${response.statusCode}');
    }
  }

  Future<ApiResponse> put(String endpoint, {dynamic data}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return ApiResponse(responseData, response.statusCode);
    } else {
      throw Exception('Failed to put data: ${response.statusCode}');
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Some DELETE operations return no content (204)
      final responseData =
          response.statusCode == 204 ? null : jsonDecode(response.body);
      return ApiResponse(responseData, response.statusCode);
    } else {
      throw Exception('Failed to delete data: ${response.statusCode}');
    }
  }
}

class ApiResponse {
  ApiResponse(this.data, this.statusCode);
  final dynamic data;
  final int statusCode;
}

/// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
      baseUrl: 'https://api.unddairy.com'); // Replace with your actual base URL
});
