import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardPage(
      icon: Icons.calendar_month,
      title: '欢迎使用 Colendar',
      desc: '一个简洁、好用的课程表应用',
    ),
    _OnboardPage(
      icon: Icons.add_circle_outline,
      title: '轻松添加课程',
      desc: '手动输入课程信息，或批量导入多门课程',
    ),
    _OnboardPage(
      icon: Icons.swap_horiz,
      title: '调课不慌',
      desc: '记录调课、停课信息，课程表自动更新',
    ),
    _OnboardPage(
      icon: Icons.notifications_outlined,
      title: '上课提醒',
      desc: '在课前收到提醒，不再错过任何一节课',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _pages.map((p) => _PageContent(page: p)).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: i == _page ? 20 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i == _page
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_page < _pages.length - 1)
                    FilledButton(
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('下一步'),
                    )
                  else
                    FilledButton(
                      onPressed: () async {
                        await context.read<SettingsProvider>().setOnboardingDone(true);
                        if (context.mounted) context.go('/');
                      },
                      child: const Text('开始使用'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final String title;
  final String desc;
  const _OnboardPage(
      {required this.icon, required this.title, required this.desc});
}

class _PageContent extends StatelessWidget {
  final _OnboardPage page;
  const _PageContent({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.icon,
              size: 100,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 32),
          Text(page.title,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(page.desc,
              style:
                  const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
