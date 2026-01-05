import 'package:flutter_test/flutter_test.dart';
import 'package:readme_creator/generator/markdown_generator.dart';
import 'package:readme_creator/models/readme_element.dart';

void main() {
  group('MarkdownGenerator', () {
    test('generates heading correctly', () {
      final generator = MarkdownGenerator();
      final element = HeadingElement(text: 'Title', level: 1);
      expect(generator.generate([element]).trim(), '# Title');
    });

    test('generates paragraph correctly', () {
      final generator = MarkdownGenerator();
      final element = ParagraphElement(text: 'Hello world');
      expect(generator.generate([element]).trim(), 'Hello world');
    });

    test('generates image correctly', () {
      final generator = MarkdownGenerator();
      final element = ImageElement(url: 'img.png', altText: 'Alt');
      expect(generator.generate([element]).trim(), '![Alt](img.png)');
    });

    test('generates link button correctly', () {
      final generator = MarkdownGenerator();
      final element = LinkButtonElement(text: 'Click me', url: 'https://example.com');
      expect(generator.generate([element]).trim(), '[Click me](https://example.com)');
    });

    test('generates code block correctly', () {
      final generator = MarkdownGenerator();
      final element = CodeBlockElement(code: 'print("Hi");', language: 'dart');
      expect(generator.generate([element]).trim(), '```dart\nprint("Hi");\n```');
    });

    test('generates list correctly', () {
      final generator = MarkdownGenerator();
      final element = ListElement(items: ['Item 1', 'Item 2']);
      expect(generator.generate([element]).trim(), '* Item 1\n* Item 2');
    });

    test('generates ordered list correctly', () {
      final generator = MarkdownGenerator();
      final element = ListElement(items: ['Item 1', 'Item 2']);
      element.isOrdered = true;
      expect(generator.generate([element]).trim(), '1. Item 1\n2. Item 2');
    });

    test('generates image with width correctly', () {
      final generator = MarkdownGenerator();
      final element = ImageElement(url: 'img.png', altText: 'Alt', width: 100);
      expect(generator.generate([element]).trim(), '<img src="img.png" alt="Alt" width="100" />');
    });

    test('generates badge correctly', () {
      final generator = MarkdownGenerator();
      final element = BadgeElement(label: 'Build', imageUrl: 'img.svg', targetUrl: 'link');
      expect(generator.generate([element]).trim(), '[![Build](img.svg)](link)');
    });

    test('generates badge without target url correctly', () {
      final generator = MarkdownGenerator();
      final element = BadgeElement(label: 'Build', imageUrl: 'img.svg', targetUrl: '');
      expect(generator.generate([element]).trim(), '![Build](img.svg)');
    });

    test('generates table correctly', () {
      final generator = MarkdownGenerator();
      final element = TableElement(
        headers: ['H1', 'H2'],
        rows: [['R1C1', 'R1C2'], ['R2C1', 'R2C2']],
        alignments: [ColumnAlignment.left, ColumnAlignment.right],
      );
      const expected = '| H1 | H2 |\n| :--- | ---: |\n| R1C1 | R1C2 |\n| R2C1 | R2C2 |';
      expect(generator.generate([element]).trim(), expected);
    });

    test('generates icon correctly', () {
      final generator = MarkdownGenerator();
      final element = IconElement(name: 'Flutter', url: 'flutter.svg', size: 40);
      expect(generator.generate([element]).trim(), '<img src="flutter.svg" alt="Flutter" width="40" height="40"/>');
    });

    test('generates embed correctly', () {
      final generator = MarkdownGenerator();
      final element = EmbedElement(url: 'https://gist.github.com/123', typeName: 'gist');
      expect(generator.generate([element]).trim(), '[gist](https://gist.github.com/123)');
    });

    test('replaces variables correctly', () {
      final generator = MarkdownGenerator();
      final element = HeadingElement(text: '[PROJECT_NAME]', level: 1);
      final variables = {'PROJECT_NAME': 'MyCoolProject'};
      expect(generator.generate([element], variables: variables).trim(), '# MyCoolProject');
    });

    test('generates multiple elements with spacing', () {
      final generator = MarkdownGenerator();
      final elements = [
        HeadingElement(text: 'Title'),
        ParagraphElement(text: 'Body'),
      ];
      final result = generator.generate(elements);
      expect(result, '# Title\n\nBody');
    });
  });
}

