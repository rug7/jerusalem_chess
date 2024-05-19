import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_language_provider.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
    required this.label,
    required this.assetImage,
    required this.height,
    required this.width,
    required this.onTap,
  });
  final String label;
  final String assetImage;
  final double height;
  final double width;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final themeLanguageProvider = Provider.of<ThemeLanguageProvider>(context, listen: false);
    final isLightMode = themeLanguageProvider.isLightMode;
    final textColor = isLightMode ? Colors.black : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                )
              ],
              image: DecorationImage(
                image: AssetImage(
                  assetImage,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),

    );
  }
}