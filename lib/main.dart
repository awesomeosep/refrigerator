import 'package:drawing_app/edit.dart';
import 'package:drawing_app/home.dart';
import 'package:drawing_app/settings.dart';
import 'package:drawing_app/upload.dart';
import 'package:drawing_app/utils/theme_provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightColorScheme;
      ColorScheme darkColorScheme;

      if (lightDynamic != null && darkDynamic != null) {
        // Use dynamic colors if available
        lightColorScheme = lightDynamic.harmonized();
        darkColorScheme = darkDynamic.harmonized();
      } else {
        // Fallback to a baseline color scheme
        lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
        darkColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);
      }

      final themeProvider = Provider.of<ThemeProvider>(context);

      return MaterialApp(
        theme: ThemeData(
          colorScheme: lightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          useMaterial3: true,
        ),
        title: 'Drawing App',
        routes: {
          "/": (context) => const HomePage(),
          "/home": (context) => const HomePage(),
          "/upload": (context) => const UploadPage(),
          "/edit": (context) => const EditPage(),
          "/settings": (context) => const SettingsPage(),
        },
        themeMode: themeProvider.themeMode,
      );
    });
  }
}
