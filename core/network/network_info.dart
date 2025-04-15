import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Network information provider
abstract class NetworkInfo {
  /// Check if device is connected to the internet
  Future<bool> get isConnected;
}

/// Network information implementation
class NetworkInfoImpl implements NetworkInfo {
  /// Internet connection checker
  final InternetConnectionChecker connectionChecker;
  
  /// Create network info
  NetworkInfoImpl(this.connectionChecker);
  
  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}