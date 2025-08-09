import 'package:flutter/material.dart';

class TechNoteEditor extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  const TechNoteEditor({
    super.key,
    required this.controller,
    required this.hintText,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      maxLines: maxLines,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your $hintText';
        }
        return null;
      },
    );
  }
}
