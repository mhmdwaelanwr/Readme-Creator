// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '高度なReadme作成ツール';

  @override
  String get saveToLibrary => 'ライブラリに保存';

  @override
  String get localSnapshots => 'ローカルスナップショット';

  @override
  String get clearWorkspace => 'ワークスペースをクリア';

  @override
  String get importMarkdown => 'Markdownをインポート';

  @override
  String get socialPreviewDesigner => 'ソーシャルプレビューデザイナー';

  @override
  String get githubActionsGenerator => 'GitHub Actionsジェネレーター';

  @override
  String get exportProjectJson => 'プロジェクトをエクスポート (JSON)';

  @override
  String get importProjectJson => 'プロジェクトをインポート (JSON)';

  @override
  String get aiSettings => 'AI設定';

  @override
  String get generateFromCodebase => 'コードベースから生成 (AI)';

  @override
  String get showTour => 'ツアーを表示';

  @override
  String get keyboardShortcuts => 'キーボードショートカット';

  @override
  String get aboutDeveloper => '開発者について';

  @override
  String get aboutApp => 'アプリについて';

  @override
  String get changeLanguage => '言語を変更';

  @override
  String get settings => '設定';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get close => '閉じる';

  @override
  String get import => 'インポート';

  @override
  String get export => 'エクスポート';

  @override
  String get projectName => 'プロジェクト名';

  @override
  String get description => '説明';

  @override
  String get tags => 'タグ (カンマ区切り)';

  @override
  String get projectSaved => 'プロジェクトがライブラリに保存されました';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get delete => '削除';

  @override
  String get restore => '復元';

  @override
  String get confirmClearWorkspace => 'ワークスペースをクリアしますか？';

  @override
  String get confirmClearWorkspaceContent =>
      'これにより、すべての要素が削除されます。この操作は元に戻せません（スナップショットがない場合）。';

  @override
  String get pickProjectFolder => 'プロジェクトフォルダを選択';

  @override
  String get repoUrl => 'リポジトリURL';

  @override
  String get scanAndGenerate => 'スキャンして生成';

  @override
  String get geminiApiKey => 'Gemini APIキー';

  @override
  String get githubToken => 'GitHubトークン (オプション)';

  @override
  String get getApiKey => 'Google AI StudioからAPIキーを取得';

  @override
  String get generateToken => '個人アクセストークンを生成';

  @override
  String get elements => '要素';

  @override
  String get words => '単語数';

  @override
  String get healthy => '正常';

  @override
  String get errors => 'エラー';

  @override
  String get warnings => '警告';

  @override
  String get focusMode => 'フォーカスモード';

  @override
  String get autoSaved => '自動保存済み';

  @override
  String get projectSettings => 'プロジェクト設定';

  @override
  String get variables => '変数';

  @override
  String get license => 'ライセンス';

  @override
  String get contributing => '貢献';

  @override
  String get colors => '色';

  @override
  String get formatting => 'フォーマット';

  @override
  String get primaryColor => 'プライマリカラー';

  @override
  String get secondaryColor => 'セカンダリカラー';

  @override
  String get exportHtml => 'HTMLをエクスポート';

  @override
  String get listBulletStyle => 'リストの箇条書きスタイル';

  @override
  String get sectionSpacing => 'セクションの間隔 (改行)';

  @override
  String get templates => 'テンプレート';

  @override
  String get load => '読み込む';

  @override
  String get viewOnGithub => 'GitHubで表示';

  @override
  String get version => 'バージョン';

  @override
  String get rightsReserved => '全著作権所有。';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get settingsSaved => '設定を保存しました！';

  @override
  String get commonShortcuts => 'Common Shortcuts';

  @override
  String get elementShortcuts => 'Element Shortcuts';

  @override
  String get newProject => 'New Project';

  @override
  String get openProject => 'Open Project';

  @override
  String get saveProject => 'Save Project';

  @override
  String get exportProject => 'Export Project';

  @override
  String get print => 'Print';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get showPreview => 'Show Preview';

  @override
  String get toggleGrid => 'Toggle Grid';

  @override
  String get toggleTheme => 'Toggle Theme';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get help => 'Help';

  @override
  String get addHeading => 'Add Heading';

  @override
  String get addSubheading => 'Add Subheading';

  @override
  String get addParagraph => 'Add Paragraph';

  @override
  String get addImage => 'Add Image';

  @override
  String get addTable => 'Add Table';

  @override
  String get addList => 'Add List';

  @override
  String get addQuote => 'Add Quote';

  @override
  String get addLink => 'Add Link';

  @override
  String get aboutDescription =>
      'Readme Creator is a powerful tool for generating professional README files for your projects. All features work across desktop, mobile and web.';

  @override
  String get enterGeminiKey =>
      'Enter your Gemini API Key to enable real AI features.';

  @override
  String get githubIntegration => 'GitHub Integration';

  @override
  String get enterGithubToken =>
      'Optional: Enter GitHub Token for higher rate limits when scanning repos.';

  @override
  String get localFolder => 'Local Folder';

  @override
  String get githubRepo => 'GitHub Repo';

  @override
  String get scanLocalFolder =>
      'Scan a local project folder to generate a README.';

  @override
  String get scanGithubRepo => 'Scan a public GitHub repository.';

  @override
  String get fetchingRepo => 'Fetching repository data...';

  @override
  String get analyzingAI => 'Analyzing with AI...';

  @override
  String get readmeGenerated => 'README generated successfully!';

  @override
  String get projectImported => 'Project imported successfully';

  @override
  String get contentFetched =>
      'Content fetched! Switch to \"Text / File\" tab to review.';

  @override
  String get fetchFailed => 'Failed to fetch';
}
