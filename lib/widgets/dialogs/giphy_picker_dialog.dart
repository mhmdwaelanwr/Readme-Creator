import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/giphy_service.dart';
import '../../utils/dialog_helper.dart';

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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final gifs = await _giphyService.getTrendingGifs();
      setState(() {
        _gifs = gifs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _loadTrending();
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final gifs = await _giphyService.searchGifs(query);
      setState(() {
        _gifs = gifs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StyledDialog(
      title: const DialogHeader(
        title: 'Select GIF from GIPHY',
        icon: Icons.gif,
        color: Colors.pinkAccent,
      ),
      width: 600,
      height: 500,
      content: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search GIFs',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _loadTrending();
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            style: GoogleFonts.inter(),
            onSubmitted: _search,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: GoogleFonts.inter(color: Colors.red)))
                    : _gifs.isEmpty
                        ? Center(child: Text('No GIFs found', style: GoogleFonts.inter()))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1, // Square for preview
                            ),
                            itemCount: _gifs.length,
                            itemBuilder: (context, index) {
                              final url = _gifs[index];
                              return InkWell(
                                onTap: () => Navigator.pop(context, url),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          if (!_isLoading && _gifs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Powered by GIPHY',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
            ),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

