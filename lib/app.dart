import 'package:flutter/material.dart';

import 'screens.dart';
import 'store.dart';
import 'ui.dart';

class SopivaApp extends StatefulWidget {
  const SopivaApp({super.key});

  @override
  State<SopivaApp> createState() => _SopivaAppState();
}

class _SopivaAppState extends State<SopivaApp> {
  final store = SopivaStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SOPIVA',
          theme: sopivaTheme(Brightness.light),
          darkTheme: sopivaTheme(Brightness.dark),
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(store: store),
        );
      },
    );
  }
}
