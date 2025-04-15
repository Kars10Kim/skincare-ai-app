import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../error/exceptions.dart';

/// Network client for API requests
class NetworkClient {
  /// HTTP client
  final http.Client client;
  
  /// API base URL
  final String baseUrl;
  
  /// Create network client
  NetworkClient({
    required this.client,
    required this.baseUrl,
  });
  
  /// Get request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    String? authToken,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = _buildHeaders(headers, requiresAuth, authToken);
      
      debugPrint('GET $uri');
      final response = await client.get(uri, headers: requestHeaders)
          .timeout(const Duration(seconds: 30));
      
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Post request
  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool requiresAuth = true,
    String? authToken,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = _buildHeaders(headers, requiresAuth, authToken);
      final encodedBody = body != null ? jsonEncode(body) : null;
      
      debugPrint('POST $uri');
      if (body != null) {
        debugPrint('Body: $encodedBody');
      }
      
      final response = await client.post(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      ).timeout(const Duration(seconds: 30));
      
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Put request
  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool requiresAuth = true,
    String? authToken,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = _buildHeaders(headers, requiresAuth, authToken);
      final encodedBody = body != null ? jsonEncode(body) : null;
      
      debugPrint('PUT $uri');
      if (body != null) {
        debugPrint('Body: $encodedBody');
      }
      
      final response = await client.put(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      ).timeout(const Duration(seconds: 30));
      
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Delete request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    bool requiresAuth = true,
    String? authToken,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = _buildHeaders(headers, requiresAuth, authToken);
      final encodedBody = body != null ? jsonEncode(body) : null;
      
      debugPrint('DELETE $uri');
      
      final response = await client.delete(
        uri,
        headers: requestHeaders,
        body: encodedBody,
      ).timeout(const Duration(seconds: 30));
      
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Multipart request for uploading files
  Future<dynamic> multipart(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? fields,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    String? authToken,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = _buildHeaders(headers, requiresAuth, authToken);
      
      debugPrint('MULTIPART $uri');
      
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(requestHeaders);
      
      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);
      
      // Add other fields
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 60));
      
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on SocketException {
      throw const NetworkException(
        message: 'No internet connection',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      if (e is NetworkException || e is ServerException || e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
  
  /// Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final fullUrl = '$baseUrl$endpoint';
    final uri = Uri.parse(fullUrl);
    
    if (queryParameters != null) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    
    return uri;
  }
  
  /// Build headers with auth token if needed
  Map<String, String> _buildHeaders(
    Map<String, String>? headers,
    bool requiresAuth,
    String? authToken,
  ) {
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (headers != null) {
      requestHeaders.addAll(headers);
    }
    
    if (requiresAuth && authToken != null) {
      requestHeaders['Authorization'] = 'Bearer $authToken';
    }
    
    return requestHeaders;
  }
  
  /// Process response and handle errors
  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
        // Success responses
        try {
          final responseText = response.body;
          final decodedBody = responseText.isNotEmpty 
              ? jsonDecode(responseText) 
              : {};
          return decodedBody;
        } catch (e) {
          // If JSON decoding fails, return raw response
          return response.body;
        }
      
      case 400:
        // Bad request
        throw ServerException(
          message: _getErrorMessage(response) ?? 'Bad request',
          code: response.statusCode,
        );
      
      case 401:
        // Unauthorized
        throw AuthException(
          message: _getErrorMessage(response) ?? 'Unauthorized',
          code: response.statusCode,
        );
      
      case 403:
        // Forbidden
        throw AuthException(
          message: _getErrorMessage(response) ?? 'Forbidden',
          code: response.statusCode,
        );
      
      case 404:
        // Not found
        throw ServerException(
          message: _getErrorMessage(response) ?? 'Not found',
          code: response.statusCode,
        );
      
      case 422:
        // Validation error
        throw ValidationException(
          message: _getErrorMessage(response) ?? 'Validation error',
          code: response.statusCode,
        );
      
      case 429:
        // Too many requests
        throw ServerException(
          message: _getErrorMessage(response) ?? 'Too many requests',
          code: response.statusCode,
        );
      
      case 500:
      case 501:
      case 502:
      case 503:
        // Server errors
        throw ServerException(
          message: _getErrorMessage(response) ?? 'Server error',
          code: response.statusCode,
        );
      
      default:
        throw ServerException(
          message: _getErrorMessage(response) ?? 'Unknown error',
          code: response.statusCode,
        );
    }
  }
  
  /// Extract error message from response
  String? _getErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        if (body.containsKey('message')) {
          return body['message'];
        } else if (body.containsKey('error')) {
          final error = body['error'];
          if (error is String) {
            return error;
          } else if (error is Map<String, dynamic> && error.containsKey('message')) {
            return error['message'];
          }
        }
      }
      return null;
    } catch (e) {
      return response.body;
    }
  }
}