import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';

class TechNoteDropdown extends StatelessWidget {
  final String? assignedTo;
  final List<String> users;
  final ValueChanged<String?>? onChanged;

  const TechNoteDropdown({
    super.key,
    required this.assignedTo,
    required this.users,
    this.onChanged,
  });

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
      initialValue: assignedTo,
      decoration: _dropdownDecoration(),
      dropdownColor: AppPallete.borderColor,
      items: users.map((user) {
        return DropdownMenuItem(value: user, child: Text(user));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
