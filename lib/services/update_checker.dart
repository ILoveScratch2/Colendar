import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateChecker {
  // Configure these URLs for your deployment
  static const String versionUrl =
      'https://versions.ilovescratch.us.ci/colendar/version.json';
  static const String announcementUrl =
      'https://versions.ilovescratch.us.ci/colendar/announcement.json';

  Future<AppVersion?> checkVersion() async {
    try {
      final response = await http
          .get(Uri.parse(versionUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AppVersion(
          version: data['version'] as String? ?? '1.0.0',
          buildNumber: data['buildNumber'] as int? ?? 1,
          downloadUrl: data['downloadUrl'] as String? ?? '',
          changelog: data['changelog'] as String? ?? '',
          forceUpdate: data['forceUpdate'] as bool? ?? false,
        );
      }
    } catch (_) {
      // Ignore network errors
    }
    return null;
  }

  Future<Announcement?> checkAnnouncement() async {
    try {
      final response = await http
          .get(Uri.parse(announcementUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Announcement(
          title: data['title'] as String? ?? '',
          content: data['content'] as String? ?? '',
          version: data['version'] as int? ?? 0,
        );
      }
    } catch (_) {
      // Ignore network errors
    }
    return null;
  }
}

class AppVersion {
  final String version;
  final int buildNumber;
  final String downloadUrl;
  final String changelog;
  final bool forceUpdate;

  const AppVersion({
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
    required this.changelog,
    this.forceUpdate = false,
  });

  bool isNewerThan(String currentVersion) {
    return version.compareTo(currentVersion) > 0;
  }
}

class Announcement {
  final String title;
  final String content;
  final int version;

  const Announcement({
    required this.title,
    required this.content,
    required this.version,
  });
}

void showUpdateDialog(BuildContext context, AppVersion version) {
  showDialog(
    context: context,
    barrierDismissible: !version.forceUpdate,
    builder: (_) => AlertDialog(
      title: const Text('发现新版本'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('版本: ${version.version}'),
          const SizedBox(height: 8),
          if (version.changelog.isNotEmpty) ...[
            const Text('更新内容:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(version.changelog),
          ],
        ],
      ),
      actions: [
        if (!version.forceUpdate)
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('稍后更新')),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            // Open download URL
          },
          child: const Text('前往更新'),
        ),
      ],
    ),
  );
}

void showAnnouncementDialog(BuildContext context, Announcement announcement) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(announcement.title),
      content: Text(announcement.content),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('知道了'),
        ),
      ],
    ),
  );
}
