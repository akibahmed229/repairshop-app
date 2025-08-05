import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';

class AuthGradientButton extends StatelessWidget {
  final String? buttonText;
  final VoidCallback onPressed;
  const AuthGradientButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    //  To make the button full width, & to have a gradient background we use a Container
    return Container(
      width: double.infinity, // Make the button full width
      height: 50,

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppPallete.gradient1, AppPallete.gradient2],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),

      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPallete.transparentColor,
          shadowColor: AppPallete.transparentColor,
        ),
        child: Text(
          '$buttonText',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
