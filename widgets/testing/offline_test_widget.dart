import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../providers/database_provider.dart';
import '../../models/product_model.dart';
import '../../models/ingredient_model.dart';

/// Widget for testing offline functionality
class OfflineTestWidget extends StatefulWidget {
  const OfflineTestWidget({Key? key}) : super(key: key);

  @override
  State<OfflineTestWidget> createState() => _OfflineTestWidgetState();
}

class _OfflineTestWidgetState extends State<OfflineTestWidget> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  
  bool _isLoading = false;
  String _statusMessage = 'Waiting for actions...';
  
  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = 
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  
  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await Connectivity().checkConnectivity();
    } catch (e) {
      debugPrint('Failed to check connectivity: $e');
      return;
    }
    
    if (!mounted) return;
    setState(() {
      _connectionStatus = result;
    });
  }
  
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }
  
  // Simulate saving a product to the database
  Future<void> _saveProductLocally() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Saving product locally...';
    });
    
    try {
      // Create a mock product
      final product = Product(
        barcode: '123456789',
        name: 'Test Product',
        brand: 'Test Brand',
        description: 'This is a test product',
        ingredients: [
          Ingredient(name: 'Ingredient A', category: 'Test Category'),
          Ingredient(name: 'Ingredient B', category: 'Test Category'),
        ],
      );
      
      // Get the repository
      final repository = DatabaseProvider.repositoryOf(context);
      
      // Save product to local database
      await repository.cacheProduct(product);
      
      setState(() {
        _statusMessage = 'Product saved successfully! Try toggling airplane mode and syncing.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error saving product: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Trigger a manual sync
  Future<void> _syncWithServer() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Syncing with server...';
    });
    
    try {
      // Get the repository
      final repository = DatabaseProvider.repositoryOf(context);
      
      // Trigger sync
      await repository.syncNow();
      
      setState(() {
        _statusMessage = 'Sync completed successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error syncing: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Get connectivity status as string
  String get _connectionStatusText {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'Connected (WiFi)';
      case ConnectivityResult.mobile:
        return 'Connected (Mobile)';
      case ConnectivityResult.ethernet:
        return 'Connected (Ethernet)';
      case ConnectivityResult.bluetooth:
        return 'Connected (Bluetooth)';
      case ConnectivityResult.none:
        return 'Offline';
      default:
        return 'Unknown';
    }
  }
  
  // Get connectivity status color
  Color get _connectionStatusColor {
    switch (_connectionStatus) {
      case ConnectivityResult.none:
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection status card
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Network Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _connectionStatus == ConnectivityResult.none
                              ? Icons.cloud_off
                              : Icons.cloud_done,
                          color: _connectionStatusColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _connectionStatusText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _connectionStatusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Toggle airplane mode on your device to test offline functionality',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Database actions
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveProductLocally,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Product Locally'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading || _connectionStatus == ConnectivityResult.none
                              ? null
                              : _syncWithServer,
                          icon: const Icon(Icons.sync),
                          label: const Text('Sync with Server'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Status message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Text(_statusMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}