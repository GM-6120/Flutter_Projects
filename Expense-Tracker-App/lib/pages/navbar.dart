import 'package:bottom_navy_bar/bottom_navy_bar.dart';

import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'account.dart';
import 'dashboard_page.dart';
import 'transaction.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bodySection(),
      bottomNavigationBar: customBottomNavigationBar(),
    );
  }

// * Body Section Components
  bodySection() {
    switch (index) {
      case 0:
        return MyHomePage();
      case 1:
        return TransactionPage();
      case 2:
        return ProfileScreen();
    }
  }

  customBottomNavigationBar() {
    return BottomNavyBar(
      selectedIndex: index,
      items: [
        BottomNavyBarItem(
          icon: Icon(Icons.home_outlined),
          title: Text('Home'),
          activeColor: kButtonColor,
          textAlign: TextAlign.center,
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.list_alt_sharp),
            title: Text('Transactions'),
            activeColor: kButtonColor,
            textAlign: TextAlign.center),
        BottomNavyBarItem(
          icon: Icon(Icons.person_2_outlined),
          title: Text('Account'),
          activeColor: kButtonColor,
          textAlign: TextAlign.center,
        ),
      ],
      onItemSelected: (index) => setState(() => this.index = index),
    );
  }
}
