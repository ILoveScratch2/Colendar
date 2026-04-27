import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

const double kWindowHeaderHeight = 40.0;

/// 仅在 Windows / Linux 上生效，在 Column 顶部留出标题栏高度
/// 并通过 Stack 把 [WindowHeader] 叠在最上层。
class WindowHeaderContainer extends StatelessWidget {
  final Widget child;

  const WindowHeaderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows && !Platform.isLinux) {
      return child;
    }
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: kWindowHeaderHeight),
            Expanded(child: child),
          ],
        ),
        const WindowHeader(),
      ],
    );
  }
}

class WindowHeader extends StatefulWidget {
  const WindowHeader({super.key});

  @override
  State<WindowHeader> createState() => _WindowHeaderState();
}

class _WindowHeaderState extends State<WindowHeader> with WindowListener {
  final _isMaximizedNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.isMaximized().then((v) => _isMaximizedNotifier.value = v);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _isMaximizedNotifier.dispose();
    super.dispose();
  }

  @override
  void onWindowMaximize() => _isMaximizedNotifier.value = true;

  @override
  void onWindowUnmaximize() => _isMaximizedNotifier.value = false;

  Future<void> _toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      child: SizedBox(
        height: kWindowHeaderHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 拖拽区域（双击最大化/还原）
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (_) => windowManager.startDragging(),
              onDoubleTap: _toggleMaximize,
              child: const SizedBox.expand(),
            ),
            // 应用标题
            Positioned(
              left: 16,
              child: Text(
                'Colendar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            // 窗口操作按钮
            Positioned(
              right: 0,
              child: Row(
                children: [
                  _HeaderButton(
                    onPressed: () => windowManager.minimize(),
                    icon: Icons.remove,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isMaximizedNotifier,
                    builder: (_, isMaximized, __) => _HeaderButton(
                      onPressed: _toggleMaximize,
                      icon: isMaximized ? Icons.filter_none : Icons.crop_square,
                      iconSize: isMaximized ? 18 : 20,
                    ),
                  ),
                  _HeaderButton(
                    onPressed: () => windowManager.close(),
                    icon: Icons.close,
                    isClose: true,
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

class _HeaderButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double iconSize;
  final bool isClose;

  const _HeaderButton({
    required this.onPressed,
    required this.icon,
    this.iconSize = 18,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: kWindowHeaderHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          hoverColor: isClose
              ? Colors.red.withValues(alpha: 0.85)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          child: Icon(icon, size: iconSize),
        ),
      ),
    );
  }
}
