import '../models/readme_element.dart';
import '../core/constants/social_platforms.dart';

class MarkdownGenerator {
  String generate(List<ReadmeElement> elements, {
    Map<String, String>? variables,
    String listBullet = '*',
    int sectionSpacing = 1,
  }) {
    final buffer = StringBuffer();
    final spacing = '\n' * (sectionSpacing + 1); // 1 means \n\n (one empty line)

    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];
      buffer.write(_generateElement(element, listBullet: listBullet));
      if (i < elements.length - 1) {
        buffer.write(spacing);
      }
    }

    var markdown = buffer.toString();

    // Generate TOC if marker exists
    if (markdown.contains('<!-- TOC -->')) {
      final tocBuffer = StringBuffer();
      tocBuffer.writeln('## Table of Contents');
      for (final element in elements) {
        if (element is HeadingElement) {
          final indent = '  ' * (element.level - 1);
          final anchor = element.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s-]'), '').replaceAll(RegExp(r'\s+'), '-');
          tocBuffer.writeln('$indent- [${element.text}](#$anchor)');
        }
      }
      markdown = markdown.replaceAll('<!-- TOC -->', tocBuffer.toString());
    }

    if (variables != null) {
      variables.forEach((key, value) {
        markdown = markdown.replaceAll('[$key]', value);
      });
    }
    return markdown;
  }

  String _generateElement(ReadmeElement element, {String listBullet = '*'}) {
    if (element is HeadingElement) {
      return '${'#' * element.level} ${element.text}';
    } else if (element is ParagraphElement) {
      return element.text;
    } else if (element is ImageElement) {
      if (element.width != null && element.width! > 0) {
        return '<img src="${element.url}" alt="${element.altText}" width="${element.width!.toInt()}" />';
      }
      return '![${element.altText}](${element.url})';
    } else if (element is LinkButtonElement) {
      return '[${element.text}](${element.url})';
    } else if (element is CodeBlockElement) {
      return '```${element.language}\n${element.code}\n```';
    } else if (element is ListElement) {
      if (element.isOrdered) {
        return element.items.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n');
      }
      return element.items.map((item) => '$listBullet $item').join('\n');
    } else if (element is BadgeElement) {
      if (element.targetUrl.isNotEmpty) {
        return '[![${element.label}](${element.imageUrl})](${element.targetUrl})';
      }
      return '![${element.label}](${element.imageUrl})';
    } else if (element is TableElement) {
      final buffer = StringBuffer();
      // Headers
      buffer.write('| ${element.headers.join(' | ')} |');
      buffer.writeln();
      // Alignments
      buffer.write('|');
      for (final align in element.alignments) {
        switch (align) {
          case ColumnAlignment.left:
            buffer.write(' :--- |');
            break;
          case ColumnAlignment.center:
            buffer.write(' :---: |');
            break;
          case ColumnAlignment.right:
            buffer.write(' ---: |');
            break;
        }
      }
      buffer.writeln();
      // Rows
      for (final row in element.rows) {
        buffer.write('| ${row.join(' | ')} |');
        buffer.writeln();
      }
      return buffer.toString().trim();
    } else if (element is IconElement) {
      return '<img src="${element.url}" alt="${element.name}" width="${element.size.toInt()}" height="${element.size.toInt()}"/>';
    } else if (element is EmbedElement) {
      // Embeds usually require HTML or specific markdown syntax depending on the platform.
      // For GitHub, some embeds work, others don't.
      // Standard way is often just a link, but user asked for "Embed".
      // Let's provide a link with a preview if possible, or just the link if it's a gist.
      // GitHub Gists can be embedded in some markdown viewers via script, but not in standard GitHub README.
      // However, standard practice for "embedding" in README is often a screenshot linking to the content.
      // Since we can't easily generate screenshots here, we'll output a link.
      // BUT, the user request says "Generate HTML code suitable for embedding".
      // So let's try to generate something useful.

      if (element.typeName == 'youtube') {
        // YouTube thumbnail link
        final videoId = Uri.tryParse(element.url)?.queryParameters['v'] ?? '';
        if (videoId.isNotEmpty) {
          return '[![${element.typeName}](https://img.youtube.com/vi/$videoId/0.jpg)](${element.url})';
        }
        return '[${element.typeName}](${element.url})';
      } else if (element.typeName == 'codepen') {
        // CodePen screenshot
        // https://codepen.io/username/pen/slug
        final uri = Uri.tryParse(element.url);
        if (uri != null && uri.pathSegments.length >= 3) {
          final user = uri.pathSegments[0];
          final slug = uri.pathSegments[2];
          return '[![CodePen](https://shots.codepen.io/$user/pen/$slug-800.jpg)](${element.url})';
        }
        return '[CodePen](${element.url})';
      } else if (element.typeName == 'gist') {
        // Return a plain link for gists to keep generated markdown simple and predictable
        return '[gist](${element.url})';
      }

      // For others, usually just a link is safe for GitHub README.
      return '[${element.typeName}](${element.url})';
    } else if (element is ContributorsElement) {
      final e = element;
      if (e.repoName.isEmpty) return '';

      // We can't fetch data synchronously here.
      // Ideally, we should have fetched data before generation or use a placeholder that gets replaced.
      // For now, let's generate a placeholder comment or a link to contributors graph.
      // Or better, if we have the data (which we don't store in element), we could use it.
      // A robust solution would be to fetch data in the export step and pass it here, or use an image service.
      // Using contrib.rocks or similar service is the easiest way to get an image for markdown without fetching data manually.

      if (e.style == 'grid') {
        return '<a href="https://github.com/${e.repoName}/graphs/contributors">\n  <img src="https://contrib.rocks/image?repo=${e.repoName}" alt="Contributors" />\n</a>';
      } else {
        return '[Contributors](https://github.com/${e.repoName}/graphs/contributors)';
      }
    } else if (element is MermaidElement) {
      return '```mermaid\n${element.code}\n```';
    } else if (element is TOCElement) {
      // We can't generate the full TOC here easily because we need the full list of elements to find headings.
      // But _generateElement only takes one element.
      // We need to change the signature or pass the context.
      // However, we can return a placeholder and replace it in the main generate method?
      // Or we can just return a marker.
      return '<!-- TOC -->';
    } else if (element is SocialsElement) {
      final buffer = StringBuffer();
      for (final profile in element.profiles) {
        final badgeUrl = SocialPlatforms.getBadgeUrl(profile.platform, element.style);
        final targetUrl = SocialPlatforms.getTargetUrl(profile.platform, profile.username);
        if (badgeUrl.isNotEmpty && targetUrl.isNotEmpty) {
          buffer.write('[![${profile.platform}]($badgeUrl)]($targetUrl) ');
        }
      }
      return buffer.toString().trim();
    } else if (element is BlockquoteElement) {
      return element.text.split('\n').map((line) => '> $line').join('\n');
    } else if (element is DividerElement) {
      return '---';
    } else if (element is CollapsibleElement) {
      return '<details>\n<summary>${element.summary}</summary>\n\n${element.content}\n\n</details>';
    }
    return '';
  }
}
