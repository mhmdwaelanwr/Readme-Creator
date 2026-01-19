import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/giphy_service.dart';
import '../../utils/dialog_helper.dart';
import '../../core/constants/app_colors.dart';

class GiphyPickerDialog extends StatefulWidget {
  const GiphyPickerDialog({super.key});

  @override
  State<GiphyPickerDialog> createState() => _GiphyPickerDialogState();
}

class _GiphyPickerDialogState extends State<GiphyPickerDialog> {
  final GiphyService _giphyService = GiphyService();
  final TextEditingController _searchController = TextEditingController();
  List<String> _gifs = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final gifs = await _giphyService.getTrendingGifs();
      setState(() { _gifs = gifs; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) { _loadTrending(); return; }
    setState(() { _isLoading = true; _error = null; });
    try {
      final gifs = await _giphyService.searchGifs(query);
      setState(() { _gifs = gifs; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: const DialogHeader(
        title: 'GIPHY Explorer',
        icon: Icons.gif_box_rounded,
        color: Colors.pinkAccent,
      ),
      width: 650,
      height: 600,
      content: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading ? _buildLoading() : (_error != null ? _buildError() : _buildGrid()),
          ),
          if (!_isLoading && _gifs.isNotEmpty) _buildFooter(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Find the perfect GIF...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: () { _searchController.clear(); _loadTrending(); },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10),
      ),
      style: GoogleFonts.inter(),
      onSubmitted: _search,
    );
  }

  Widget _buildGrid() {
    if (_gifs.isEmpty) return Center(child: Text('No results found', style: GoogleFonts.inter(color: Colors.grey)));
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _gifs.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => Navigator.pop(context, _gifs[index]),
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GlassCard(
              padding: EdgeInsets.zero,
              opacity: 0.1,
              child: Image.network(
                _gifs[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image_rounded, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
  Widget _buildError() => Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bolt_rounded, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text('Powered by GIPHY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}
