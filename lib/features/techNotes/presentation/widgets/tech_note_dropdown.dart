import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';

class TechNoteDropdown extends StatefulWidget {
  final String assignedTo;
  final List<String> users;

  const TechNoteDropdown({
    super.key,
    required this.users,
    required this.assignedTo,
  });

  @override
  State<TechNoteDropdown> createState() => _TechNoteDropdownState();
}

class _TechNoteDropdownState extends State<TechNoteDropdown> {
  // Set my dropdown’s current selection to whatever the parent widget gave me as the starting value.
  late String _selectedUser;

  @override
  void initState() {
    super.initState();
    // Set my dropdown’s current selection to whatever the parent widget gave me as the starting value.
    _selectedUser = widget.assignedTo;
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppPallete.borderColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedUser,
      items: widget.users
          .map((user) => DropdownMenuItem(value: user, child: Text(user)))
          .toList(),
      decoration: _dropdownDecoration(),
      dropdownColor: AppPallete.borderColor,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedUser = value);
        }
      },
    );
  }
}
