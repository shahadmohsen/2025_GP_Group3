import 'package:flutter/material.dart';
import 'manageprofile.dart';
import 'clinics.dart';
import 'pages/chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Set initial index to 2 for the middle button
  int _currentIndex = 2;
  final PageController _pageController = PageController(initialPage: 2);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Your page content remains the same
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          const ChatPage(),
          Container(color: Colors.white),
          Container(color: Colors.white),
          const ListOfClinicsWidget(),
          const ManageProfile(),
        ],
      ),
      // Modified bottom navigation bar
      bottomNavigationBar: SafeArea(
        bottom: true, // Ensures padding at the bottom for safe area
        child: Container(
          // Remove fixed height to let it size naturally
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.person, "الحساب", _currentIndex == 4, () => _onItemTapped(4)),
              _buildNavItem(Icons.local_hospital, "العيادات", _currentIndex == 3, () => _onItemTapped(3)),
              _buildMainNavItem(() => _onItemTapped(2)),
              _buildNavItem(Icons.calendar_today, "المواعيد", _currentIndex == 1, () => _onItemTapped(1)),
              _buildNavItem(Icons.android, "اسألني", _currentIndex == 0, () => _onItemTapped(0)),
            ],
          ),
        ),
      ),
      extendBody: true, // This helps content extend under the navigation bar if needed
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.blue : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainNavItem(VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amberAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: const Icon(
            Icons.storefront,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
