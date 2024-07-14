import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/helper_methods.dart';
import '../providers/theme_language_provider.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  late ThemeLanguageProvider _themeLanguageProvider;
  Map<String, dynamic> translations = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeLanguageProvider = Provider.of<ThemeLanguageProvider>(context);
    loadTranslations(_themeLanguageProvider.currentLanguage).then((value) {
      if (mounted) {
        setState(() {
          translations = value;
        });
      }
    });
  }

  void reloadTranslations(String language) {
    loadTranslations(language).then((value) {
      if (mounted) {
        setState(() {
          translations = value;
        });
      }
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _themeLanguageProvider.isLightMode ? Colors.black : Colors.white;
    final backgroundColor = _themeLanguageProvider.isLightMode ? Colors.white : const Color(0xFF121212);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff4e3c96),
        title: Text(
          getTranslation('communication', translations),
          style: const TextStyle(color: Colors.white, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700),
        ),
        actions: [
          // Dark mode toggle button
          IconButton(
            icon: Icon(_themeLanguageProvider.isLightMode ? Icons.light_mode : Icons.dark_mode),
            color: _themeLanguageProvider.isLightMode ? const Color(0xfff0c230) : const Color(0xfff0f5f7),
            onPressed: _themeLanguageProvider.toggleThemeMode,
          ),
          // Language change button
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (String selectedLanguage) {
              _themeLanguageProvider.changeLanguage(selectedLanguage);
              reloadTranslations(selectedLanguage);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Arabic',
                child: Text('العربية'),
              ),
              const PopupMenuItem<String>(
                value: 'English',
                child: Text('English'),
              ),
            ],
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.facebook, color: Colors.white),
                label: Text('Facebook'),
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.blue, // Facebook color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded edges
                  ),
                  elevation: 10, // Shadow elevation
                ),
                onPressed: () {
                  _launchURL('https://www.facebook.com/Shah2Range/');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                label: Text('Instagram'),
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.purple, // Instagram color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded edges
                  ),
                  elevation: 10, // Shadow elevation
                ),
                onPressed: () {
                  _launchURL('https://www.instagram.com/shah2range/');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.play_circle_outline, color: Colors.white),
                label: Text('YouTube'),
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.red, // YouTube color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded edges
                  ),
                  elevation: 10, // Shadow elevation
                ),
                onPressed: () {
                  _launchURL('https://www.youtube.com/channel/UCNywSWs67G8ML-8goaYUy0A');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.business, color: Colors.white),
                label: Text('LinkedIn'),
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.blueGrey, // LinkedIn color
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded edges
                  ),
                  elevation: 10, // Shadow elevation
                ),
                onPressed: () {
                  _launchURL('https://www.linkedin.com/company/shah2range/?originalSubdomain=il');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
