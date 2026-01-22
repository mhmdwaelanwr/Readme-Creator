import 'package:jaspr/jaspr.dart';
import 'dart:html' as html;

class LandingApp extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    final path = html.window.location.pathname;

    if (path == '/app') {
      yield _buildFlutterAppHost();
    } else {
      yield div(id: 'landing-container', [
        _buildStyles(),
        _buildLiquidBackground(),
        _buildNavbar(),
        _buildHero(),
        _buildFeatures(),
        _buildPricing(),
        _buildSponsorSection(),
        _buildDownload(),
        _buildFooter(),
      ]);
    }
  }

  Component _buildLiquidBackground() {
    return div(classes: 'liquid-bg', [
      div(classes: 'blob blob-1', []),
      div(classes: 'blob blob-2', []),
      div(classes: 'blob blob-3', []),
      div(classes: 'blob blob-4', []),
      div(classes: 'glass-overlay', []),
    ]);
  }

  Component _buildFlutterAppHost() {
    return div(id: 'flutter-app-container', [
      style([raw('''
        #flutter-app-container {
          height: 100vh; width: 100vw;
          display: flex; flex-direction: column;
          justify-content: center; align-items: center;
          background: #030712; color: white;
          font-family: 'Inter', sans-serif;
        }
        .loader-wrapper { position: relative; width: 140px; height: 140px; display: flex; justify-content: center; align-items: center; }
        .ring { position: absolute; border-radius: 50%; border: 3px solid transparent; }
        .ring-1 { width: 120px; height: 120px; border-top-color: #6366F1; animation: spin 1.2s infinite cubic-bezier(0.5, 0, 0.5, 1); }
        .ring-2 { width: 90px; height: 90px; border-right-color: #F43F5E; animation: spin 1.8s infinite reverse linear; }
        .ring-3 { width: 60px; height: 60px; border-bottom-color: #A855F7; animation: spin 1s infinite linear; }
        .loader-icon { font-size: 28px; color: #6366F1; filter: drop-shadow(0 0 15px #6366F1); animation: pulse 2s infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        @keyframes pulse { 0%, 100% { opacity: 0.4; transform: scale(0.8); } 50% { opacity: 1; transform: scale(1.1); } }
        .loading-text { margin-top: 40px; font-weight: 800; letter-spacing: 4px; font-size: 0.75rem; color: #6366F1; text-transform: uppercase; }
      ''')]),
      div(classes: 'loader-wrapper', [
        div(classes: 'ring ring-1', []),
        div(classes: 'ring ring-2', []),
        div(classes: 'ring ring-3', []),
        i(classes: 'fa-solid fa-bolt-lightning loader-icon', []),
      ]),
      div(classes: 'loading-text', [text('Powering Up Studio')]),
      script([raw('''
        (function() {
          if (window._flutter) {
            _flutter.loader.load({
              onEntrypointLoaded: function(engineInitializer) {
                engineInitializer.initializeEngine().then(function(appRunner) { appRunner.runApp(); });
              }
            });
          }
        })();
      ''')])
    ]);
  }

  Component _buildStyles() {
    return style([raw('''
      :root {
        --primary: #6366F1;
        --accent: #F43F5E;
        --purple: #A855F7;
        --bg: #030712;
        --glass: rgba(255, 255, 255, 0.03);
        --glass-border: rgba(255, 255, 255, 0.08);
        --text: #F9FAFB;
      }
      body { background: var(--bg); color: var(--text); font-family: 'Inter', sans-serif; margin: 0; overflow-x: hidden; }
      .container { max-width: 1100px; margin: 0 auto; padding: 0 24px; position: relative; z-index: 5; }
      
      /* Liquid Glass Engine */
      .liquid-bg { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 1; overflow: hidden; background: #030712; }
      .blob { position: absolute; border-radius: 50%; filter: blur(80px); opacity: 0.45; animation: drift 25s infinite alternate ease-in-out; mix-blend-mode: screen; }
      .blob-1 { width: 600px; height: 600px; background: var(--primary); top: -150px; left: -150px; }
      .blob-2 { width: 500px; height: 500px; background: var(--accent); bottom: -100px; right: -100px; animation-duration: 20s; }
      .blob-3 { width: 400px; height: 400px; background: var(--purple); top: 30%; right: 20%; animation-duration: 30s; }
      .blob-4 { width: 350px; height: 350px; background: #3B82F6; bottom: 20%; left: 10%; animation-duration: 18s; }
      @keyframes drift { from { transform: translate(0, 0) rotate(0deg); } to { transform: translate(150px, 150px) rotate(180deg); } }
      .glass-overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; backdrop-filter: blur(60px); background: rgba(3, 7, 18, 0.4); }

      /* Navbar */
      .navbar { padding: 25px 0; border-bottom: 1px solid var(--glass-border); backdrop-filter: blur(20px); position: sticky; top: 0; z-index: 100; }
      .nav-content { display: flex; justify-content: space-between; align-items: center; }
      .logo { font-weight: 900; font-size: 1.6rem; color: white; text-decoration: none; display: flex; align-items: center; gap: 12px; }
      .logo i { color: var(--primary); filter: drop-shadow(0 0 12px var(--primary)); }
      
      /* Buttons */
      .btn-main { background: linear-gradient(135deg, var(--primary), var(--purple)); color: white; padding: 16px 42px; border-radius: 18px; 
                  text-decoration: none; font-weight: 800; font-size: 1.1rem; border: none; cursor: pointer; transition: 0.4s cubic-bezier(0.2, 1, 0.3, 1); display: inline-block; }
      .btn-main:hover { transform: translateY(-4px) scale(1.03); box-shadow: 0 25px 50px rgba(99, 102, 241, 0.4); }
      
      /* Hero */
      .hero { padding: 160px 0 100px; text-align: center; }
      .hero h1 { font-size: clamp(3.5rem, 10vw, 6rem); font-weight: 900; margin-bottom: 24px; line-height: 1; letter-spacing: -4px; 
                 background: linear-gradient(to bottom right, #fff 40%, var(--primary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
      .hero p { color: #94A3B8; font-size: 1.5rem; max-width: 800px; margin: 0 auto 56px; line-height: 1.6; font-weight: 500; }
      
      /* Features & Pricing Cards */
      .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 32px; padding: 80px 0; }
      .card { background: var(--glass); padding: 56px 40px; border-radius: 40px; border: 1px solid var(--glass-border); backdrop-filter: blur(15px); transition: 0.4s; }
      .card:hover { border-color: var(--primary); background: rgba(255,255,255,0.06); transform: translateY(-10px); }
      .card i { font-size: 2.8rem; background: linear-gradient(135deg, var(--primary), var(--accent)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin-bottom: 28px; }
      .card h3 { font-size: 1.8rem; margin-bottom: 12px; font-weight: 800; }
      
      .p-card { background: var(--glass); padding: 72px 48px; border-radius: 48px; border: 1px solid var(--glass-border); text-align: center; backdrop-filter: blur(15px); }
      .p-card.featured { border-color: var(--primary); box-shadow: 0 0 80px rgba(99, 102, 241, 0.15); background: rgba(99, 102, 241, 0.08); }
      .price { font-size: 4.5rem; font-weight: 900; margin: 32px 0; letter-spacing: -2px; }
      
      /* Sponsor & Download */
      .sponsor-box { background: linear-gradient(135deg, rgba(244, 63, 94, 0.1), rgba(168, 85, 247, 0.1)); padding: 80px; border-radius: 48px; 
                     text-align: center; margin: 80px 0; border: 1px solid rgba(244, 63, 94, 0.2); backdrop-filter: blur(10px); }
      .badge-btn { background: var(--glass); color: white; padding: 20px 40px; border-radius: 20px; text-decoration: none; margin: 10px; 
                   border: 1px solid var(--glass-border); transition: 0.3s; display: inline-flex; align-items: center; gap: 12px; }
      .badge-btn:hover { background: var(--primary); border-color: var(--primary); }
      
      footer { padding: 100px 0; text-align: center; color: #4B5563; border-top: 1px solid var(--glass-border); font-weight: 600; letter-spacing: 1px; }
    ''')]);
  }

  Component _buildNavbar() {
    return nav(classes: 'navbar', [
      div(classes: 'container nav-content', [
        a(href: '/', classes: 'logo', [
          i(classes: 'fa-solid fa-bolt-lightning', []),
          span([text('Markdown Studio')])
        ]),
        div([a(href: '/app', classes: 'btn-main', [text('Open Studio')])]),
      ]),
    ]);
  }

  Component _buildHero() {
    return section(classes: 'hero container', [
      h1([text('Markdown Mastery.')]),
      p([text('Elevate your documentation with the most advanced visual editor. AI-powered precision, cloud-native stability.')]),
      a(href: '/app', classes: 'btn-main', [text('Start Creating Free')]),
    ]);
  }

  Component _buildFeatures() {
    return section(classes: 'container grid', [
      _featureCard('Visual Canvas', 'Design professional READMEs using a sleek component-based visual interface.', 'fa-shapes'),
      _featureCard('Generative AI', 'Leverage Gemini AI to write descriptions, summaries, and complex technical docs.', 'fa-wand-magic-sparkles'),
      _featureCard('Pro Cloud', 'Secure cloud storage for all your projects with real-time sync across platforms.', 'fa-cloud-bolt'),
    ]);
  }

  Component _buildPricing() {
    return section(id: 'pricing', classes: 'container', [
      h2(style: 'text-align: center; font-size: 3rem; font-weight: 900; margin-bottom: 10px;', [text('Simple Plans')]),
      p(style: 'text-align: center; color: #94A3B8; margin-bottom: 50px;', [text('Free for enthusiasts, powerful for professionals.')]),
      div(classes: 'grid', [
        _priceCard('Starter', '0', ['Standard Components', 'Standard Markdown Export', 'Community Support']),
        _priceCard('Pro Suite', '5', ['Unlimited AI Generation', 'Pro PDF/HTML Templates', 'Cloud Library Access', 'Ad-Free Experience'], isFeatured: true),
      ]),
    ]);
  }

  Component _buildSponsorSection() {
    return section(classes: 'container', [
      div(classes: 'sponsor-box', [
        i(classes: 'fa-solid fa-heart', style: 'color: #F43F5E; font-size: 3rem; margin-bottom: 24px;', []),
        h2([text('Support the Evolution')]),
        p(style: 'max-width: 600px; margin: 0 auto 32px;', [text('Help us build the future of technical documentation. Sponsors receive lifetime Pro status and exclusive badges.')]),
        a(href: 'https://buymeacoffee.com/yourname', classes: 'btn-main', style: 'background: #F43F5E;', [text('Become a Sponsor')]),
      ])
    ]);
  }

  Component _buildDownload() {
    return section(classes: 'container', style: 'padding: 80px 0; text-align: center;', [
      h3([text('Deploy Everywhere')]),
      div(style: 'margin-top: 32px;', [
        _badgeBtn('Windows', 'fa-windows', '#'),
        _badgeBtn('Android', 'fa-android', '#'),
      ])
    ]);
  }

  Component _badgeBtn(String label, String icon, String url) {
    return a(href: url, classes: 'badge-btn', [
      i(classes: 'fa-brands $icon', []),
      text(label)
    ]);
  }

  Component _priceCard(String title, String price, List<String> perks, {bool isFeatured = false}) {
    return div(classes: 'p-card ${isFeatured ? 'featured' : ''}', [
      h3([text(title)]),
      div(classes: 'price', [text('\$$price'), span(style: 'font-size: 1rem; color: #64748B;', [text('/mo')])]),
      ul(style: 'list-style: none; padding: 0; margin: 40px 0; text-align: left;', [
        for (var p in perks) li(style: 'margin-bottom: 16px; display: flex; align-items: center; gap: 12px;', [
          i(classes: 'fa-solid fa-circle-check', style: 'color: #10B981;', []),
          text(p)
        ])
      ]),
      a(href: '/app', classes: 'btn-main', style: isFeatured ? '' : 'background: rgba(255,255,255,0.1);', [text('Join $title')])
    ]);
  }

  Component _featureCard(String title, String desc, String icon) {
    return div(classes: 'card', [
      i(classes: 'fa-solid $icon', []),
      h3([text(title)]),
      p([text(desc)]),
    ]);
  }

  Component _buildFooter() {
    return footer([div(classes: 'container', [text('© 2024 Markdown Studio Pro • Excellence in Documentation')])]);
  }
}
