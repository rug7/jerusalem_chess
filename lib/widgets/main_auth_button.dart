 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_language_provider.dart';

class MainAuthButton extends StatelessWidget {
  const MainAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.fontSize,
  });

  final String label;
  final Function() onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final themeLanguageProvider = Provider.of<ThemeLanguageProvider>(context, listen: false);
    final isLightMode = themeLanguageProvider.isLightMode;
    final oppColor = isLightMode ? Colors.black : Colors.white;
    return Material(
      elevation: 5,
      color: const Color(0xFF663d99),
      borderRadius: BorderRadius.circular(10),
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: double.infinity,
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: oppColor,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
