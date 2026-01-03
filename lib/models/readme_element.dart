import 'package:uuid/uuid.dart';
import 'dart:typed_data';

enum ReadmeElementType {
  heading,
  paragraph,
  image,
  linkButton,
  codeBlock,
  list,
  badge,
  table,
  icon,
  embed,
  githubStats,
  contributors,
  mermaid,
  toc,
  socials,
}

abstract class ReadmeElement {
  final String id;
  final ReadmeElementType type;

  ReadmeElement({required this.type, String? id}) : id = id ?? const Uuid().v4();

  String get description;

  Map<String, dynamic> toJson();

  factory ReadmeElement.fromJson(Map<String, dynamic> json) {
    final type = ReadmeElementType.values.firstWhere((e) => e.toString() == json['type']);
    switch (type) {
      case ReadmeElementType.heading:
        return HeadingElement.fromJson(json);
      case ReadmeElementType.paragraph:
        return ParagraphElement.fromJson(json);
      case ReadmeElementType.image:
        return ImageElement.fromJson(json);
      case ReadmeElementType.linkButton:
        return LinkButtonElement.fromJson(json);
      case ReadmeElementType.codeBlock:
        return CodeBlockElement.fromJson(json);
      case ReadmeElementType.list:
        return ListElement.fromJson(json);
      case ReadmeElementType.badge:
        return BadgeElement.fromJson(json);
      case ReadmeElementType.table:
        return TableElement.fromJson(json);
      case ReadmeElementType.icon:
        return IconElement.fromJson(json);
      case ReadmeElementType.embed:
        return EmbedElement.fromJson(json);
      case ReadmeElementType.githubStats:
        return GitHubStatsElement.fromJson(json);
      case ReadmeElementType.contributors:
        return ContributorsElement.fromJson(json);
      case ReadmeElementType.mermaid:
        return MermaidElement.fromJson(json);
      case ReadmeElementType.toc:
        return TOCElement.fromJson(json);
      case ReadmeElementType.socials:
        return SocialsElement.fromJson(json);
    }
  }
}

class SocialProfile {
  final String platform;
  final String username;

  SocialProfile({required this.platform, required this.username});

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'username': username,
  };

  factory SocialProfile.fromJson(Map<String, dynamic> json) {
    return SocialProfile(
      platform: json['platform'],
      username: json['username'],
    );
  }
}

class SocialsElement extends ReadmeElement {
  List<SocialProfile> profiles;
  String style; // 'for-the-badge', 'flat', 'flat-square', 'plastic', 'social'

  SocialsElement({List<SocialProfile>? profiles, this.style = 'for-the-badge', super.id})
      : profiles = profiles ?? [],
        super(type: ReadmeElementType.socials);

  @override
  String get description => 'Social Links';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'profiles': profiles.map((e) => e.toJson()).toList(),
    'style': style,
  };

  factory SocialsElement.fromJson(Map<String, dynamic> json) {
    return SocialsElement(
      profiles: (json['profiles'] as List).map((e) => SocialProfile.fromJson(e)).toList(),
      style: json['style'] ?? 'for-the-badge',
      id: json['id'],
    );
  }
}

class MermaidElement extends ReadmeElement {
  String code;

  MermaidElement({this.code = 'graph TD;\n    A-->B;', super.id}) : super(type: ReadmeElementType.mermaid);

  @override
  String get description => 'Mermaid Diagram';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'code': code,
  };

  factory MermaidElement.fromJson(Map<String, dynamic> json) {
    return MermaidElement(
      code: json['code'] ?? '',
      id: json['id'],
    );
  }
}

class TOCElement extends ReadmeElement {
  String title;

  TOCElement({this.title = 'Table of Contents', super.id}) : super(type: ReadmeElementType.toc);

  @override
  String get description => 'Table of Contents';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'title': title,
  };

  factory TOCElement.fromJson(Map<String, dynamic> json) {
    return TOCElement(
      title: json['title'] ?? 'Table of Contents',
      id: json['id'],
    );
  }
}

