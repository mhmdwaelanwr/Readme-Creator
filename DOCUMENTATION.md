# Readme Creator - Technical Documentation

## 1. Project Overview
**Readme Creator** is a cross-platform Flutter application designed to simplify the creation of `README.md` files for developers. It combines a visual drag-and-drop interface with powerful features like AI generation, GitHub integration, and live previewing.

## 2. Architecture & Project Structure
The project follows a clean architecture pattern using **Provider** for state management.

### Folder Structure (`lib/`)
- **`main.dart`**: Entry point, sets up themes, localization, and providers.
- **`config/`**: App-wide configuration and constants.
- **`core/`**: Core utilities and constants (e.g., `AppColors`).
- **`generator/`**: Logic for converting internal models to Markdown/HTML.
  - `markdown_generator.dart`: The core engine that traverses the element tree and produces Markdown strings.
  - `file_generators.dart`: Templates for extra files (LICENSE, CONTRIBUTING, etc.).
- **`l10n/`**: Localization files (ARB) and generated classes.
- **`models/`**: Data classes representing the application state.
  - `readme_element.dart`: The base abstract class and concrete implementations for all UI elements (Heading, Image, Table, etc.).
  - `saved_project.dart`: Model for serializing projects to JSON.
  - `snippet.dart`: Model for reusable templates.
- **`providers/`**: State management classes.
  - `ProjectProvider`: The central store for the current workspace (elements, variables, settings). Handles undo/redo, selection, and property updates.
  - `LibraryProvider`: Manages saved projects and snippets using `SharedPreferences`.
- **`screens/`**: Full-page widgets.
  - `home_screen.dart`: The main IDE interface.
  - `projects_library_screen.dart`: Gallery of saved projects.
  - `social_preview_screen.dart`: Designer for Open Graph images.
  - `github_actions_generator.dart`: UI for configuring GitHub Actions workflows.
- **`services/`**: External integrations and business logic.
  - `ai_service.dart`: Google Gemini API integration.
  - `github_service.dart` & `github_publisher_service.dart`: GitHub API interactions.
  - `codebase_scanner_service.dart`: Local file system analysis.
  - `health_check_service.dart`: Linter for README best practices.
- **`utils/`**: Helper functions (Dialogs, Toasts, Debouncer, Downloader).
- **`widgets/`**: Reusable UI components.
  - `editor_canvas.dart`: The drop target and rendering area for elements.
  - `components_panel.dart`: The sidebar containing draggable items.
  - `settings_panel.dart`: The property editor for the selected element.

## 3. Core Features Breakdown

### 3.1 Visual Editor (Drag-and-Drop)
- **Mechanism**: Uses Flutter's `Draggable<T>` and `DragTarget<T>` widgets.
- **Flow**:
  1. User drags an item from `ComponentsPanel`.
  2. `EditorCanvas` accepts the data (`ReadmeElementType` or `Snippet`).
  3. `ProjectProvider.addElement()` is called, creating a new instance of the specific `ReadmeElement` subclass.
  4. The UI rebuilds, displaying the new widget in the list.
- **Reordering**: The canvas list supports reordering via `ReorderableListView` or custom implementation (currently custom list with move up/down actions in settings).

### 3.2 Supported Elements
The editor supports a wide range of Markdown elements, each with specific configuration options:
- **Typography**: Heading (H1-H6), Paragraph, Blockquote.
- **Media**: Image (URL/Upload), Icon (DevIcons), Badge (Shields.io).
- **Structure**: Table (customizable rows/cols), List (Ordered/Unordered), Divider, Collapsible Section (Details/Summary).
- **Code**: Code Block (with syntax highlighting language selection), GitHub Gist Embed.
- **Dynamic/Social**:
  - **GitHub Stats**: Readme Stats integration (Stars, Forks, etc.).
  - **Contributors**: Auto-fetch contributors from repo.
  - **Social Links**: Buttons for Twitter, LinkedIn, etc.
  - **Dynamic Widgets**: Spotify Playing, YouTube Video, Medium Articles.
