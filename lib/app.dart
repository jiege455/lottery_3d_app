import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/bet_provider.dart';
import 'providers/settings_provider.dart';
import 'pages/home/entry_page.dart';
import 'pages/stats/stats_page.dart';
import 'pages/check/check_page.dart';
import 'pages/manage/manage_page.dart';

class Lottery3DApp extends StatelessWidget {
  const Lottery3DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BetProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: '福彩3D助手',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppErrorBoundary(child: MainScaffold()),
        builder: (context, widget) {
          ErrorWidget.builder = (details) {
            return Material(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: AppColors.danger),
                        const SizedBox(height: 16),
                        const Text('应用遇到了问题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('请重新打开应用，如问题持续请联系开发者', style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text('开发者：杰哥网络科技', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          };
          return widget ?? const SizedBox.shrink();
        },
      ),
    );
  }
}

class AppErrorBoundary extends StatefulWidget {
  final Widget child;
  const AppErrorBoundary({super.key, required this.child});

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      setState(() => _hasError = true);
      originalOnError?.call(details);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text('加载遇到问题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _hasError = false),
                  child: const Text('点击重试'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[
    EntryPage(),
    StatsPage(),
    CheckPage(),
    ManagePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: '录入'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '统计'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_outlined), label: '校验'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: '管理'),
        ],
      ),
    );
  }
}