class HeadingElement extends ReadmeElement {
  String text;
  int level; // 1, 2, 3

  HeadingElement({this.text = 'Heading', this.level = 1, super.id}) : super(type: ReadmeElementType.heading);

  @override
  String get description => 'Heading $level';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'text': text,
    'level': level,
  };

  factory HeadingElement.fromJson(Map<String, dynamic> json) {
    return HeadingElement(
      text: json['text'],
      level: json['level'],
      id: json['id'],
    );
  }
}

class ParagraphElement extends ReadmeElement {
  String text;

  ParagraphElement({this.text = 'Paragraph text', super.id}) : super(type: ReadmeElementType.paragraph);

  @override
  String get description => 'Paragraph';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'text': text,
  };

  factory ParagraphElement.fromJson(Map<String, dynamic> json) {
    return ParagraphElement(
      text: json['text'],
      id: json['id'],
    );
  }
}

class ImageElement extends ReadmeElement {
  String url;
  String altText;
  double? width;
  Uint8List? localData; // For local preview

  ImageElement({this.url = 'https://via.placeholder.com/150', this.altText = 'Image', this.width, this.localData, super.id}) : super(type: ReadmeElementType.image);

  @override
  String get description => 'Image';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'url': url,
    'altText': altText,
    'width': width,
    // We don't save localData to JSON as it's temporary for the session
  };

  factory ImageElement.fromJson(Map<String, dynamic> json) {
    return ImageElement(
      url: json['url'],
      altText: json['altText'],
      width: json['width'],
      id: json['id'],
    );
  }
}

class LinkButtonElement extends ReadmeElement {
  String text;
  String url;

  LinkButtonElement({this.text = 'Link', this.url = 'https://example.com', super.id}) : super(type: ReadmeElementType.linkButton);

  @override
  String get description => 'Link Button';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'text': text,
    'url': url,
  };

  factory LinkButtonElement.fromJson(Map<String, dynamic> json) {
    return LinkButtonElement(
      text: json['text'],
      url: json['url'],
      id: json['id'],
    );
  }
}

class CodeBlockElement extends ReadmeElement {
  String code;
  String language;

  CodeBlockElement({this.code = 'print("Hello World");', this.language = 'dart', super.id}) : super(type: ReadmeElementType.codeBlock);

  @override
  String get description => 'Code Block';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'code': code,
    'language': language,
  };

  factory CodeBlockElement.fromJson(Map<String, dynamic> json) {
    return CodeBlockElement(
      code: json['code'],
      language: json['language'],
      id: json['id'],
    );
  }
}

class ListElement extends ReadmeElement {
  List<String> items;
  bool isOrdered;

  ListElement({List<String>? items, this.isOrdered = false, super.id}) : items = items ?? ['Item 1'], super(type: ReadmeElementType.list);

  @override
  String get description => 'List';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'items': items,
    'isOrdered': isOrdered,
  };

  factory ListElement.fromJson(Map<String, dynamic> json) {
    return ListElement(
      items: List<String>.from(json['items']),
      isOrdered: json['isOrdered'] ?? false,
      id: json['id'],
    );
  }
}

class BadgeElement extends ReadmeElement {
  String imageUrl;
  String targetUrl;
  String label;

  BadgeElement({this.imageUrl = 'https://img.shields.io/badge/Label-Message-blue', this.targetUrl = '', this.label = 'Badge', super.id}) : super(type: ReadmeElementType.badge);

  @override
  String get description => 'Badge';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'imageUrl': imageUrl,
    'targetUrl': targetUrl,
    'label': label,
  };

  factory BadgeElement.fromJson(Map<String, dynamic> json) {
    return BadgeElement(
      imageUrl: json['imageUrl'],
      targetUrl: json['targetUrl'],
      label: json['label'],
      id: json['id'],
    );
  }
}

enum ColumnAlignment { left, center, right }

