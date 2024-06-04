import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {

  int selectedIndex = 0;

  NavBar(int selectedIndex, {super.key}){
    this.selectedIndex = selectedIndex;
  }

  @override
  State<NavBar> createState() => _NavBarState(selectedIndex);
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  _NavBarState(int selectedIndex){
    _selectedIndex = selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/login'); //muss auf search geändert werden
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/favorites');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/collection');
          break;
        // case 3:
        //   // Profil-Seite (noch nicht implementiert)
        //   break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Collection',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.transparent,
      elevation: 0,
      onTap: _onItemTapped,
    );
  }
}