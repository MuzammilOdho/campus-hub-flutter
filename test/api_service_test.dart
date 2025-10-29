import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:campus_hub/src/api/api_service.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};
  @override
  Future<void> write({required String key, required String? value, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    return _data[key];
  }

  @override
  Future<void> delete({required String key, IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions, WebOptions? webOptions, MacOsOptions? mOptions, WindowsOptions? wOptions}) async {
    _data.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('login stores token on success', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path.endsWith('/auth/login')) {
        return http.Response(jsonEncode({'token': 'abc123', 'expiresAt': 999999999}), 202);
      }
      return http.Response('Not Found', 404);
    });

    final api = ApiService(baseUrl: 'http://example.com', client: mockClient, storage: FakeSecureStorage());
    final res = await api.login('test@example.com', 'password');
    expect(res.token, 'abc123');
    final stored = await api.getToken();
    expect(stored, 'abc123');
  });
}
