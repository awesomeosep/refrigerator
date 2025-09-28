import 'package:drawing_app/utils/bottom_nav_bar.dart';
import 'package:drawing_app/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String currentTheme = themeProvider.themeMode == ThemeMode.dark
        ? "dark"
        : (themeProvider.themeMode == ThemeMode.light ? "light" : "system");

    return Scaffold(
      bottomNavigationBar: const MyBottomNavBar(page: 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Settings"),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    const Text("Theme:"),
                    const SizedBox(width: 16),
                    SegmentedButton<String>(
                      multiSelectionEnabled: false,
                      emptySelectionAllowed: true,
                      showSelectedIcon: false,
                      selected: currentTheme.isNotEmpty ? {currentTheme} : {},
                      onSelectionChanged: (Set<String> newSelection) {
                        if (newSelection.first == "dark") {
                          themeProvider.toggleTheme(ThemeMode.dark);
                        } else if (newSelection.first == "light") {
                          themeProvider.toggleTheme(ThemeMode.light);
                        } else if (newSelection.first == "system") {
                          themeProvider.toggleTheme(ThemeMode.system);
                        }
                        setState(() {
                          currentTheme = newSelection.first;
                        });
                      },
                      segments: ["dark", "light", "system"].map<ButtonSegment<String>>((String theme) {
                        return ButtonSegment<String>(
                            value: theme, label: Text(theme[0].toUpperCase() + theme.substring(1)));
                      }).toList(),
                    ),
                  ],
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
