import 'package:flutter/material.dart';

/// 24 carefully chosen course colors matching the classTime palette.
class CourseColorPalette {
  static const List<String> colors = [
    '#5B9BD5', // 蓝
    '#F5A864', // 橙
    '#6FBE6E', // 绿
    '#9B7BD7', // 紫
    '#F57C82', // 红
    '#52B3D9', // 青
    '#FFD666', // 黄
    '#C89B7D', // 棕
    '#4A90E2', // 深蓝
    '#FF8C69', // 珊瑚橙
    '#4DB897', // 青绿
    '#B28FCE', // 薰衣草紫
    '#EF7A82', // 粉红
    '#58C1D3', // 湖蓝
    '#FFC44C', // 金黄
    '#B8956F', // 卡其棕
    '#6B8DD6', // 钴蓝
    '#FFB347', // 金橙
    '#5FCF80', // 翠绿
    '#A68EC5', // 丁香紫
    '#F59BB0', // 粉色
    '#7FA3B8', // 灰蓝
    '#FA9FB5', // 桃粉
    '#8BA7BB', // 雾蓝
  ];

  static Color colorFromHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  static String getColorForCourse(String courseName, List<String> usedColors) {
    // Deterministic index by hash
    final idx = courseName.hashCode.abs() % colors.length;
    // Try to find an unused color starting from idx
    for (int i = 0; i < colors.length; i++) {
      final candidate = colors[(idx + i) % colors.length];
      if (!usedColors.contains(candidate)) return candidate;
    }
    return colors[idx];
  }

  static String getColorByIndex(int index) =>
      colors[index.abs() % colors.length];

  static int get count => colors.length;

  static List<String> generateRandomScheme(int count) {
    final shuffled = List<String>.from(colors)..shuffle();
    return List.generate(count, (i) => shuffled[i % shuffled.length]);
  }

  static List<String> generateHarmonizedScheme(int count) {
    // Generate evenly-spaced colors from the palette
    final step = colors.length ~/ count;
    return List.generate(count, (i) => colors[(i * step) % colors.length]);
  }
}
