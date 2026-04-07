
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Key used to persist the JWT access token locally.
const _kTokenKey = 'auth_access_token';

class ApiClient {
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/v1';
    }
    return 'http://localhost:8080/v1';
  }

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // ---------------------------------------------------------------------------
  // Token Management (local storage — no SDK dependency)
  // ---------------------------------------------------------------------------

  /// Saves the access token returned by the backend to local storage.
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  /// Retrieves the persisted access token, or null if not logged in.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey);
  }

  /// Clears the stored token on logout.
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
  }

  // ---------------------------------------------------------------------------
  // Auth Methods (call the backend, not Supabase directly)
  // ---------------------------------------------------------------------------

  /// Calls POST /v1/auth/login and persists the returned token.
  /// Returns the decoded response body or throws on failure.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      await saveToken(body['access_token'] as String);
    }
    return body; // Caller checks for 'code' key on error.
  }

  /// Calls POST /v1/auth/register.
  /// Returns the decoded response body or throws on failure.
  Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Base HTTP Methods (authenticated)
  // ---------------------------------------------------------------------------

  /// Appends standard headers and the JWT Bearer token from local storage.
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return _client.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return _client.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return _client.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return _client.delete(url, headers: headers);
  }
}
