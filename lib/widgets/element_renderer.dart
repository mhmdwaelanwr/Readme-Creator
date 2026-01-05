import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/readme_element.dart';
import '../providers/project_provider.dart';
import '../core/constants/social_platforms.dart';

class ElementRenderer extends StatelessWidget {
  final ReadmeElement element;

  const ElementRenderer({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    if (element is HeadingElement) {
      final e = element as HeadingElement;
      TextStyle style;
      Widget content;

      switch (e.level) {
        case 1:
          style = GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textColor,
            height: 1.2,
          );
          content = Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50), width: 1)),
            ),
            child: Text(e.text, style: style),
          );
          break;
        case 2:
          style = GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1.3,
          );
          content = Container(
            padding: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50), width: 1)),
            ),
            child: Text(e.text, style: style),
          );
          break;
        case 3:
          style = GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.4,
          );
          content = Text(e.text, style: style);
          break;
        default:
          style = GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          );
          content = Text(e.text, style: style);
      }
      return content;
    } else if (element is ParagraphElement) {
      final e = element as ParagraphElement;
      return _buildRichText(e.text, textColor);
    } else if (element is ImageElement) {
      final e = element as ImageElement;
      if (e.localData != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                e.localData!,
                width: e.width,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
              ),
            ),
            if (e.altText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(e.altText, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
              ),
          ],
        );
      }
      if (e.url.isEmpty) return const Text('Empty Image URL', style: TextStyle(color: Colors.red));

      Widget imageWidget;
      if (e.url.toLowerCase().endsWith('.svg')) {
        imageWidget = SvgPicture.network(
          e.url,
          width: e.width,
          placeholderBuilder: (BuildContext context) => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
        );
      } else {
        imageWidget = CachedNetworkImage(
          imageUrl: e.url,
          width: e.width,
          placeholder: (context, url) => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget),
          if (e.altText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(e.altText, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
            ),
        ],
      );
    } else if (element is LinkButtonElement) {
      final e = element as LinkButtonElement;
      return ElevatedButton(
        onPressed: null, // Disabled in editor
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(e.text),
      );
    } else if (element is CodeBlockElement) {
      final e = element as CodeBlockElement;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF6F8FA),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Window Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                border: Border(bottom: BorderSide(color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5))),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 5, backgroundColor: Color(0xFFFF5F56)),
                  const SizedBox(width: 6),
                  const CircleAvatar(radius: 5, backgroundColor: Color(0xFFFFBD2E)),
                  const SizedBox(width: 6),
                  const CircleAvatar(radius: 5, backgroundColor: Color(0xFF27C93F)),
                  const Spacer(),
                  if (e.language.isNotEmpty)
                    Text(
                      e.language.toUpperCase(),
                      style: GoogleFonts.firaCode(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              child: HighlightView(
                e.code,
                language: e.language.isEmpty ? 'plaintext' : e.language,
                theme: isDark ? draculaTheme : githubTheme,
                padding: const EdgeInsets.all(16),
                textStyle: GoogleFonts.firaCode(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (element is ListElement) {
      final e = element as ListElement;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: e.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final prefix = e.isOrdered ? '${index + 1}.' : '•';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    prefix,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.inter(color: textColor, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (element is BadgeElement) {
      final e = element as BadgeElement;
      if (e.imageUrl.isEmpty) return const Text('Empty Badge URL', style: TextStyle(color: Colors.red));

      return _buildBadgeImage(e.imageUrl);
    } else if (element is IconElement) {
      final e = element as IconElement;
      if (e.url.isEmpty) return Text('Empty Icon URL', style: GoogleFonts.inter(color: Colors.red));

      Widget iconWidget;
      if (e.url.toLowerCase().endsWith('.svg')) {
        iconWidget = SvgPicture.network(
          e.url,
          width: e.size,
          height: e.size,
          placeholderBuilder: (BuildContext context) => SizedBox(width: e.size, height: e.size, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
        );
      } else {
        iconWidget = CachedNetworkImage(
          imageUrl: e.url,
          width: e.size,
          height: e.size,
          placeholder: (context, url) => SizedBox(width: e.size, height: e.size, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
        );
      }

      return Column(
        children: [
          iconWidget,
          const SizedBox(height: 4),
          Text(e.name, style: GoogleFonts.inter(fontSize: 10, color: textColor.withAlpha(150))),
        ],
      );
    } else if (element is EmbedElement) {
      final e = element as EmbedElement;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(Icons.code, size: 40, color: isDark ? Colors.grey[500] : Colors.grey[600]),
            const SizedBox(height: 8),
            Text('Embed: ${e.typeName}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(e.url, style: GoogleFonts.inter(color: textColor.withAlpha(180), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('(Embeds are rendered as HTML in Markdown)', style: GoogleFonts.inter(fontSize: 10, fontStyle: FontStyle.italic, color: textColor.withAlpha(150))),
          ],
        ),
      );
    } else if (element is GitHubStatsElement) {
      final e = element as GitHubStatsElement;
      if (e.repoName.isEmpty) return Text('Enter Repo Name (user/repo)', style: GoogleFonts.inter(color: Colors.red));

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (e.showStars)
            _buildBadgeImage('https://img.shields.io/github/stars/${e.repoName}?style=social', height: 20, width: null),
          if (e.showForks)
            _buildBadgeImage('https://img.shields.io/github/forks/${e.repoName}?style=social', height: 20, width: null),
          if (e.showIssues)
            _buildBadgeImage('https://img.shields.io/github/issues/${e.repoName}', height: 20, width: null),
          if (e.showLicense)
            _buildBadgeImage('https://img.shields.io/github/license/${e.repoName}', height: 20, width: null),
        ],
      );
    } else if (element is ContributorsElement) {
      final e = element as ContributorsElement;
      if (e.repoName.isEmpty) return Text('Enter Repo Name (user/repo)', style: GoogleFonts.inter(color: Colors.red));

      // In editor, we just show a placeholder or maybe fetch if we want to be fancy.
      // For now, let's show a static representation to avoid too many API calls during editing.
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(Icons.people, size: 40, color: isDark ? Colors.grey[500] : Colors.grey[600]),
            const SizedBox(height: 8),
            Text('Contributors: ${e.repoName}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(5, (index) => const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 20, color: Colors.white),
              )),
            ),
            const SizedBox(height: 8),
            Text('(Actual contributors will be fetched on export)', style: GoogleFonts.inter(fontSize: 10, fontStyle: FontStyle.italic, color: textColor.withAlpha(150))),
          ],
        ),
      );
    } else if (element is TableElement) {
      final e = element as TableElement;
      // Ensure consistency between headers and row cells to prevent DataTable assertions
      final columnCount = e.headers.length;
      final colorScheme = Theme.of(context).colorScheme;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(100)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(colorScheme.primaryContainer.withAlpha(50)),
              dataRowColor: WidgetStateProperty.all(isDark ? colorScheme.surfaceContainer : colorScheme.surface),
              border: TableBorder(
                horizontalInside: BorderSide(color: colorScheme.outlineVariant.withAlpha(50)),
                verticalInside: BorderSide(color: colorScheme.outlineVariant.withAlpha(50)),
              ),
              columns: e.headers.map((h) => DataColumn(
                label: Text(
                  h,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
              )).toList(),
              rows: e.rows.map((row) {
                // Pad row with empty strings if it has fewer cells than columns
                final cells = List<String>.from(row);
                while (cells.length < columnCount) {
                  cells.add('');
                }
                // Truncate if it has more (though UI prevents this, data might be stale)
                if (cells.length > columnCount) {
                  cells.length = columnCount;
                }

                return DataRow(
                  cells: cells.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cell = entry.value;
                    Alignment alignment = Alignment.centerLeft;
                    if (index < e.alignments.length) {
                       switch(e.alignments[index]) {
                         case ColumnAlignment.left: alignment = Alignment.centerLeft; break;
                         case ColumnAlignment.center: alignment = Alignment.center; break;
                         case ColumnAlignment.right: alignment = Alignment.centerRight; break;
                       }
                    }
                    return DataCell(
                      Container(
                        alignment: alignment,
                        width: double.infinity,
                        child: _buildCellContent(cell, textColor),
                      )
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      );
    } else if (element is MermaidElement) {
      final e = element as MermaidElement;
      final base64Code = base64Encode(utf8.encode(e.code));
      final imageUrl = 'https://mermaid.ink/img/$base64Code';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white, // Mermaid usually needs white background
        ),
        child: Column(
          children: [
            Image.network(
              imageUrl,
              errorBuilder: (context, error, stackTrace) => const Column(
                children: [
                  Icon(Icons.broken_image, color: Colors.red),
                  SizedBox(height: 8),
                  Text('Failed to render diagram. Check your syntax.', style: TextStyle(color: Colors.red)),
                ],
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      );
    } else if (element is TOCElement) {
      final e = element as TOCElement;
      final provider = Provider.of<ProjectProvider>(context);
      final headings = provider.elements.whereType<HeadingElement>().toList();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withAlpha(100)),
          borderRadius: BorderRadius.circular(8),
          color: isDark ? Colors.grey[850] : Colors.grey[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
            const SizedBox(height: 8),
            if (headings.isEmpty)
              const Text('No headings found.', style: TextStyle(color: Colors.grey)),
            ...headings.map((h) {
              return Padding(
                padding: EdgeInsets.only(left: (h.level - 1) * 16.0, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        h.text,
                        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    } else if (element is SocialsElement) {
      final e = element as SocialsElement;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: e.profiles.map((p) {
          String badgeUrl = SocialPlatforms.getBadgeUrl(p.platform, e.style);
          if (badgeUrl.isEmpty) return Chip(label: Text('${p.platform}: ${p.username}'));

          return _buildBadgeImage(badgeUrl, height: 28, width: null);
        }).toList(),
      );
    } else if (element is BlockquoteElement) {
      final e = element as BlockquoteElement;
      return Container(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Colors.grey[400]!, width: 4)),
        ),
        child: Text(
          e.text,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      );
    } else if (element is DividerElement) {
      return const Divider(thickness: 2);
    } else if (element is CollapsibleElement) {
      final e = element as CollapsibleElement;
      return ExpansionTile(
        title: Text(e.summary, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(e.content, style: TextStyle(color: textColor)),
          ),
        ],
      );
    }
    return Text('Unknown Element: ${element.type}');
  }

  Widget _buildRichText(String text, Color textColor) {
    final spans = <TextSpan>[];
    final exp = RegExp(r'(\*\*(.*?)\*\*)|(\*(.*?)\*)|(`(.*?)`)');
    int start = 0;

    for (final match in exp.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: GoogleFonts.inter(color: textColor, height: 1.6),
        ));
      }

      if (match.group(1) != null) { // Bold **text**
        spans.add(TextSpan(
          text: match.group(2),
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor, height: 1.6),
        ));
      } else if (match.group(3) != null) { // Italic *text*
        spans.add(TextSpan(
          text: match.group(4),
          style: GoogleFonts.inter(fontStyle: FontStyle.italic, color: textColor, height: 1.6),
        ));
      } else if (match.group(5) != null) { // Code `text`
        spans.add(TextSpan(
          text: match.group(6),
          style: GoogleFonts.firaCode(
            backgroundColor: Colors.grey.withAlpha(50),
            color: textColor,
            fontSize: 13,
          ),
        ));
      }
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: GoogleFonts.inter(color: textColor, height: 1.6),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildCellContent(String text, Color textColor) {
    // Check for Markdown image: ![alt](url)
    final imageRegex = RegExp(r'!\[(.*?)\]\((.*?)\)');
    final match = imageRegex.firstMatch(text);

    if (match != null) {
      final url = match.group(2) ?? '';
      if (url.isNotEmpty) {
        return _buildBadgeImage(url, height: 30, width: null);
      }
    }

    // Check for HTML image: <img src="url" ... />
    final htmlImageRegex = RegExp(r'<img[^>]+src="([^"]+)"[^>]*>');
    final htmlMatch = htmlImageRegex.firstMatch(text);

    if (htmlMatch != null) {
      final url = htmlMatch.group(1) ?? '';
      if (url.isNotEmpty) {
        return _buildBadgeImage(url, height: 30, width: null);
      }
    }

    return _buildRichText(text, textColor);
  }

  Widget _buildBadgeImage(String url, {double? height, double? width}) {
    String badgeUrl = url;
    // Force PNG for shields.io to avoid SVG rendering issues
    if (badgeUrl.contains('img.shields.io') && !badgeUrl.contains('.png') && !badgeUrl.contains('.svg')) {
       final uri = Uri.parse(badgeUrl);
       // Insert .png before query parameters
       final newPath = '${uri.path}.png';
       badgeUrl = uri.replace(path: newPath).toString();
    }

    // If it's a PNG (which we just forced for shields.io), use Image.network
    if (badgeUrl.endsWith('.png') || badgeUrl.contains('.png?')) {
       return Image.network(
        badgeUrl,
        height: height,
        width: width,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: width ?? 50,
            height: height ?? 20,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2))
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading badge: $badgeUrl, error: $error');
          return const Icon(Icons.broken_image);
        },
      );
    }

    return SvgPicture.network(
      badgeUrl,
      height: height,
      width: width,
      placeholderBuilder: (_) => SizedBox(
        width: width ?? 50,
        height: height ?? 20,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2))
      ),
    );
  }
}
