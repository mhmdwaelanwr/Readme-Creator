import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialPlatform {
  final String name;
  final String color;
  final String logo;
  final IconData icon;
  final String Function(String username) urlBuilder;

  const SocialPlatform({
    required this.name,
    required this.color,
    required this.logo,
    required this.icon,
    required this.urlBuilder,
  });
}

class SocialPlatforms {
  static final Map<String, SocialPlatform> platforms = {
    'TikTok': SocialPlatform(
      name: 'TikTok',
      color: '000000',
      logo: 'tiktok',
      icon: FontAwesomeIcons.tiktok,
      urlBuilder: (username) => 'https://www.tiktok.com/@$username',
    ),
    'Threads': SocialPlatform(
      name: 'Threads',
      color: '000000',
      logo: 'threads',
      icon: FontAwesomeIcons.threads,
      urlBuilder: (username) => 'https://www.threads.net/@$username',
    ),
    'Discord': SocialPlatform(
      name: 'Discord',
      color: '5865F2',
      logo: 'discord',
      icon: FontAwesomeIcons.discord,
      urlBuilder: (username) => 'https://discord.gg/$username', // Or user ID
    ),
    'YouTube': SocialPlatform(
      name: 'YouTube',
      color: 'FF0000',
      logo: 'youtube',
      icon: FontAwesomeIcons.youtube,
      urlBuilder: (username) => 'https://youtube.com/@$username',
    ),
    'Facebook': SocialPlatform(
      name: 'Facebook',
      color: '1877F2',
      logo: 'facebook',
      icon: FontAwesomeIcons.facebook,
      urlBuilder: (username) => 'https://facebook.com/$username',
    ),
    'Twitch': SocialPlatform(
      name: 'Twitch',
      color: '9146FF',
      logo: 'twitch',
      icon: FontAwesomeIcons.twitch,
      urlBuilder: (username) => 'https://twitch.tv/$username',
    ),
    'Instagram': SocialPlatform(
      name: 'Instagram',
      color: 'E4405F',
      logo: 'instagram',
      icon: FontAwesomeIcons.instagram,
      urlBuilder: (username) => 'https://instagram.com/$username',
    ),
    'LinkedIn': SocialPlatform(
      name: 'LinkedIn',
      color: '0A66C2',
      logo: 'linkedin',
      icon: FontAwesomeIcons.linkedin,
      urlBuilder: (username) => 'https://linkedin.com/in/$username',
    ),
    'Telegram': SocialPlatform(
      name: 'Telegram',
      color: '26A5E4',
      logo: 'telegram',
      icon: FontAwesomeIcons.telegram,
      urlBuilder: (username) => 'https://t.me/$username',
    ),
    'GitLab': SocialPlatform(
      name: 'GitLab',
      color: 'FC6D26',
      logo: 'gitlab',
      icon: FontAwesomeIcons.gitlab,
      urlBuilder: (username) => 'https://gitlab.com/$username',
    ),
    'Google Dev': SocialPlatform(
      name: 'Google Dev',
      color: '4285F4',
      logo: 'google-developers',
      icon: FontAwesomeIcons.google,
      urlBuilder: (username) => 'https://g.dev/$username',
    ),
    'Gitea': SocialPlatform(
      name: 'Gitea',
      color: '609926',
      logo: 'gitea',
      icon: FontAwesomeIcons.git, // Fallback
      urlBuilder: (username) => 'https://gitea.com/$username',
    ),
    'Spotify': SocialPlatform(
      name: 'Spotify',
      color: '1DB954',
      logo: 'spotify',
      icon: FontAwesomeIcons.spotify,
      urlBuilder: (username) => 'https://open.spotify.com/user/$username',
    ),
    'Snapchat': SocialPlatform(
      name: 'Snapchat',
      color: 'FFFC00',
      logo: 'snapchat',
      icon: FontAwesomeIcons.snapchat,
      urlBuilder: (username) => 'https://www.snapchat.com/add/$username',
    ),
    'Reddit': SocialPlatform(
      name: 'Reddit',
      color: 'FF4500',
      logo: 'reddit',
      icon: FontAwesomeIcons.reddit,
      urlBuilder: (username) => 'https://www.reddit.com/user/$username',
    ),
    'PayPal': SocialPlatform(
      name: 'PayPal',
      color: '00457C',
      logo: 'paypal',
      icon: FontAwesomeIcons.paypal,
      urlBuilder: (username) => 'https://paypal.me/$username',
    ),
    'Email': SocialPlatform(
      name: 'Email',
      color: 'D14836',
      logo: 'gmail',
      icon: Icons.email,
      urlBuilder: (username) => 'mailto:$username',
    ),
    'Phone': SocialPlatform(
      name: 'Phone',
      color: '25D366', // WhatsApp green as generic phone color or generic grey
      logo: 'whatsapp', // Using whatsapp logo as generic phone or maybe just 'phone' if available in simpleicons but shields.io uses simpleicons
      icon: Icons.phone,
      urlBuilder: (username) => 'tel:$username',
    ),
    'WhatsApp': SocialPlatform(
      name: 'WhatsApp',
      color: '25D366',
      logo: 'whatsapp',
      icon: FontAwesomeIcons.whatsapp,
      urlBuilder: (username) => 'https://wa.me/$username',
    ),
    'Skype': SocialPlatform(
      name: 'Skype',
      color: '00AFF0',
      logo: 'skype',
      icon: FontAwesomeIcons.skype,
      urlBuilder: (username) => 'skype:$username?chat',
    ),
    'Slack': SocialPlatform(
      name: 'Slack',
      color: '4A154B',
      logo: 'slack',
      icon: FontAwesomeIcons.slack,
      urlBuilder: (username) => 'https://$username.slack.com', // Assuming workspace name
    ),
    'Bluesky': SocialPlatform(
      name: 'Bluesky',
      color: '0285FF',
      logo: 'bluesky',
      icon: FontAwesomeIcons.bluesky,
      urlBuilder: (username) => 'https://bsky.app/profile/$username',
    ),
    'X (Twitter)': SocialPlatform(
      name: 'X',
      color: '000000',
      logo: 'x',
      icon: FontAwesomeIcons.xTwitter,
      urlBuilder: (username) => 'https://x.com/$username',
    ),
    'Mastodon': SocialPlatform(
      name: 'Mastodon',
      color: '6364FF',
      logo: 'mastodon',
      icon: FontAwesomeIcons.mastodon,
      urlBuilder: (username) => 'https://mastodon.social/@$username',
    ),
    'Stack Overflow': SocialPlatform(
      name: 'Stack Overflow',
      color: 'F58025',
      logo: 'stackoverflow',
      icon: FontAwesomeIcons.stackOverflow,
      urlBuilder: (username) => 'https://stackoverflow.com/users/$username',
    ),
    'Medium': SocialPlatform(
      name: 'Medium',
      color: '000000',
      logo: 'medium',
      icon: FontAwesomeIcons.medium,
      urlBuilder: (username) => 'https://medium.com/@$username',
    ),
    'Patreon': SocialPlatform(
      name: 'Patreon',
      color: 'FF424D',
      logo: 'patreon',
      icon: FontAwesomeIcons.patreon,
      urlBuilder: (username) => 'https://www.patreon.com/$username',
    ),
    'Ko-fi': SocialPlatform(
      name: 'Ko-fi',
      color: 'FF5E5B',
      logo: 'ko-fi',
      icon: Icons.coffee, // Fallback
      urlBuilder: (username) => 'https://ko-fi.com/$username',
    ),
    'Buy Me a Coffee': SocialPlatform(
      name: 'Buy Me a Coffee',
      color: 'FFDD00',
      logo: 'buymeacoffee',
      icon: FontAwesomeIcons.mugHot,
      urlBuilder: (username) => 'https://www.buymeacoffee.com/$username',
    ),
    'Dev.to': SocialPlatform(
      name: 'Dev.to',
      color: '0A0A0A',
      logo: 'dev.to',
      icon: FontAwesomeIcons.dev,
      urlBuilder: (username) => 'https://dev.to/$username',
    ),
    'Kaggle': SocialPlatform(
      name: 'Kaggle',
      color: '20BEFF',
      logo: 'kaggle',
      icon: FontAwesomeIcons.kaggle,
      urlBuilder: (username) => 'https://www.kaggle.com/$username',
    ),
    'Behance': SocialPlatform(
      name: 'Behance',
      color: '1769FF',
      logo: 'behance',
      icon: FontAwesomeIcons.behance,
      urlBuilder: (username) => 'https://www.behance.net/$username',
    ),
    'Dribbble': SocialPlatform(
      name: 'Dribbble',
      color: 'EA4C89',
      logo: 'dribbble',
      icon: FontAwesomeIcons.dribbble,
      urlBuilder: (username) => 'https://dribbble.com/$username',
    ),
    'CodePen': SocialPlatform(
      name: 'CodePen',
      color: '000000',
      logo: 'codepen',
      icon: FontAwesomeIcons.codepen,
      urlBuilder: (username) => 'https://codepen.io/$username',
    ),
    'Pinterest': SocialPlatform(
      name: 'Pinterest',
      color: 'BD081C',
      logo: 'pinterest',
      icon: FontAwesomeIcons.pinterest,
      urlBuilder: (username) => 'https://www.pinterest.com/$username',
    ),
    'SoundCloud': SocialPlatform(
      name: 'SoundCloud',
      color: 'FF5500',
      logo: 'soundcloud',
      icon: FontAwesomeIcons.soundcloud,
      urlBuilder: (username) => 'https://soundcloud.com/$username',
    ),
    'Vimeo': SocialPlatform(
      name: 'Vimeo',
      color: '1AB7EA',
      logo: 'vimeo',
      icon: FontAwesomeIcons.vimeo,
      urlBuilder: (username) => 'https://vimeo.com/$username',
    ),
    'LeetCode': SocialPlatform(
      name: 'LeetCode',
      color: 'FFA116',
      logo: 'leetcode',
      icon: FontAwesomeIcons.code, // Fallback
      urlBuilder: (username) => 'https://leetcode.com/$username',
    ),
    'HackerRank': SocialPlatform(
      name: 'HackerRank',
      color: '00EA64',
      logo: 'hackerrank',
      icon: FontAwesomeIcons.hackerrank,
      urlBuilder: (username) => 'https://www.hackerrank.com/$username',
    ),
    // Generic/Other
    'NGL': SocialPlatform(
      name: 'NGL',
      color: 'FF0050', // Approximate color
      logo: 'linktree', // Fallback or generic
      icon: Icons.question_answer,
      urlBuilder: (username) => 'https://ngl.link/$username',
    ),
    'Rave': SocialPlatform(
      name: 'Rave',
      color: 'E91E63',
      logo: 'youtube', // Fallback
      icon: Icons.movie,
      urlBuilder: (username) => 'https://rave.io/$username', // Guessing URL structure
    ),
  };

  static String getBadgeUrl(String platform, String style) {
    final p = platforms[platform];
    if (p == null) return '';
    // Encode label and color
    final label = Uri.encodeComponent(p.name);
    final color = p.color;
    final logo = p.logo;
    return 'https://img.shields.io/badge/$label-$color?style=$style&logo=$logo&logoColor=white';
  }

  static String getTargetUrl(String platform, String username) {
    final p = platforms[platform];
    if (p == null) return '';
    return p.urlBuilder(username);
  }
}

