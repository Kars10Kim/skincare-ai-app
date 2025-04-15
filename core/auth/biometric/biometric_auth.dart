
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../exceptions/auth_exceptions.dart';

/// Handles biometric authentication operations
class BiometricAuth {
  static const String _biometricEnabledKey = 'biometric_enabled';
  final _auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  
  /// Check if biometric authentication is available on the device
  Future<bool> isAvailable() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      final isEnabled = await _isEnabled();
      
      return canCheckBiometrics && isDeviceSupported && isEnabled;
    } catch (e) {
      return false;
    }
  }

  /// Authenticate the user using device biometrics
  Future<void> authenticate() async {
    try {
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        throw BiometricException();
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!didAuthenticate) {
        throw BiometricException();
      }
    } catch (e) {
      throw BiometricException();
    }
  }

  /// Enable biometric authentication for the user
  Future<void> enableForAuth() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      
      if (!canCheckBiometrics || !isDeviceSupported) {
        throw BiometricException();
      }
      
      // Store the setting in secure storage
      await _storage.write(key: _biometricEnabledKey, value: 'true');
    } catch (e) {
      throw BiometricException();
    }
  }
  
  /// Disable biometric authentication for the user
  Future<void> disable() async {
    try {
      await _storage.delete(key: _biometricEnabledKey);
    } catch (e) {
      // Fail silently - no need to throw an exception when disabling
    }
  }
  
  /// Check if biometric authentication is enabled for the user
  Future<bool> _isEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }
}
