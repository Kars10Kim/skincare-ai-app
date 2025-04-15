import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

/// A utility class for making authenticated HTTP requests
/// 
/// Handles adding authorization headers and token refresh automatically
class AuthenticatedHttpClient {
  final AuthService _authService = AuthService();
  
  /// Base URL for API requests
  final String _baseUrl;
  
  /// Create a new HttpClient with the given base URL
  /// 
  /// If baseUrl is null, the default base URL will be used
  AuthenticatedHttpClient({String? baseUrl}) 
      : _baseUrl = baseUrl ?? 'http://localhost:5000';
  
  /// Make an authenticated HTTP GET request
  Future<http.Response> get(String endpoint) async {
    return _request('GET', endpoint);
  }
  
  /// Make an authenticated HTTP POST request
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    return _request('POST', endpoint, body: body);
  }
  
  /// Make an authenticated HTTP PUT request
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    return _request('PUT', endpoint, body: body);
  }
  
  /// Make an authenticated HTTP DELETE request
  Future<http.Response> delete(String endpoint) async {
    return _request('DELETE', endpoint);
  }
  
  /// Make an authenticated HTTP request with the given method and endpoint
  /// 
  /// Handles adding authorization headers and automatically refreshes tokens if needed
  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    // Get the current authentication token
    final token = await _authService.getToken();
    
    // Create appropriate headers
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer ${token.token}',
    };
    
    // Create full URI
    final uri = Uri.parse(endpoint.startsWith('http') 
        ? endpoint 
        : '$_baseUrl${endpoint.startsWith('/') ? endpoint : '/$endpoint'}');
    
    // Make the request based on the method
    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri, 
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri, 
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
    
    // Handle 401 responses by refreshing the token and retrying the request
    if (response.statusCode == 401 && token != null) {
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        // Token was refreshed, retry request
        return _request(method, endpoint, body: body);
      }
    }
    
    return response;
  }
}