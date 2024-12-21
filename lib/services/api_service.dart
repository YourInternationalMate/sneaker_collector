import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sneaker.dart';
import '../models/user.dart';

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pages;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PaginatedResponse(
      items: (json['items'] as List).map((item) => fromJson(item)).toList(),
      total: json['total'],
      page: json['page'],
      pages: json['pages'],
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorId;

  ApiException(this.message, {this.statusCode, this.errorId});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException() : super('No internet connection available');
}

class AuthException extends ApiException {
  AuthException() : super('Authentication failed', statusCode: 401);
}

class RateLimitException extends ApiException {
  RateLimitException() : super('Rate limit exceeded. Please try again later.', statusCode: 429);
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5001/api/v1'; // For Android emulator
  static String? _token;

  static Future<String?> get token async {
    if (_token != null) {
      return _token;
    }
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    if (storedToken != null) {
      // Validate stored token
      try {
        final parts = storedToken.split('.');
        if (parts.length != 3) {
          // Invalid token, clear it
          await prefs.remove('token');
          return null;
        }
      } catch (e) {
        await prefs.remove('token');
        return null;
      }
    }
    _token = storedToken;
    return storedToken;
  }

  static Future<void> setToken(String token) async {
    try {
      // Basic validation that the token is a proper JWT
      final parts = token.split('.');
      if (parts.length != 3) {
        throw ApiException('Invalid token format');
      }
      
      _token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    } catch (e) {
      throw ApiException('Failed to save token: $e');
    }
  }

  static Future<Map<String, String>> get headers async {
      final token = await ApiService.token;
      if (token == null) throw AuthException();
      
      return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // Make sure there's a space after 'Bearer'
      };
  }

  static Future<T> _handleResponse<T>(
    Future<http.Response> Function() request,
    T Function(Map<String, dynamic>) parser,
  ) async {
    try {
      final response = await request();
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 401) {
        throw AuthException();
      }

      if (response.statusCode == 429) {
        throw RateLimitException();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return parser(data);
      }

      final error = json.decode(response.body);
      print('Error response: $error');
      throw ApiException(
        error['message'] ?? error['error'] ?? 'An error occurred',
        statusCode: response.statusCode,
        errorId: error['error_id'],
      );
    } catch (e) {
      print('Exception in _handleResponse: $e');
      rethrow;
    }
  }

  // Auth Methods
  static Future<Map<String, dynamic>> login(String username, String password) async {
    return _handleResponse(
      () => http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ),
      (data) {
        if (data['token'] != null) {
          setToken(data['token']);
        }
        return data;
      },
    );
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    return _handleResponse(
      () => http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ),
      (data) {
        if (data['token'] != null) {
          setToken(data['token']);
        }
        return data;
      },
    );
  }

  static Future<void> logout() async {
    try {
      _token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      throw ApiException('Failed to logout: $e');
    }
  }

  // Profile Methods
  static Future<User> getUserProfile() async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: await headers,
      ),
      (data) => User(
        name: data['username'],
        email: data['email'],
        password: '',
        since: data['since'],
      ),
    );
  }

  static Future<User> updateProfile({
    String? username,
    String? email,
    String? password,
  }) async {
    final Map<String, dynamic> updateData = {};
    if (username != null) updateData['username'] = username;
    if (email != null) updateData['email'] = email;
    if (password != null) updateData['password'] = password;

    return _handleResponse(
      () async => http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: await headers,
        body: json.encode(updateData),
      ),
      (data) => User(
        name: data['user']['username'],
        email: data['user']['email'],
        password: '',
        since: data['user']['since'],
      ),
    );
  }

  // Collection Methods
  static Future<PaginatedResponse<Sneaker>> getCollection({int page = 1}) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/collection?page=$page'),
        headers: await headers,
      ),
      (data) => PaginatedResponse.fromJson(
        data,
        (json) => Sneaker.fromJson(json),
      ),
    );
  }

  static Future<bool> updateCollection(Sneaker sneaker) async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/collection'),
        headers: await headers,
        body: json.encode({
          'product_id': sneaker.id,
          'count': sneaker.count,
          'size': sneaker.size,
          'purchase_price': sneaker.purchasePrice,
        }),
      ),
      (data) => true,
    );
  }

  static Future<bool> removeFromCollection(Sneaker sneaker) async {
    return _handleResponse(
      () async => http.delete(
        Uri.parse('$baseUrl/collection'),
        headers: await headers,
        body: json.encode({
          'product_id': sneaker.id,
        }),
      ),
      (data) => true,
    );
  }

  // Favorites Methods
  static Future<PaginatedResponse<Sneaker>> getFavorites({int page = 1}) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/favorites?page=$page'),
        headers: await headers,
      ),
      (data) => PaginatedResponse.fromJson(
        data,
        (json) => Sneaker.fromJson(json),
      ),
    );
  }

  static Future<bool> toggleFavorite(Sneaker sneaker) async {
    return _handleResponse(
      () async => http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: await headers,
        body: json.encode({
          'product_id': sneaker.id,
        }),
      ),
      (data) => true,
    );
  }

  static Future<bool> removeFromFavorites(Sneaker sneaker) async {
    return _handleResponse(
      () async => http.delete(
        Uri.parse('$baseUrl/favorites'),
        headers: await headers,
        body: json.encode({
          'product_id': sneaker.id,
        }),
      ),
      (data) => true,
    );
  }

  // Search Methods
  static Future<PaginatedResponse<Sneaker>> searchSneakers(String query, {int page = 1}) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/search?query=$query&page=$page'),
        headers: await headers,
      ),
      (data) => PaginatedResponse.fromJson(
        data,
        (json) => Sneaker.fromJson(json),
      ),
    );
  }

  static Future<Sneaker> getSneakerDetails(int productId) async {
    return _handleResponse(
      () async => http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: await headers,
      ),
      (data) => Sneaker.fromJson(data),
    );
  }
}