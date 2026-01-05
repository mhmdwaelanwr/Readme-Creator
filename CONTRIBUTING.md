# Contributing to Readme Creator

First off, thank you for considering contributing to **Readme Creator**! It's people like you that make the open-source community such an amazing place to learn, inspire, and create.

We welcome contributions of all kinds, from bug fixes and feature additions to documentation improvements and translations.

## 📜 Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please treat everyone with respect and kindness.

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:
- **Flutter SDK** (Latest Stable)
- **Dart SDK**
- **Git**
- An IDE (VS Code or Android Studio recommended)

### Setting Up the Environment

1.  **Fork the repository** on GitHub.
2.  **Clone your fork** locally:
    ```bash
    git clone https://github.com/YOUR_USERNAME/Readme-Creator.git
    cd Readme-Creator
    ```
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run the app**:
    ```bash
    flutter run
    ```

## 🏗️ Project Structure

Understanding the project structure will help you navigate the codebase:

*   **`lib/main.dart`**: Entry point, sets up themes, localization, and providers.
*   **`lib/models/`**: Data classes. `readme_element.dart` is the core model for all UI elements.
*   **`lib/providers/`**: State management. `ProjectProvider` manages the workspace state.
*   **`lib/screens/`**: Full-page widgets (`HomeScreen`, `ProjectsLibraryScreen`, etc.).
*   **`lib/widgets/`**: Reusable UI components (`EditorCanvas`, `ComponentsPanel`, `SettingsPanel`).
*   **`lib/generator/`**: Logic for converting models to Markdown (`markdown_generator.dart`).
*   **`lib/services/`**: External integrations (AI, GitHub, File System).

## 🛠️ How to Contribute

### Reporting Bugs

If you find a bug, please create an issue on GitHub. Be sure to include:
- A clear, descriptive title.
- Steps to reproduce the issue.
- Expected vs. actual behavior.
- Screenshots or screen recordings (if applicable).
- Your environment details (OS, Flutter version).

### Suggesting Enhancements

Have an idea for a new feature? We'd love to hear it! Open an issue with the tag `enhancement` and describe:
- The feature you'd like to see.
- Why it would be useful.
- Any design sketches or examples.

### Pull Requests

1.  **Create a Branch**: Create a new branch for your feature or bug fix.
    ```bash
    git checkout -b feature/amazing-feature
    # or
    git checkout -b fix/annoying-bug
    ```
2.  **Make Changes**: Write clean, maintainable code. Follow the existing coding style.
3.  **Test**: Ensure your changes don't break existing functionality. Run tests if available.
4.  **Commit**: Use descriptive commit messages.
    ```bash
    git commit -m "feat: Add amazing feature"
    ```
5.  **Push**: Push your branch to your fork.
    ```bash
    git push origin feature/amazing-feature
    ```
6.  **Open a PR**: Go to the original repository and open a Pull Request. Provide a clear description of your changes.

## 🧩 Guide: Adding a New Element

Want to add a new component (e.g., a "Twitter Feed" or "Calendar")? Follow these steps:

1.  **Define the Model**:
    - Go to `lib/models/readme_element.dart`.
    - Add a new value to the `ReadmeElementType` enum.
    - Create a new class extending `ReadmeElement` (e.g., `TwitterFeedElement`).
    - Implement `toJson`, `fromJson`, and `description`.
    - Update `ReadmeElement.fromJson` factory to handle the new type.

2.  **Update the Generator**:
    - Go to `lib/generator/markdown_generator.dart`.
    - In the `generate` method, add a case for your new element type.
    - Implement the logic to convert your element's properties into a Markdown string.

3.  **Update the UI (Components Panel)**:
    - Go to `lib/widgets/components_panel.dart`.
    - Add a `ComponentItem` for your new element in the appropriate list (e.g., `mediaItems` or `advancedItems`).
    - Add a tooltip message in `_getTooltipMessage`.

4.  **Update the UI (Settings Panel)**:
    - Go to `lib/widgets/settings_panel.dart`.
    - In `_buildSettingsForm`, add a case for your new element type.
    - Create a new widget (e.g., `TwitterFeedSettings`) to allow users to edit properties.

5.  **Update the UI (Canvas Rendering)**:
    - Go to `lib/widgets/canvas_item.dart`.
    - In `_buildElementContent`, add a case for your new element type.
    - Return a widget that represents how the element looks in the editor (it doesn't have to be perfect Markdown, just a visual representation).

## 🎨 Style Guide

- **Dart**: We follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
- **Linter**: The project uses `flutter_lints`. Ensure there are no analysis errors before submitting.
- **Formatting**: Run `dart format .` to format your code.

## 🌍 Translations

We want Readme Creator to be accessible to everyone. If you'd like to add a new language or improve an existing translation:
1.  Navigate to `lib/l10n/`.
2.  Create or edit the `.arb` file for your language (e.g., `app_es.arb`).
3.  Add the translation keys and values.
4.  Run `flutter gen-l10n` (or just run the app) to generate the Dart files.

## ❓ Questions?

If you have any questions, feel free to reach out via [![Discord](https://img.shields.io/badge/Discord-5865F2?style=plastic&logo=discord&logoColor=white)](https://discord.gg/https://discord.gg/eNpUVUzp) or open a discussion on GitHub.

---

Thank you for contributing! ❤️

