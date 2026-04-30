import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'providers/schedule_provider.dart';
import 'providers/settings_provider.dart';
import 'navigation/router.dart';
import 'widgets/window_header.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  if (Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      minimumSize: Size(500, 400),
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  await NotificationService().initialize();
  runApp(const ColendarApp());
}

class ColendarApp extends StatefulWidget {
  const ColendarApp({super.key});

  @override
  State<ColendarApp> createState() => _ColendarAppState();
}

class _ColendarAppState extends State<ColendarApp> {
  final _settings = SettingsProvider();
  final _schedule = ScheduleProvider();
  late final _router = buildRouter(_settings);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _settings.load();
    await _schedule.load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _settings),
        ChangeNotifierProvider.value(value: _schedule),
      ],
      child: Consumer<SettingsProvider>(
        builder: (_, settings, __) {
          return MaterialApp.router(
            title: 'Colendar',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(settings.seedColor),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'NotoSansSC',
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(settings.seedColor),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              fontFamily: 'NotoSansSC',
            ),
            builder: (context, child) =>
                WindowHeaderContainer(child: child!),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
