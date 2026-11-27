import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class AppSecurityService extends ChangeNotifier {
  AppSecurityService({SecureKeyValueStore? store, Random? random})
      : _store = store ?? FlutterSecureKeyValueStore(),
        _random = random ?? Random.secure();

  static const _enabledKey = 'app_lock_enabled';
  static const _saltKey = 'app_lock_pin_salt';
  static const _hashKey = 'app_lock_pin_hash';
  static const _pinLength = 6;
  static const _iterations = 120000;

  final SecureKeyValueStore _store;
  final Random _random;
  bool _lockEnabled = false;
  bool get lockEnabled => _lockEnabled;

  final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: 256,
  );

  Future<bool> get isLockEnabled async {
    final enabled = await _store.read(_enabledKey) == 'true';
    final salt = await _store.read(_saltKey);
    final hash = await _store.read(_hashKey);
    _lockEnabled = enabled && salt != null && hash != null;
    return _lockEnabled;
  }

  Future<void> enableWithPin(String pin) async {
    if (!_isValidPin(pin)) {
      throw ArgumentError.value(pin, 'pin', 'PIN must contain exactly 6 digits.');
    }
    final salt = List<int>.generate(16, (_) => _random.nextInt(256));
    final hash = await _derivePinHash(pin, salt);
    await _store.write(_saltKey, base64Encode(salt));
    await _store.write(_hashKey, base64Encode(hash));
    await _store.write(_enabledKey, 'true');
    _lockEnabled = true;
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final saltValue = await _store.read(_saltKey);
    final hashValue = await _store.read(_hashKey);
    if (saltValue == null || hashValue == null) return false;
    if (!_isValidPin(pin)) return false;

    try {
      final actual = await _derivePinHash(pin, base64Decode(saltValue));
      final expected = base64Decode(hashValue);
      if (actual.length != expected.length) return false;
      var difference = 0;
      for (var i = 0; i < actual.length; i++) {
        difference |= actual[i] ^ expected[i];
      }
      return difference == 0;
    } on FormatException {
      return false;
    }
  }

  Future<void> disableLock() async {
    await _store.delete(_enabledKey);
    await _store.delete(_saltKey);
    await _store.delete(_hashKey);
    _lockEnabled = false;
    notifyListeners();
  }

  bool _isValidPin(String pin) =>
      pin.length == _pinLength && RegExp(r'^\d+
    final key = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return key.extractBytes();
  }
}
).hasMatch(pin);

  Future<List<int>> _derivePinHash(String pin, List<int> salt) async {
    final key = await _pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return key.extractBytes();
  }
}
