import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database_provider.dart';
import '../../models/scan_history_model.dart';
import '../../utils/constants.dart';
import '../../widgets/card_container.dart';
import '../../widgets/network_status_indicator.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading/loading_state_widget.dart';
import '../../widgets/animated_components.dart';
import '../../utils/date_formatter.dart';

/// Favorites screen showing starred products
class FavoritesScreen extends StatefulWidget {
  /// Creates a favorites screen
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  List<ScanHistory>? _favorites;
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 300),
    );
    _loadFavorites();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      final favorites = await dbProvider.getFavorites();
      
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(ScanHistory scan) async {
    if (scan.id == null) return;
    
    try {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      await dbProvider.toggleFavorite(scan.id!);
      
      // Refresh the list
      _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating favorite'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline indicator
          const NetworkStatusIndicator(),
          
          // Main content
          Expanded(
            child: _isLoading
                ? const LoadingStateWidget.message(message: 'Loading your favorites...')
                : _favorites == null || _favorites!.isEmpty
                    ? _buildEmptyState(context)
                    : _buildFavoritesList(context),
          ),
        ],
      ),
    );
  }
  
  /// Builds the favorites list
  Widget _buildFavoritesList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ListView.builder(
          key: ValueKey(_favorites?.length ?? 0),
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: _favorites?.length ?? 0,
          itemBuilder: (context, index) {
            final item = _favorites![index];
            
            return FadeSlideTransition(
              animation: _animationController,
              delay: index * 0.05,
              child: Dismissible(
                key: Key(item.id.toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Remove from Favorites?"),
                        content: const Text(
                            "Are you sure you want to remove this product from your favorites?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  _toggleFavorite(item);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to details when tapped
                      Navigator.pushNamed(
                        context, 
                        '/product_details',
                        arguments: item.productBarcode,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        // If we have a Product object, use that data
                        if (item.product != null)
                          ProductCard(
                            product: item.product!, 
                            conflicts: item.conflicts,
                            showFavoriteButton: true,
                            isFavorite: true,
                            onFavoriteToggle: () => _toggleFavorite(item),
                          )
                        else
                          // Fallback for when product is missing
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.inventory_2_outlined, color: Colors.white),
                            ),
                            title: Text(
                              'Product ${item.productBarcode}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Scanned on ${DateFormatter.formatDate(item.scanDate)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () => _toggleFavorite(item),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the empty state when no favorites are available
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: CardContainer(
          useGlassmorphism: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                'No Favorites Yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mark products as favorites to save them here for quick access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to scan tab
                  Navigator.of(context).pushReplacementNamed('/');
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan a Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}