- **Advanced**:
  - **Mermaid.js**: Text-to-diagram generation.
  - **Table of Contents**: Auto-generated based on headings.
  - **Raw HTML/Markdown**: For custom needs.

### 3.3 Live Preview
- **Implementation**: Uses `flutter_markdown` package.
- **Sync**: The preview listens to `ProjectProvider`. Whenever an element changes, `MarkdownGenerator` reconstructs the full Markdown string, which is then rendered by the preview widget.

### 3.3 State Management (Undo/Redo)
- **Snapshots**: `ProjectProvider` maintains a stack of JSON strings (`_snapshots`).
- **Trigger**: Every significant action (add, remove, reorder, property change) calls `_recordHistory()`.
- **Restore**: Undo pops the last snapshot and deserializes it back into the `_elements` list.

## 4. Services & Integrations

### 4.1 AI Service (`ai_service.dart`)
- **Provider**: Google Gemini (Generative AI).
- **Functionality**:
  - `generateReadmeFromStructure`: Takes a file tree string and prompts the AI to write a comprehensive README.
  - `improveText`: Rewrites specific text blocks for clarity or grammar.

### 4.2 GitHub Integration
- **Scanner (`github_scanner_service.dart`)**: Uses GitHub API to fetch the file tree of a public repository.
- **Publisher (`github_publisher_service.dart`)**:
  - Authenticates using a Personal Access Token (PAT).
  - Creates a new branch.
  - Commits the generated `README.md`.
  - Opens a Pull Request against the default branch.

### 4.3 Codebase Scanner (`codebase_scanner_service.dart`)
- **Local**: Recursively walks a selected directory.
- **Filtering**: Ignores common non-source files (`.git`, `node_modules`, `build`, etc.) to keep the context window manageable for the AI.

### 4.4 Health Check (`health_check_service.dart`)
- **Logic**: Iterates through `provider.elements` and applies rules.
- **Rules**:
  - Images must have Alt Text.
  - Links must be valid URLs.
  - Headings should follow a hierarchy (H1 -> H2).
  - Sections should not be empty.

## 5. Generators

### 5.1 Markdown Generator
- **Polymorphism**: Each `ReadmeElement` subclass knows its data, but the generator decides the formatting.
- **Customization**: Respects user preferences for:
  - Bullet style (`*`, `-`, `+`).
  - Section spacing (Compact vs. Spacious).
  - License badges and shields.

### 5.2 Extra Files
- **Templates**: Pre-defined strings for standard files like `LICENSE` (MIT, Apache, etc.), `CONTRIBUTING.md`, and `CODE_OF_CONDUCT.md`.
- **Variable Injection**: Replaces placeholders like `{{PROJECT_NAME}}` and `{{AUTHOR}}` with actual project variables.

## 6. Advanced Tools

### 6.1 Social Preview Designer
- **Canvas**: A dedicated editor for creating 1280x640 images.
- **Export**: Renders the widget tree to an image using `RepaintBoundary` and `ui.Image`.

### 6.2 GitHub Actions Generator
- **YAML Generation**: Constructs `.github/workflows/main.yml` files based on selected triggers (push, pull_request) and jobs (test, build, deploy).

## 7. Installation & Setup

### Prerequisites
- Flutter SDK (Latest Stable)
- Dart SDK
- Android Studio / VS Code

### Steps
1. **Clone the repository**:
   ```bash
   git clone https://github.com/mhmdwaelanwr/Readme-Creator.git
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the application**:
   ```bash
   flutter run
   ```
   *Select Windows, macOS, or Linux as the target device for the best experience.*

## 8. Contributing
We welcome contributions! Please see `CONTRIBUTING.md` for guidelines.
1. Fork the repo.
2. Create a feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes.
4. Push to the branch.
5. Open a Pull Request.

## 9. License
This project is licensed under the MIT License - see the `LICENSE` file for details.

