import '../models/readme_element.dart';
import '../core/constants/social_platforms.dart';
import '../core/constants/readme_translations.dart';

class MarkdownGenerator {
  String generate(List<ReadmeElement> elements, {
    Map<String, String>? variables,
    String listBullet = '*',
    int sectionSpacing = 1,
    String targetLanguage = 'en',
    bool isPreview = false,
  }) {
    final buffer = StringBuffer();
    final spacing = '\n' * (sectionSpacing + 1);

    for (int i = 0; i < elements.length; i++) {
      final element = elements[i];
      buffer.write(_generateElement(
        element, 
        listBullet: listBullet, 
        targetLanguage: targetLanguage, 
        allElements: elements,
        isPreview: isPreview,
      ));
      if (i < elements.length - 1) {
        buffer.write(spacing);
      }
    }

    var markdown = buffer.toString();
    
    if (variables != null) {
      variables.forEach((key, value) {
        markdown = markdown.replaceAll('[$key]', value);
      });
    }
    return markdown;
  }

  String _generateElement(ReadmeElement element, {
    String listBullet = '*', 
    String targetLanguage = 'en',
    List<ReadmeElement>? allElements,
    bool isPreview = false,
  }) {
    if (element is HeadingElement) {
      final translatedText = ReadmeTranslations.get(element.text, targetLanguage);
      return '${'#' * element.level} $translatedText';
    } else if (element is ParagraphElement) {
      return element.text;
    } else if (element is ImageElement) {
      if (!isPreview && element.width != null && element.width! > 0) {
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
      buffer.write('| ${element.headers.join(' | ')} |');
      buffer.writeln();
      buffer.write('|');
      for (final align in element.alignments) {
        switch (align) {
          case ColumnAlignment.left: buffer.write(' :--- |'); break;
          case ColumnAlignment.center: buffer.write(' :---: |'); break;
          case ColumnAlignment.right: buffer.write(' ---: |'); break;
        }
      }
      buffer.writeln();
      for (final row in element.rows) {
        buffer.write('| ${row.join(' | ')} |');
        buffer.writeln();
      }
      return buffer.toString().trim();
    } else if (element is IconElement) {
      if (isPreview) {
        return '![${element.name}](${element.url})';
      }
      return '<img src="${element.url}" alt="${element.name}" width="${element.size.toInt()}" height="${element.size.toInt()}"/>';
    } else if (element is EmbedElement) {
      if (element.typeName == 'youtube') {
        final videoId = Uri.tryParse(element.url)?.queryParameters['v'] ?? '';
        if (videoId.isNotEmpty) {
          return '[![${element.typeName}](https://img.youtube.com/vi/$videoId/0.jpg)](${element.url})';
        }
        return '[${element.typeName}](${element.url})';
      } else if (element.typeName == 'codepen') {
        final uri = Uri.tryParse(element.url);
        if (uri != null && uri.pathSegments.length >= 3) {
          final user = uri.pathSegments[0];
          final slug = uri.pathSegments[2];
          return '[![CodePen](https://shots.codepen.io/$user/pen/$slug-800.jpg)](${element.url})';
        }
        return '[CodePen](${element.url})';
      }
      return '[${element.typeName}](${element.url})';
    } else if (element is ContributorsElement) {
      if (element.repoName.isEmpty) return '';
      if (isPreview) {
        return '![Contributors](https://contrib.rocks/image?repo=${element.repoName})';
      }
      if (element.style == 'grid') {
        return '<a href="https://github.com/${element.repoName}/graphs/contributors">\n  <img src="https://contrib.rocks/image?repo=${element.repoName}" alt="Contributors" />\n</a>';
      }
      return '[Contributors](https://github.com/${element.repoName}/graphs/contributors)';
    } else if (element is GitHubStatsElement) {
      final e = element;
      final buffer = StringBuffer();
      if (e.showStars) buffer.write('[![Stars](https://img.shields.io/github/stars/${e.repoName}?style=social)](https://github.com/${e.repoName}) ');
      if (e.showForks) buffer.write('[![Forks](https://img.shields.io/github/forks/${e.repoName}?style=social)](https://github.com/${e.repoName}/network/members) ');
      if (e.showIssues) buffer.write('[![Issues](https://img.shields.io/github/issues/${e.repoName})](https://github.com/${e.repoName}/issues) ');
      if (e.showLicense) buffer.write('[![License](https://img.shields.io/github/license/${e.repoName})](https://github.com/${e.repoName}/blob/master/LICENSE) ');
      return buffer.toString().trim();
    } else if (element is MermaidElement) {
      return '```mermaid\n${element.code}\n```';
    } else if (element is TOCElement) {
      if (allElements == null) return '<!-- TOC -->';
      final buffer = StringBuffer();
      buffer.writeln('## ${ReadmeTranslations.get('Table of Contents', targetLanguage)}');
      for (final e in allElements) {
        if (e is HeadingElement) {
          final indent = '  ' * (e.level - 1);
          final anchor = e.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s-]'), '').replaceAll(RegExp(r'\s+'), '-');
          buffer.writeln('$indent- [${e.text}](#$anchor)');
        }
      }
      return buffer.toString().trim();
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
    } else if (element is RawElement) {
      if (isPreview) return '*[Raw HTML/CSS Hidden in Preview]*';
      if (element.css.isNotEmpty) return '<style>\n${element.css}\n</style>\n\n${element.content}';
      return element.content;
    } else if (element is CollapsibleElement) {
      if (isPreview) return '### ${element.summary}\n${element.content}';
      return '<details>\n<summary>${element.summary}</summary>\n\n${element.content}\n</details>';
    } else if (element is DynamicWidgetElement) {
      switch (element.widgetType) {
        case DynamicWidgetType.spotify:
          return '[![Spotify](https://spotify-github-profile.vercel.app/api/view?uid=${element.identifier}&cover_image=true&theme=${element.theme}&show_offline=true&background_color=121212&interchange=true&bar_color=53b14f&bar_color_cover=false)](https://open.spotify.com/user/${element.identifier})';
        case DynamicWidgetType.youtube:
          return '[![YouTube Channel](https://github-readme-youtube-cards.vercel.app/?channel_id=${element.identifier}&theme=${element.theme})](${element.identifier})';
        case DynamicWidgetType.medium:
           return '[![Medium](https://github-readme-medium-recent-article.vercel.app/medium/@${element.identifier}/0)](https://medium.com/@${element.identifier})';
        case DynamicWidgetType.activity:
           return '![GitHub Activity Graph](https://activity-graph.herokuapp.com/graph?username=${element.identifier}&theme=${element.theme})';
      }
    }
    return '';
  }
}
