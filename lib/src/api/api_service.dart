import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  ApiService({required this.baseUrl, FlutterSecureStorage? storage, http.Client? client})
      : _storage = storage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client();

  final String baseUrl;
  final FlutterSecureStorage _storage;
  final http.Client _client;

  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async => await _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  Future<void> clearToken() async => await _storage.delete(key: _tokenKey);

  Map<String, String> _defaultHeaders(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) => Uri.parse('${baseUrl.replaceAll(RegExp(r"/\z"), "")}/$path');

  // Auth
  Future<LoginResponse> login(String email, String password) async {
    final resp = await _client.post(
      _uri('auth/login'),
      headers: _defaultHeaders(null),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (resp.statusCode == 202 || resp.statusCode == 200) {
      try {
        final data = jsonDecode(resp.body);
        if (data is Map<String, dynamic> || data is Map) {
          final login = LoginResponse.fromJson(data as Map<String, dynamic>);
          await saveToken(login.token);
          return login;
        }
        if (data is String) {
          final token = data;
          final login = LoginResponse(token: token, expiresAt: 0);
          await saveToken(login.token);
          return login;
        }
      } on FormatException {
        // If backend returned a plain token string or unexpected format, try to recover.
        var token = resp.body.trim();
        if (token.startsWith('"') && token.endsWith('"') && token.length > 1) {
          token = token.substring(1, token.length - 1);
        }
        if (token.isNotEmpty) {
          final login = LoginResponse(token: token, expiresAt: 0);
          await saveToken(login.token);
          return login;
        }
        throw ApiException(resp.statusCode, 'Invalid login response format');
      }
    }

    throw _handleError(resp);
  }

  Future<String> signup(String name, String email, String password) async {
    final resp = await _client.post(
      _uri('auth/signup'),
      headers: _defaultHeaders(null),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (resp.statusCode == 200) return resp.body;

    throw _handleError(resp);
  }

  Future<UserDto> getProfile() async {
    final token = await getToken();
    final resp = await _client.get(_uri('user/me'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      // Debugging: log masked token and response body to help diagnose verification mismatches.
      try {
        final masked = (token ?? '').isEmpty ? '<no-token>' : '${(token ?? '').substring(0, (token ?? '').length>6?(token ?? '').length: (token ?? '').length)}...';
        debugPrint('ApiService.getProfile token: $masked');
        debugPrint('ApiService.getProfile resp: ${resp.body}');
      } catch (_) {}
      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic> || decoded is Map) {
          return UserDto.fromJson(decoded as Map<String, dynamic>);
        }
        throw ApiException(500, 'Invalid profile response format: ${resp.body}');
      } on FormatException catch (_) {
        throw ApiException(500, 'Failed to parse profile response as JSON: ${resp.body}');
      }
    }
    throw _handleError(resp);
  }

  // Resources
  Future<List<ResourceDto>> getResources({String type = 'All', String category = 'All', String status = 'Any', int page = 0, int size = 10}) async {
    final token = await getToken();
    final uri = _uri('resource/?type=$type&category=$category&status=$status&page=$page&size=$size');
    final resp = await _client.get(uri, headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      // The backend returns a Page<ResourceDto> - often Spring's Page serializes content and metadata.
      final content = data['content'] ?? data;
      return (content as List).map((e) => ResourceDto.fromJson(e)).toList();
    }
    throw _handleError(resp);
  }

  Future<ResourceDto> getResourceById(int id) async {
    final token = await getToken();
    final resp = await _client.get(_uri('resource/$id'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      return ResourceDto.fromJson(jsonDecode(resp.body));
    }
    throw _handleError(resp);
  }

  Future<void> createResource(CreateResourceRequest req, File? image) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw ApiException(401, 'Not authenticated. Please login before uploading a resource.');
    }
    final uri = _uri('resource/create');
    final request = http.MultipartRequest('POST', uri);
    // Set Authorization header explicitly for multipart request. Some servers are picky about header casing,
    // so set both 'Authorization' and 'authorization'. Also add Accept header so server returns JSON errors.
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Map user-friendly inputs to backend enum values to avoid enum parsing errors.
    String mapCategory(String input) {
      final s = input.trim().toLowerCase();
      if (s.contains('book')) return 'BOOKS';
      if (s.contains('lab')) return 'LAB_EQUIPMENT';
      if (s.contains('electro') || s.contains('electr') || s.contains('electronic')) return 'ELECTRONICS';
      if (s.contains('station')) return 'STATIONERY';
      if (s.isEmpty) return 'MISCELLANEOUS';
      // fallback: try to uppercase and replace spaces
      final normalized = s.replaceAll(RegExp(r"[^a-z0-9]"), '_').toUpperCase();
      // if normalized matches known enums, use it; otherwise default to MISCELLANEOUS
      const allowed = {'BOOKS', 'LAB_EQUIPMENT', 'ELECTRONICS', 'STATIONERY', 'MISCELLANEOUS'};
      return allowed.contains(normalized) ? normalized : 'MISCELLANEOUS';
    }

    String mapResourceType(String input) {
      final s = input.trim().toLowerCase();
      if (s.contains('don')) return 'DONATE';
      // Treat 'share' or anything else as LEND
      return 'LEND';
    }

    final mappedCategory = mapCategory(req.category);
    final mappedType = mapResourceType(req.resourceType);

    // The backend expects a multipart request with a JSON part named 'resource'
    // (mapped to @RequestPart CreateResourceRequest) and a file part named 'image'.
    final resourceJson = jsonEncode({
      'name': req.name,
      'description': req.description,
      'category': mappedCategory,
      'resourceType': mappedType,
    });

    // Add JSON part with proper content-type
    request.files.add(http.MultipartFile.fromString('resource', resourceJson, contentType: MediaType('application', 'json')));

    if (image != null) {
      final img = image; // promoted non-null within this block
      request.files.add(await http.MultipartFile.fromPath('image', img.path));
    }

    // Debug/logging to help diagnose 400/403 issues
    try {
      final masked = '${token.substring(0, token.length>6?6:token.length)}...';
      debugPrint('createResource POST $uri token: $masked hasImage: ${image != null}');
      debugPrint('createResource payload JSON: $resourceJson');
      for (final f in request.files) {
        debugPrint('createResource part: name=${f.field} filename=${f.filename} length=${f.length} contentType=${f.contentType}');
      }
    } catch (_) {}

    final streamed = await _client.send(request);
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 201) return;
    // Log server response body for debugging
    debugPrint('createResource failed: status=${resp.statusCode} body=${resp.body}');
    throw _handleError(resp);
  }

  // Requests
  Future<void> createUserRequest(int resourceId, DateTime returnDate) async {
    final token = await getToken();
    final body = {
      'resourceId': resourceId,
      'returnDate': _formatDate(returnDate), // dd-MM-yyyy
    };
    final resp = await _client.post(_uri('request/create'), headers: _defaultHeaders(token), body: jsonEncode(body));
    if (resp.statusCode == 200) return;
    throw _handleError(resp);
  }

  Future<void> approveRequest(int requestId, DateTime returnDate) async {
    final token = await getToken();
    final body = {'id': requestId, 'returnDate': _formatDate(returnDate)};
    final resp = await _client.put(_uri('request/approve'), headers: _defaultHeaders(token), body: jsonEncode(body));
    if (resp.statusCode == 200) return;
    throw _handleError(resp);
  }

  Future<void> declineRequest(int requestId) async {
    final token = await getToken();
    final resp = await _client.put(_uri('request/decline/$requestId'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) return;
    throw _handleError(resp);
  }

  Future<List<UserRequestDto>> getReceivedRequests() async {
    final token = await getToken();
    final resp = await _client.get(_uri('request/receive'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List;
      return data.map((e) => UserRequestDto.fromJson(e)).toList();
    }
    throw _handleError(resp);
  }

  Future<List<UserRequestDto>> getSentRequests() async {
    final token = await getToken();
    final resp = await _client.get(_uri('request/sent'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List;
      return data.map((e) => UserRequestDto.fromJson(e)).toList();
    }
    throw _handleError(resp);
  }

  // Transactions
  Future<List<TransactionRecordDto>> getLentRecords() async {
    final token = await getToken();
    final resp = await _client.get(_uri('transactions/lent'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List;
      return data.map((e) => TransactionRecordDto.fromJson(e)).toList();
    }
    throw _handleError(resp);
  }

  Future<List<TransactionRecordDto>> getBorrowedRecords() async {
    final token = await getToken();
    final resp = await _client.get(_uri('transactions/borrowed'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List;
      return data.map((e) => TransactionRecordDto.fromJson(e)).toList();
    }
    throw _handleError(resp);
  }

  Future<void> markAsReturn(int transactionId) async {
    final token = await getToken();
    final resp = await _client.patch(_uri('transactions/return/$transactionId'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) return;
    throw _handleError(resp);
  }

  Future<void> confirmReturn(int transactionId) async {
    final token = await getToken();
    final resp = await _client.patch(_uri('transactions/confirm/$transactionId'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) return;
    throw _handleError(resp);
  }

  // Donation records
  Future<List<DonationRecordDto>> getDonations() async {
    final token = await getToken();
    final resp = await _client.get(_uri('donation/'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List;
      return data.map((e) => DonationRecordDto.fromJson(e)).toList();
    }
    throw _handleError(resp);
  }

  Future<List<ResourceDto>> getMyResources({int page = 0, int size = 10}) async {
    final token = await getToken();
    final uri = _uri('resource/me?page=$page&size=$size');
    final resp = await _client.get(uri, headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final content = data['content'] ?? data;
      return (content as List).map((e) => ResourceDto.fromJson(e)).toList();
    }
    throw _handleError(resp);
  }

  // Delete resource
  Future<String> deleteResource(int id) async {
    final token = await getToken();
    final resp = await _client.delete(_uri('resource/delete/$id'), headers: _defaultHeaders(token));
    if (resp.statusCode == 200) {
      return resp.body;
    }
    throw _handleError(resp);
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  /// Checks whether the configured base URL (optionally with [path]) is reachable.
  /// Returns `true` when a GET request returns a 2xx/3xx status code within [timeout].
  Future<bool> isBaseUrlAlive({String path = '', Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final uri = path.isEmpty
          ? Uri.parse(baseUrl.replaceAll(RegExp(r"/\z"), ""))
          : _uri(path);
      final resp = await _client.get(uri).timeout(timeout);
      return resp.statusCode >= 200 && resp.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  /// Verify a newly registered user using the verification code (OTP) sent to email.
  Future<void> verifyUser(String email, String verificationCode) async {
    final body = {'email': email, 'verificationCode': verificationCode};
    final resp = await _client.post(_uri('auth/verify'), headers: _defaultHeaders(null), body: jsonEncode(body));
    if (resp.statusCode == 200) return;
    throw _handleError(resp);
  }

  /// Resend verification code for the given email.
  Future<void> resendVerificationCode(String email) async {
    final resp = await _client.post(_uri('auth/resendVerification/$email'), headers: _defaultHeaders(null));
    if (resp.statusCode == 200) return;
    throw _handleError(resp);
  }

  /// Decline a transaction return (transactions/decline/{id}) with optional dispute info.
  Future<void> declineReturn(int transactionId, {String? disputeType, String? disputeDetails}) async {
    final body = {
      if (disputeType != null) 'disputeType': disputeType,
      if (disputeDetails != null) 'disputeDetails': disputeDetails,
    };
    final resp = await _client.patch(_uri('transactions/decline/$transactionId'), headers: _defaultHeaders(await getToken()), body: jsonEncode(body));
    if (resp.statusCode == 200) return;
    throw _handleError(resp);
  }

  ApiException _handleError(http.Response resp) {
    // Try to decode JSON error body; if that fails, include the raw body in the message.
    if (resp.body.isNotEmpty) {
      try {
        final body = jsonDecode(resp.body);
        if (body is Map && body['message'] != null) return ApiException(resp.statusCode, body['message'].toString());
        if (body is String) return ApiException(resp.statusCode, body);
        return ApiException(resp.statusCode, resp.body);
      } catch (e) {
        return ApiException(resp.statusCode, resp.body);
      }
    }
    return ApiException(resp.statusCode, resp.reasonPhrase ?? 'Unknown error');
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}
