import 'package:flutter/material.dart';
import 'package:prayer_times/about_screen.dart';
import 'package:prayer_times/donate_screen.dart';
import 'prayer_times_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    PrayerTimesScreen(),
    AboutScreen(),
    DonateScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false, // Hide selected tab labels
        showUnselectedLabels: false, // Hide unselected tab labels
        backgroundColor: Colors.white, // Change background color
        selectedItemColor: Color(0xFF15977e), // Change selected item color
        unselectedItemColor: Color(0xFF135776), // Change unselected item color
        items: const [
          BottomNavigationBarItem( icon: Icon(Icons.access_time), label: 'Prayer Times', ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          BottomNavigationBarItem( icon: Icon(Icons.card_giftcard), label: 'Donate', ),
          BottomNavigationBarItem( icon: Icon(Icons.settings), label: 'Settings', ),
        ],
      ),
    );
  }
}
