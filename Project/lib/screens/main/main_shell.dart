import 'package:flutter/material.dart';

import '../blood_banks/blood_banks_screen.dart';
import '../find_blood/find_blood_screen.dart';
import '../hospitals/hospitals_screen.dart';
import '../home/home_screen.dart';
import '../doctors/doctors_screen.dart';
import '../profile/profile_screen.dart';

/// Hosts the 6 bottom-navigation tabs (Phase 3):
/// Home | Find Blood | Hospitals | Doctors | Blood Banks | Profile
///
/// Donate, Camps and the role-based admin dashboards are reachable
/// from the Home tab (cards + "See all" links).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.bloodtype_outlined),
      selectedIcon: Icon(Icons.bloodtype),
      label: 'Find Blood',
    ),
    NavigationDestination(
      icon: Icon(Icons.local_hospital_outlined),
      selectedIcon: Icon(Icons.local_hospital),
      label: 'Hospitals',
    ),
    NavigationDestination(
      icon: Icon(Icons.medical_services_outlined),
      selectedIcon: Icon(Icons.medical_services),
      label: 'Doctors',
    ),
    NavigationDestination(
      icon: Icon(Icons.water_drop_outlined),
      selectedIcon: Icon(Icons.water_drop),
      label: 'Blood Banks',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  static const List<Widget> _screens = [
    HomeScreen(),
    FindBloodScreen(),
    HospitalsScreen(),
    DoctorsScreen(),
    BloodBanksScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations,
      ),
    );
  }
}
