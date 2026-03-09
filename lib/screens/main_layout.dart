import 'package:flutter/material.dart';
import 'buyer/home_screen.dart';
import 'buyer/orders_screen.dart';
import 'buyer/saved_screen.dart';    // <-- Tambahan baru
import 'buyer/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Ini daftar halaman dummy untuk tiap tab
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    OrdersScreen(),
    SavedScreen(),   // <-- Ganti teks dummy jadi ini
    ProfileScreen(),
    Center(child: Text('Halaman Beranda (Dashboard) Nanti Di Sini', style: TextStyle(fontSize: 18))),
    Center(child: Text('Halaman Order & History Nanti Di Sini', style: TextStyle(fontSize: 18))),
    Center(child: Text('Halaman Saved/Favorit Nanti Di Sini', style: TextStyle(fontSize: 18))),
    Center(child: Text('Halaman Profil Nanti Di Sini', style: TextStyle(fontSize: 18))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Biar labelnya tetep keliatan walau lebih dari 3 tab
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE46A25), // Warna Oranye sesuai tema
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}