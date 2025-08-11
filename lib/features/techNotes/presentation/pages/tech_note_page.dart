import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/features/techNotes/presentation/pages/add_tech_note_page.dart';
import 'package:repair_shop/features/techNotes/presentation/pages/user_tech_note_page.dart';
import 'package:repair_shop/features/techNotes/presentation/pages/view_tech_note_page.dart';

class TechNotePage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const TechNotePage());

  const TechNotePage({super.key});

  @override
  State<TechNotePage> createState() => _TechNotePageState();
}

class _TechNotePageState extends State<TechNotePage> {
  int _selectedIndex = 1;

  static const List<Widget> _pages = <Widget>[
    AddTechNotePage(),
    ViewTechNotePage(),
    UserTechNotePage(),
  ];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppPallete.borderColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),

          child: GNav(
            gap: 8,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            curve: Curves.easeInOut,
            tabBackgroundColor: AppPallete.backgroundColor.withOpacity(0.5),
            activeColor: AppPallete.gradient3,
            tabs: const [
              GButton(icon: Icons.note_add_rounded, text: 'Add Notes'),
              GButton(icon: Icons.sticky_note_2_rounded, text: 'TechNotes'),
              GButton(icon: Icons.settings_rounded, text: 'Setting'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onTabChange,
          ),
        ),
      ),
    );
  }
}