class TableElement extends ReadmeElement {
  List<String> headers;
  List<List<String>> rows;
  List<ColumnAlignment> alignments;

  TableElement({
    List<String>? headers,
    List<List<String>>? rows,
    List<ColumnAlignment>? alignments,
    super.id,
  })  : headers = headers != null ? List<String>.from(headers) : ['Header 1', 'Header 2'],
        rows = rows != null
            ? rows.map((r) => List<String>.from(r)).toList()
            : [['Cell 1', 'Cell 2']],
        alignments = alignments != null
            ? List<ColumnAlignment>.from(alignments)
            : [ColumnAlignment.left, ColumnAlignment.left],
        super(type: ReadmeElementType.table);

  @override
  String get description => 'Table';

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'headers': headers,
        'rows': rows,
        'alignments': alignments.map((e) => e.toString()).toList(),
      };

  factory TableElement.fromJson(Map<String, dynamic> json) {
    return TableElement(
      headers: List<String>.from(json['headers']),
      rows: (json['rows'] as List).map((row) => List<String>.from(row)).toList(),
      alignments: (json['alignments'] as List)
          .map((e) => ColumnAlignment.values.firstWhere((a) => a.toString() == e))
          .toList(),
      id: json['id'],
    );
  }
}

class IconElement extends ReadmeElement {
  String name;
  String url;
  double size;

  IconElement({this.name = 'Flutter', this.url = 'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg', this.size = 40, super.id}) : super(type: ReadmeElementType.icon);

  @override
  String get description => 'Icon: $name';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'name': name,
    'url': url,
    'size': size,
  };

  factory IconElement.fromJson(Map<String, dynamic> json) {
    return IconElement(
      name: json['name'],
      url: json['url'],
      size: json['size']?.toDouble() ?? 40.0,
      id: json['id'],
    );
  }
}

class EmbedElement extends ReadmeElement {
  String url;
  String typeName; // 'gist', 'codepen', etc.

  EmbedElement({this.url = '', this.typeName = 'gist', super.id}) : super(type: ReadmeElementType.embed);

  @override
  String get description => 'Embed: $typeName';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'url': url,
    'typeName': typeName,
  };

  factory EmbedElement.fromJson(Map<String, dynamic> json) {
    return EmbedElement(
      url: json['url'],
      typeName: json['typeName'],
      id: json['id'],
    );
  }
}

class GitHubStatsElement extends ReadmeElement {
  String repoName; // username/repo
  bool showStars;
  bool showForks;
  bool showIssues;
  bool showLicense;

  GitHubStatsElement({
    this.repoName = '',
    this.showStars = true,
    this.showForks = true,
    this.showIssues = true,
    this.showLicense = true,
    super.id,
  }) : super(type: ReadmeElementType.githubStats);

  @override
  String get description => 'GitHub Stats';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'repoName': repoName,
    'showStars': showStars,
    'showForks': showForks,
    'showIssues': showIssues,
    'showLicense': showLicense,
  };

  factory GitHubStatsElement.fromJson(Map<String, dynamic> json) {
    return GitHubStatsElement(
      repoName: json['repoName'] ?? '',
      showStars: json['showStars'] ?? true,
      showForks: json['showForks'] ?? true,
      showIssues: json['showIssues'] ?? true,
      showLicense: json['showLicense'] ?? true,
      id: json['id'],
    );
  }
}

class ContributorsElement extends ReadmeElement {
  String repoName; // username/repo
  String style; // 'grid', 'list'

  ContributorsElement({
    this.repoName = '',
    this.style = 'grid',
    super.id,
  }) : super(type: ReadmeElementType.contributors);

  @override
  String get description => 'Contributors';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'repoName': repoName,
    'style': style,
  };

  factory ContributorsElement.fromJson(Map<String, dynamic> json) {
    return ContributorsElement(
      repoName: json['repoName'] ?? '',
      style: json['style'] ?? 'grid',
      id: json['id'],
    );
  }
}
