# Readme Creator

[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:mhmdwaelanwr@gmail.com)
[![Discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/mhmdwaelanwr)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

**Readme Creator** is a powerful, intuitive, cross-platform application that streamlines the creation of professional `README.md` files. Leverage its visual drag-and-drop editor, AI-powered generation, and extensive customization options to rapidly craft comprehensive and engaging project documentation.

Whether you are a developer, open-source contributor, or technical writer, Readme Creator simplifies the documentation process, allowing you to focus on your code while ensuring your project looks its best.

## 📸 Screenshots

| **Editor Canvas** | **Live Preview** |
|:---:|:---:|
| ![Editor Canvas](assets/screenshots/editor.png) | ![Live Preview](assets/screenshots/preview.png) |
*(Placeholders - Add your screenshots in `assets/screenshots/`)*

## ✨ Features

*   **🎨 Visual Drag-and-Drop Editor**: Build your README by dragging and dropping elements like headings, images, code blocks, lists, tables, and badges directly onto a live canvas.
*   **👁️ Live Markdown Preview**: Instantly see how your Markdown will render with a side-by-side live preview.
*   **🤖 AI-Powered Generation**:
    *   **Generate from Codebase**: Automatically create an initial README by scanning your local project folder or a public GitHub repository using Google Gemini AI.
    *   **AI Assistant**: Improve text, fix grammar, or generate descriptions for specific elements.
*   **📚 Comprehensive Element Library**:
    *   **GitHub Stats**: Dynamic badges for stars, forks, and issues.
    *   **Contributors**: Generate grids or lists of project contributors.
    *   **Social Links**: Customizable social media badges.
    *   **Dev Icons**: Popular technology and language icons.
    *   **Embeds**: Integrate GitHub Gists, CodePen, and YouTube.
    *   **Mermaid Diagrams**: Create flowcharts and diagrams.
    *   **Table of Contents**: Auto-generated clickable TOC.
*   **🎨 Theming & Customization**: Light/Dark modes, custom colors, bullet styles, and spacing.
*   **🖼️ Social Preview Designer**: Create visually appealing Open Graph/Twitter Card images.
*   **⚙️ GitHub Actions Generator**: Automate README updates with pre-configured workflows.
*   **💾 Project Management**: Save/load projects, create snapshots, import existing Markdown, and export as JSON, Markdown, HTML, or ZIP.
*   **⌨️ Keyboard Shortcuts**: Speed up your workflow with extensive shortcuts.
*   **🏥 Health Check**: Analyze your README for issues like missing alt text or broken links.
*   **🌍 Internationalization**: Available in 10+ languages including Arabic, English, Spanish, French, and Japanese.

## 🛠️ Tech Stack

Built with **Flutter** and **Dart**.

*   **Frontend**: Flutter
*   **State Management**: Provider
*   **AI**: Google Generative AI SDK
*   **Markdown**: `markdown` package, custom generators
*   **Utils**: `file_picker`, `archive`, `share_plus`, `printing`

## 🚀 Getting Started

### Prerequisites

*   **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install)
*   **Dart SDK**: Included with Flutter

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/mhmdwaelanwr/Readme-Creator.git
    cd Readme-Creator
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the Application**
    ```bash
    flutter run
    ```

### AI & GitHub Setup (Optional)

To unlock full AI capabilities and higher GitHub API limits:
1.  **Gemini API Key**: Get a key from [Google AI Studio](https://aistudio.google.com/app/apikey) and enter it in **Settings > AI Settings**.
2.  **GitHub Token**: Generate a [Personal Access Token](https://github.com/settings/tokens) and enter it in **Settings > AI Settings**.

## 📖 Usage

1.  **Start**: Create a blank project or load a template.
2.  **Drag & Drop**: Use the **Components Panel** to add elements.
3.  **Edit**: Click an element to customize its properties in the **Settings Panel**.
4.  **Preview**: Toggle "Live Preview" to see the result.
5.  **Export**: Click the download icon to export your `README.md` and related files.

## 📂 Project Structure

```
lib/
├── core/          # Constants, themes
├── generator/     # Markdown & License generation logic
├── l10n/          # Localization files
├── models/        # Data models
├── providers/     # State management
├── screens/       # UI Screens
├── services/      # API services (AI, GitHub)
├── utils/         # Helpers (export, download, dialogs)
└── widgets/       # Reusable UI components
```

## 🤝 Contributing

Contributions are welcome! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

<div align="center">
  Developed with ❤️ by <a href="https://github.com/mhmdwaelanwr">Mohamed Anwar</a>
</div>

