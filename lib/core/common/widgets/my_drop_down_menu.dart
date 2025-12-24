import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';

class MyDropDownMenu extends StatelessWidget {
  final String value;
  final ValueChanged<String?>? onChanged;
  final List<DropdownMenuItem<String>> items;

  const MyDropDownMenu({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: AppPallete.backgroundColor,
        style: const TextStyle(color: AppPallete.whiteColor, fontSize: 16),
        icon: const Icon(Icons.arrow_drop_down, color: AppPallete.whiteColor),
        onChanged: onChanged,
        items: items,
      ),
    );
  }
}
