import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../providers/settings_provider.dart';

class BackgroundSettingsScreen extends StatefulWidget {
  const BackgroundSettingsScreen({super.key});

  @override
  State<BackgroundSettingsScreen> createState() =>
      _BackgroundSettingsScreenState();
}

class _BackgroundSettingsScreenState extends State<BackgroundSettingsScreen> {
  String? _customImagePath;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('背景设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('玻璃效果',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                SwitchListTile(
                  title: const Text('启用玻璃拟态'),
                  subtitle: const Text('课表背景使用毛玻璃效果'),
                  value: settings.glassEffect,
                  onChanged: (v) => settings.setGlassEffect(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('背景模糊',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('低'),
                      Expanded(
                        child: Slider(
                          value: settings.backgroundBlur,
                          min: 0,
                          max: 20,
                          divisions: 20,
                          label: '${settings.backgroundBlur.toStringAsFixed(1)}',
                          onChanged: (v) => settings.setBackgroundBlur(v),
                        ),
                      ),
                      const Text('高'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('背景暗化',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('亮'),
                      Expanded(
                        child: Slider(
                          value: settings.backgroundDim,
                          min: 0,
                          max: 0.9,
                          divisions: 9,
                          label: '${(settings.backgroundDim * 100).toStringAsFixed(0)}%',
                          onChanged: (v) => settings.setBackgroundDim(v),
                        ),
                      ),
                      const Text('暗'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('自定义背景',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: Text(
                      _customImagePath != null ? '已选择图片' : '选择背景图片'),
                  subtitle: _customImagePath != null
                      ? Text(_customImagePath!.split('/').last)
                      : null,
                  trailing: _customImagePath != null
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _customImagePath = null),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      setState(
                          () => _customImagePath = result.files.first.path);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
