
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class TokenManager {
  static const _key = 'auth_token';
  final _storage = const FlutterSecureStorage();
  final _encrypter = Encrypter(AES(Key.fromSecureRandom(32)));

  Future<void> save(AuthToken token) async {
    final encrypted = _encrypt(token.toJson());
    await _storage.write(
      key: _key,
      value: encrypted,
    );
  }

  Future<AuthToken?> getToken() async {
    final encrypted = await _storage.read(key: _key);
    if (encrypted == null) return null;
    
    final decrypted = _decrypt(encrypted);
    return AuthToken.fromJson(decrypted);
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }

  String _encrypt(String data) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(data, iv: iv);
    return base64Encode(iv.bytes + encrypted.bytes);
  }

  String _decrypt(String encrypted) {
    final bytes = base64Decode(encrypted);
    final iv = IV(bytes.sublist(0, 16));
    final encryptedBytes = bytes.sublist(16);
    return _encrypter.decrypt64(base64Encode(encryptedBytes), iv: iv);
  }
}

class AuthToken {
  final String token;
  final DateTime expiresAt;

  AuthToken(this.token, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String toJson() => jsonEncode({
    'token': token,
    'expiresAt': expiresAt.toIso8601String(),
  });

  factory AuthToken.fromJson(String json) {
    final map = jsonDecode(json);
    return AuthToken(
      map['token'],
      DateTime.parse(map['expiresAt']),
    );
  }
}
