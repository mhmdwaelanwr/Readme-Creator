import 'package:markdown/markdown.dart' as md;
import '../models/readme_element.dart';
import '../utils/social_platforms.dart';

class MarkdownImporter {
  List<ReadmeElement> parse(String markdown) {
    final List<ReadmeElement> elements = [];
    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubWeb,
      encodeHtml: false,
    );

    // Pre-process to extract comments like <!-- TOC -->
    if (markdown.contains('<!-- TOC -->')) {
      // We can't easily inject this into the AST stream as a node.
      // But we can check for it later or handle it if we parse block by block.
      // The markdown parser ignores comments.
      // Let's split by TOC if present? No, that's messy.
      // Let's just check if we can find it in the raw text and insert a placeholder element?
      // Or better, if we encounter a specific pattern.
      // For now, let's stick to AST.
    }

    final nodes = document.parseLines(markdown.split('\n'));

    for (final node in nodes) {
      if (node is md.Element) {
        _parseElement(node, elements);
      } else if (node is md.Text) {
        if (node.text.trim().isNotEmpty) {
          elements.add(ParagraphElement(text: node.text));
        }
      }
    }

    return _postProcessElements(elements);
  }

  List<ReadmeElement> _postProcessElements(List<ReadmeElement> elements) {
    // Group adjacent badges into a single paragraph or keep them separate?
    // Actually, we want to detect SocialsElement.
    // If we have a paragraph that contains ONLY images that are social links, convert to SocialsElement.
    // Or if we have a list of links that are social links.

    final List<ReadmeElement> processed = [];

    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];

      // Check for Socials
      if (element is ParagraphElement) {
        // Check if paragraph text is just a collection of social links
        // This is hard because we only have the text representation.
        // We need to parse the text back to check for links?
        // Or we should have detected it during parsing.
        // Let's try to detect it during parsing instead.
        processed.add(element);
      } else {
        processed.add(element);
      }
    }
    return processed;
  }

  void _parseElement(md.Element node, List<ReadmeElement> elements) {
    switch (node.tag) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        final level = int.tryParse(node.tag.substring(1)) ?? 1;
        final text = node.textContent;
        elements.add(HeadingElement(text: text, level: level));
        break;

      case 'p':
        // Check for special content in paragraph
        if (_isSocialsParagraph(node)) {
          elements.add(_parseSocials(node));
        } else if (_isBadgeParagraph(node)) {
           // If it's a badge paragraph, we might want to add them as individual BadgeElements
           // or keep them as a paragraph with images.
           // Our BadgeElement is a single badge.
           // If we have multiple, we can't represent them as a list of BadgeElements easily in the UI (they would stack vertically).
           // So we should probably keep them as a ParagraphElement with images for now,
           // UNLESS we have a "BadgesRowElement" (which we don't, but we have SocialsElement).
           // Let's treat them as Paragraph for now, but maybe we can extract single badges.
           // If there is only ONE badge, we can convert to BadgeElement.
           if (_countChildren(node) == 1) {
             final child = node.children!.first;
             if (child is md.Element && child.tag == 'a') {
                // Linked Badge
                final img = child.children!.firstWhere((c) => c is md.Element && c.tag == 'img') as md.Element;
                final src = img.attributes['src'] ?? '';
                final href = child.attributes['href'] ?? '';
                final alt = img.attributes['alt'] ?? '';
                elements.add(BadgeElement(imageUrl: src, targetUrl: href, label: alt));
             } else if (child is md.Element && child.tag == 'img') {
                // Unlinked Badge
                final src = child.attributes['src'] ?? '';
                final alt = child.attributes['alt'] ?? '';
                elements.add(BadgeElement(imageUrl: src, label: alt));
             }
           } else {
             // Multiple badges - keep as paragraph
             final text = _reconstructMarkdown(node.children);
             if (text.trim().isNotEmpty) {
                elements.add(ParagraphElement(text: text));
             }
           }
        } else if (node.children != null &&
            node.children!.length == 1 &&
            node.children!.first is md.Element &&
            (node.children!.first as md.Element).tag == 'img') {
          _parseImage(node.children!.first as md.Element, elements);
        } else {
          final text = _reconstructMarkdown(node.children);
          if (text.trim().isNotEmpty) {
             elements.add(ParagraphElement(text: text));
          }
        }
        break;

      case 'img':
        _parseImage(node, elements);
        break;

      case 'pre':
        if (node.children != null && node.children!.isNotEmpty) {
          final codeNode = node.children!.first;
          if (codeNode is md.Element && codeNode.tag == 'code') {
            final code = codeNode.textContent;
            String language = '';
            if (codeNode.attributes['class'] != null) {
              language = codeNode.attributes['class']!.replaceAll('language-', '');
            }

            if (language == 'mermaid') {
              elements.add(MermaidElement(code: code));
            } else {
              elements.add(CodeBlockElement(code: code, language: language));
            }
          }
        }
        break;

      case 'ul':
      case 'ol':
        final isOrdered = node.tag == 'ol';
        final items = <String>[];
        if (node.children != null) {
          for (final child in node.children!) {
            if (child is md.Element && child.tag == 'li') {
              items.add(_reconstructMarkdown(child.children));
            }
          }
        }
        if (items.isNotEmpty) {
          elements.add(ListElement(items: items, isOrdered: isOrdered));
        }
        break;

      case 'table':
        _parseTable(node, elements);
        break;

      case 'blockquote':
         final text = _reconstructMarkdown(node.children);
         if (text.trim().isNotEmpty) {
            elements.add(ParagraphElement(text: '> $text'));
         }
         break;

      case 'hr':
         elements.add(ParagraphElement(text: '---'));
         break;

      default:
        // Try to handle HTML tags that markdown parser exposes
        if (node.tag == 'div' || node.tag == 'center') {
           // Often used for alignment. We just extract content.
           // If children are block elements, parse them.
           if (node.children != null) {
             for (final child in node.children!) {
               if (child is md.Element) {
                 _parseElement(child, elements);
               } else if (child is md.Text) {
                 if (child.text.trim().isNotEmpty) {
                   elements.add(ParagraphElement(text: child.text));
                 }
               }
             }
           }
        }
        break;
    }
  }

  bool _isSocialsParagraph(md.Element node) {
    // Check if all children are links or images that look like social links
    if (node.children == null || node.children!.isEmpty) return false;

    int socialCount = 0;
    int otherCount = 0;

    for (final child in node.children!) {
      if (child is md.Text) {
        if (child.text.trim().isNotEmpty) otherCount++;
        continue;
      }

      if (child is md.Element) {
        if (child.tag == 'a') {
          final href = child.attributes['href'] ?? '';
          if (_isSocialLink(href)) {
            socialCount++;
          } else {
            otherCount++;
          }
        } else if (child.tag == 'img') {
           // Images might be badges, but if they are not wrapped in <a>, they are likely not social links (except maybe just icons)
           otherCount++;
        } else if (child.tag == 'br') {
          // Ignore breaks
        } else {
          otherCount++;
        }
      }
    }

    return socialCount > 0 && otherCount == 0;
  }

  bool _isSocialLink(String url) {
    for (final platform in SocialPlatforms.platforms.values) {
      // Simple check: does URL contain platform name?
      // Better: check domain.
      // urlBuilder usually returns full URL.
      // We can check if the URL matches the pattern or domain.
      // Let's check if it contains the domain.
      final domain = Uri.tryParse(platform.urlBuilder('test'))?.host;
      if (domain != null && url.contains(domain)) return true;
    }
    return false;
  }

  SocialsElement _parseSocials(md.Element node) {
    final profiles = <SocialProfile>[];

    for (final child in node.children!) {
      if (child is md.Element && child.tag == 'a') {
        final href = child.attributes['href'] ?? '';
        for (final entry in SocialPlatforms.platforms.entries) {
          final platformName = entry.key;
          final platform = entry.value;
          final domain = Uri.tryParse(platform.urlBuilder('test'))?.host;

          if (domain != null && href.contains(domain)) {
            // Extract username
            // This is tricky as URL structures vary.
            // But we can just store the platform and maybe try to extract username or just use the URL?
            // SocialProfile expects username.
            // Let's try to extract last part of path.
            final uri = Uri.tryParse(href);
            if (uri != null) {
              String username = '';
              if (uri.pathSegments.isNotEmpty) {
                username = uri.pathSegments.last;
                // Remove @ if present
                if (username.startsWith('@')) username = username.substring(1);
              }
              profiles.add(SocialProfile(platform: platformName, username: username));
            }
            break;
          }
        }
      }
    }

    return SocialsElement(profiles: profiles);
  }

  bool _isBadgeParagraph(md.Element node) {
    // Check if children are images with shields.io
    if (node.children == null) return false;
    for (final child in node.children!) {
      if (child is md.Element) {
        if (child.tag == 'img') {
          final src = child.attributes['src'] ?? '';
          if (src.contains('shields.io')) return true;
        } else if (child.tag == 'a') {
           // Check children of a
           if (child.children != null) {
             for (final sub in child.children!) {
               if (sub is md.Element && sub.tag == 'img') {
                 final src = sub.attributes['src'] ?? '';
                 if (src.contains('shields.io')) return true;
               }
             }
           }
        }
      }
    }
    return false;
  }

  int _countChildren(md.Element node) {
    if (node.children == null) return 0;
    return node.children!.where((c) => c is md.Element || (c is md.Text && c.text.trim().isNotEmpty)).length;
  }

  void _parseImage(md.Element node, List<ReadmeElement> elements) {
    final src = node.attributes['src'] ?? '';
    final alt = node.attributes['alt'] ?? '';
    // Check if it's a badge (often linked)
    // But here we just have img.
    // If it was wrapped in <a>, the parent would be <p><a><img></a></p> or just <a><img></a>
    // The parser might handle this differently.
    // For now, simple image.
    elements.add(ImageElement(url: src, altText: alt));
  }

  void _parseTable(md.Element node, List<ReadmeElement> elements) {
    // Table parsing logic
    // <thead> <tr> <th>...
    // <tbody> <tr> <td>...
    final headers = <String>[];
    final rows = <List<String>>[];
    final alignments = <ColumnAlignment>[];

    if (node.children == null) return;

    for (final child in node.children!) {
      if (child is md.Element) {
        if (child.tag == 'thead') {
          if (child.children != null) {
            for (final row in child.children!) {
              if (row is md.Element && row.tag == 'tr') {
                if (row.children != null) {
                  for (final cell in row.children!) {
                    if (cell is md.Element && cell.tag == 'th') {
                      headers.add(cell.textContent);
                      // Check alignment style if present (markdown package might not expose it easily in AST attributes for GFM tables)
                      // Default to left
                      alignments.add(ColumnAlignment.left);
                    }
                  }
                }
              }
            }
          }
        } else if (child.tag == 'tbody') {
          if (child.children != null) {
            for (final row in child.children!) {
              if (row is md.Element && row.tag == 'tr') {
                final rowData = <String>[];
                if (row.children != null) {
                  for (final cell in row.children!) {
                    if (cell is md.Element && cell.tag == 'td') {
                      rowData.add(cell.textContent);
                    }
                  }
                }
                rows.add(rowData);
              }
            }
          }
        }
      }
    }

    if (headers.isNotEmpty) {
      elements.add(TableElement(headers: headers, rows: rows, alignments: alignments));
    }
  }

  String _reconstructMarkdown(List<md.Node>? nodes) {
    if (nodes == null) return '';
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is md.Text) {
        buffer.write(node.text);
      } else if (node is md.Element) {
        if (node.tag == 'strong' || node.tag == 'b') {
          buffer.write('**${_reconstructMarkdown(node.children)}**');
        } else if (node.tag == 'em' || node.tag == 'i') {
          buffer.write('*${_reconstructMarkdown(node.children)}*');
        } else if (node.tag == 'code') {
          buffer.write('`${node.textContent}`');
        } else if (node.tag == 'a') {
          final href = node.attributes['href'] ?? '';
          buffer.write('[${_reconstructMarkdown(node.children)}]($href)');
        } else if (node.tag == 'img') {
           final src = node.attributes['src'] ?? '';
           final alt = node.attributes['alt'] ?? '';
           buffer.write('![$alt]($src)');
        } else if (node.tag == 'br') {
           buffer.write('\n');
        } else if (node.tag == 'del') {
           buffer.write('~~${_reconstructMarkdown(node.children)}~~');
        } else {
          buffer.write(_reconstructMarkdown(node.children));
        }
      }
    }
    return buffer.toString();
  }
}

