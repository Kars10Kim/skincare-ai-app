import 'package:flutter/material.dart';

/// Search favorite bar
class SearchFavoriteBar extends StatefulWidget {
  /// Search callback
  final void Function(String) onSearch;
  
  /// Create search favorite bar
  const SearchFavoriteBar({
    Key? key,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<SearchFavoriteBar> createState() => _SearchFavoriteBarState();
}

class _SearchFavoriteBarState extends State<SearchFavoriteBar> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Favorites',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Product name, brand, ingredient, etc.',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.onSearch(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Tips',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                TextButton(
                  onPressed: () {
                    final value = _controller.text.trim();
                    if (value.isNotEmpty) {
                      widget.onSearch(value);
                    }
                  },
                  child: const Text('SEARCH'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSearchTips(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchTips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSearchTip('Moisturizer', () {
          _controller.text = 'Moisturizer';
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }),
        _buildSearchTip('CeraVe', () {
          _controller.text = 'CeraVe';
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }),
        _buildSearchTip('Hyaluronic Acid', () {
          _controller.text = 'Hyaluronic Acid';
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }),
        _buildSearchTip('5-star', () {
          _controller.text = '5-star';
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }),
      ],
    );
  }
  
  Widget _buildSearchTip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}