import '../models/readme_element.dart';

class ProjectTemplate {
  final String name;
  final String description;
  final List<ReadmeElement> elements;

  ProjectTemplate({
    required this.name,
    required this.description,
    required this.elements,
  });
}

class Templates {
  static List<ProjectTemplate> get all => [
        ProjectTemplate(
          name: 'Minimal',
          description: 'Basic structure with Project Name, Description, and License.',
          elements: [
            HeadingElement(text: '[PROJECT_NAME]', level: 1),
            ParagraphElement(text: 'A brief description of what this project does and who it\'s for.'),
            HeadingElement(text: 'License', level: 2),
            ParagraphElement(text: 'MIT License. Copyright (c) [CURRENT_YEAR] [GITHUB_USERNAME]'),
          ],
        ),
        ProjectTemplate(
          name: 'Library / Package',
          description: 'Includes Installation, Usage, and Example sections.',
          elements: [
            HeadingElement(text: '[PROJECT_NAME]', level: 1),
            BadgeElement(label: 'Version', imageUrl: 'https://img.shields.io/pub/v/[PROJECT_NAME]', targetUrl: 'https://pub.dev/packages/[PROJECT_NAME]'),
            ParagraphElement(text: 'A powerful library for...'),
            HeadingElement(text: 'Installation', level: 2),
            CodeBlockElement(code: 'flutter pub add [PROJECT_NAME]', language: 'bash'),
            HeadingElement(text: 'Usage', level: 2),
            CodeBlockElement(code: 'import \'package:[PROJECT_NAME]/[PROJECT_NAME].dart\';\n\nvoid main() {\n  // Use the library\n}', language: 'dart'),
            HeadingElement(text: 'License', level: 2),
            ParagraphElement(text: 'MIT License. Copyright (c) [CURRENT_YEAR] [GITHUB_USERNAME]'),
          ],
        ),
        ProjectTemplate(
          name: 'Full Project',
          description: 'Comprehensive structure including Prerequisites, Contributing, and Tests.',
          elements: [
            HeadingElement(text: '[PROJECT_NAME]', level: 1),
            ParagraphElement(text: 'A complete solution for...'),
            HeadingElement(text: 'Prerequisites', level: 2),
            ListElement(items: ['Flutter SDK', 'Android Studio / VS Code']),
            HeadingElement(text: 'Installation', level: 2),
            CodeBlockElement(code: 'git clone https://github.com/[GITHUB_USERNAME]/[PROJECT_NAME].git\ncd [PROJECT_NAME]\nflutter pub get', language: 'bash'),
            HeadingElement(text: 'Running Tests', level: 2),
            CodeBlockElement(code: 'flutter test', language: 'bash'),
            HeadingElement(text: 'Contributing', level: 2),
            ParagraphElement(text: 'Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.'),
            HeadingElement(text: 'License', level: 2),
            ParagraphElement(text: 'MIT License. Copyright (c) [CURRENT_YEAR] [GITHUB_USERNAME]'),
          ],
        ),
        ProjectTemplate(
          name: 'Contributing Guide',
          description: 'Standard CONTRIBUTING.md structure.',
          elements: [
            HeadingElement(text: 'Contributing to [PROJECT_NAME]', level: 1),
            ParagraphElement(text: 'First off, thanks for taking the time to contribute! ❤️'),
            HeadingElement(text: 'How to Contribute', level: 2),
            ParagraphElement(text: '1. Fork the repo and create your branch from `main`.\n2. If you\'ve added code that should be tested, add tests.\n3. Ensure the test suite passes.\n4. Make sure your code lints.'),
            HeadingElement(text: 'Pull Request Process', level: 2),
            ListElement(items: ['Update the README.md with details of changes to the interface.', 'Increase the version numbers in any examples files and the README.md to the new version that this Pull Request would represent.']),
          ],
        ),
        ProjectTemplate(
          name: 'Documentation Site',
          description: 'Structure for a documentation-heavy project.',
          elements: [
            HeadingElement(text: '[PROJECT_NAME] Documentation', level: 1),
            ParagraphElement(text: 'Welcome to the official documentation for [PROJECT_NAME].'),
            TOCElement(title: 'Table of Contents'),
            HeadingElement(text: 'Getting Started', level: 2),
            ParagraphElement(text: 'Introduction to the core concepts...'),
            HeadingElement(text: 'API Reference', level: 2),
            ParagraphElement(text: 'Detailed API documentation...'),
            HeadingElement(text: 'Tutorials', level: 2),
            ListElement(items: ['Basic Usage', 'Advanced Configuration', 'Integration Guide']),
            HeadingElement(text: 'FAQ', level: 2),
            CollapsibleElement(summary: 'How do I reset the configuration?', content: 'You can reset by running `reset_config.sh`.'),
          ],
        ),
      ];
}
