import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/bet_provider.dart';
import 'providers/settings_provider.dart';
import 'pages/home/entry_page.dart';
import 'pages/stats/stats_page.dart';
import 'pages/check/check_page.dart';
import 'pages/manage/manage_page.dart';
import 'widgets/dev_bar.dart';

class Lottery3DApp extends StatelessWidget {
  const Lottery3DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BetProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: '福彩 3D 助手',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const MainScaffold(),
          );
        },
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    EntryPage(),
    StatsPage(),
    CheckPage(),
    ManagePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          const Positioned(top: 0, left: 0, right: 0, child: DevBar()),
        ],
      ),
      bottomNavigationBar: const DevBar(),
    );
  }
}
