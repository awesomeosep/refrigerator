import 'package:flutter/material.dart';

class MyBottomNavBar extends StatefulWidget {
  const MyBottomNavBar({super.key, required this.page});

  final int page;

  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (value) => {
        if (widget.page != value)
          {
            if (value == 0) {Navigator.pushNamed(context, "/home")},
            if (value == 1) {Navigator.pushNamed(context, "/settings")},
          }
      },
      selectedIndex: widget.page,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
