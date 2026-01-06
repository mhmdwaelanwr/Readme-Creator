import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
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
      // Use MarkdownBody for rich text support including images and links
      return MarkdownBody(
        data: e.text,
        styleSheet: MarkdownStyleSheet(
          p: GoogleFonts.inter(color: textColor, fontSize: 16, height: 1.5),
          strong: GoogleFonts.inter(fontWeight: FontWeight.bold),
          em: GoogleFonts.inter(fontStyle: FontStyle.italic),
          code: GoogleFonts.firaCode(
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            color: textColor,
          ),
          a: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          blockquote: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        onTapLink: (text, href, title) async {
          if (href != null) {
            final uri = Uri.tryParse(href);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          }
        },
        // imageBuilder is deprecated, but we use it for simplicity for now as simple replacement isn't obvious without more context
        // or we can use builders: {'img': ...}
        // Let's stick to imageBuilder as it works, but suppress warning if possible? No.
        // Let's try to use builders.
        builders: {
          'img': BadgeImageBuilder(builder: _buildBadgeImage),
        },
      );
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
                    Flexible(
                      child: Text(
                        e.language.toUpperCase(),
                        style: GoogleFonts.firaCode(
                          fontSize: 10,
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
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
          border: Border(left: BorderSide(color: Colors.grey.shade400, width: 4)),
        ),
        child: Text(
          e.text,
          style: GoogleFonts.inter(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            fontStyle: FontStyle.italic,
            fontSize: 16,
          ),
        ),
      );
    } else if (element is DividerElement) {
      return const Divider(thickness: 2);
    } else if (element is CollapsibleElement) {
      final e = element as CollapsibleElement;
      return ExpansionTile(
        title: Text(e.summary, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: textColor)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(e.content, style: GoogleFonts.inter(color: textColor)),
          ),
        ],
      );
    } else if (element is DynamicWidgetElement) {
      final e = element as DynamicWidgetElement;
      String imageUrl = '';
      String altText = '';

      switch (e.widgetType) {
        case DynamicWidgetType.spotify:
          // Using novatorem for Spotify
          // https://github.com/novatorem/novatorem
          // URL: https://novatorem.vercel.app/api/spotify?background_color=0d1117&border_color=ffffff&spotify_client_id=...
          // Simplified for demo:
          // We can use https://spotify-github-profile.vercel.app/api/view?uid={identifier}&cover_image=true&theme={theme}
          // Or https://github-readme-stats.vercel.app/api/pin/?username={identifier}&repo={repo} (not spotify)
          // Let's use a generic placeholder or a known service if identifier is present.
          if (e.identifier.isNotEmpty) {
            // Example service: https://github.com/novatorem/novatorem
            // Note: This usually requires user to deploy their own instance or use a public one.
            // Let's use a common public one for demo purposes or fallback to a placeholder.
            // https://spotify-github-profile.vercel.app/api/view?uid=...
            imageUrl = 'https://spotify-github-profile.vercel.app/api/view?uid=${e.identifier}&cover_image=true&theme=${e.theme}&bar_color=53b14f&bar_color_cover=true';
            altText = 'Spotify Status';
          } else {
            return _buildPlaceholderWidget(context, 'Spotify Status', Icons.music_note, 'Enter Spotify UID');
          }
          break;
        case DynamicWidgetType.youtube:
          // https://github.com/DenverCoder1/github-readme-youtube-cards
          if (e.identifier.isNotEmpty) {
            imageUrl = 'https://ytcards.demolab.com/?id=${e.identifier}&theme=${e.theme}&layout=wide';
            altText = 'Latest YouTube Video';
          } else {
            return _buildPlaceholderWidget(context, 'Latest YouTube Video', Icons.video_library, 'Enter Channel ID');
          }
          break;
        case DynamicWidgetType.medium:
          // https://github.com/DenverCoder1/github-readme-medium-recent-article
          // Or https://github.com/vn7n24fzkq/github-profile-summary-cards
          // Let's use: https://github-readme-medium-recent-article.vercel.app/medium/@{username}/0
          if (e.identifier.isNotEmpty) {
            imageUrl = 'https://github-readme-medium-recent-article.vercel.app/medium/@${e.identifier}/0';
            altText = 'Latest Medium Article';
          } else {
            return _buildPlaceholderWidget(context, 'Latest Medium Article', Icons.article, 'Enter Medium Username');
          }
          break;
        case DynamicWidgetType.activity:
          // https://github.com/ashutosh00710/github-readme-activity-graph
          if (e.identifier.isNotEmpty) {
            imageUrl = 'https://github-readme-activity-graph.vercel.app/graph?username=${e.identifier}&theme=${e.theme}';
            altText = 'GitHub Activity Graph';
          } else {
            return _buildPlaceholderWidget(context, 'Activity Graph', Icons.show_chart, 'Enter GitHub Username');
          }
          break;
      }

      return Center(
        child: Semantics(
          label: altText,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Column(
              children: [
                const Icon(Icons.error, color: Colors.red),
                Text('Failed to load widget. Check ID.', style: GoogleFonts.inter(color: Colors.red, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    } else if (element is RawElement) {
      final e = element as RawElement;
      // If we are in "Preview" mode (which ElementRenderer usually is), we should try to render it if possible.
      // But RawElement contains raw Markdown or HTML.
      // Flutter Markdown can render Markdown, and basic HTML.
      // But if it contains complex HTML/JS, we can't render it in Flutter perfectly.
      // We show a preview box that indicates what's there.
      // The user complained "not showing code in preview".
      // They probably meant they want to see the rendered result of the raw markdown?
      // Or they want to see the code itself?
      // "not showing code in preview" -> If I type `<b>Bold</b>`, I expect to see "<b>Bold</b>" or "**Bold**"?
      // Usually "Preview" means "Rendered Result".
      // If they put `<b>Bold</b>`, they expect "Bold" (bolded).
      // My implementation shows the CODE in a box.
      // "Raw Markdown / HTML" usually means "Insert this text AS IS into the file".
      // So in the final file it is `<b>Bold</b>`.
      // If the user views the final file on GitHub, they see "**Bold**".
      // In MY app preview, I am showing the source code because I can't guarantee rendering of raw HTML.
      // BUT if the user wants to see "drag & drop" preview, maybe they want rendered markdown?
      // Use MarkdownBody to render the content.

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.code, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Raw Content', style: GoogleFonts.firaCode(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            // Render the raw markdown/html as best as we can
            MarkdownBody(
              data: e.content,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.inter(color: textColor, fontSize: 16),
              ),
              onTapLink: (text, href, title) async {
                  if (href != null) {
                    final uri = Uri.tryParse(href);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  }
              },
            ),
            if (e.css.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              Text('Applied CSS:', style: GoogleFonts.firaCode(fontSize: 10, color: Colors.grey)),
              Text(
                e.css,
                style: GoogleFonts.firaCode(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlaceholderWidget(BuildContext context, String title, IconData icon, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 4),
          Text(message, style: GoogleFonts.inter(color: Colors.grey)),
        ],
      ),
    );
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

    // Use MarkdownBody for rich text in cells
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet(
       p: GoogleFonts.inter(fontSize: 14, color: textColor),
      ),
      builders: {
        'img': BadgeImageBuilder(builder: _buildBadgeImage),
      },
    );
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

class BadgeImageBuilder extends MarkdownElementBuilder {
  final Widget Function(String url, {double? width, double? height}) builder;

  BadgeImageBuilder({required this.builder});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final url = element.attributes['src'] ?? '';
    // Basic attempt to parse width/height if present in style (unlikely in simple markdown) or html attributes
    // In typical markdown ![alt](url), no attributes.
    // If it's HTML <img>, we might get them.
    // But flutter_markdown handles HTML tags by converting them.
    return builder(url);
  }
}
