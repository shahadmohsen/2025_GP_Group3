import 'package:flutter/material.dart';
import 'manageprofile.dart'; // Update this import path
import 'clinics.dart';
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
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
            _buildNavItem(context, Icons.person, "الحساب", false),
            _buildNavItem(context, Icons.local_hospital, "العيادات", false),
            _buildMainNavItem(),
            _buildNavItem(context, Icons.calendar_today, "المواعيد", false),
            _buildNavItem(context, Icons.android, "اسألني", false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == "الحساب") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManageProfile()),
          );
        }
        if (label == "العيادات") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListOfClinicsWidget()),
          );
        }
        // You can add similar navigation for other nav items if needed
      },
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

  Widget _buildMainNavItem() {
    return Container(
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
      padding: EdgeInsets.all(10),
      child: Icon(
        Icons.storefront,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}