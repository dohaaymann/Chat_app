import 'package:example/Constant/colors.dart';
import 'package:example/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class homescreen extends StatefulWidget {
  const homescreen({Key? key}) : super(key: key);

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  @override
  int _selectedIndex = 0;
  // TextStyle optionStyle =TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List _widgetOptions = <Widget>[
    messages({"${FirebaseAuth.instance.currentUser!.uid}"}),
    messages({"${FirebaseAuth.instance.currentUser!.uid}"}),
   ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: pinkyy,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            backgroundColor: Colors.red,
            label: 'Home', // Added label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            backgroundColor: Colors.pink,
            label: 'Profile', // Added label
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
