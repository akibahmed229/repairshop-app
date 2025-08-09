import 'package:flutter/material.dart';

class TechNoteEditor extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final dynamic maxLines;
  final int minLines;
  const TechNoteEditor({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = null,
    this.minLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      maxLines: maxLines,
      minLines: minLines,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your $hintText';
        }
        return null;
      },
    );
  }
}
