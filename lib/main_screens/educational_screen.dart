import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/helper_methods.dart';
import '../providers/theme_language_provider.dart';

class EducationalScreen extends StatefulWidget {
  const EducationalScreen({super.key});

  @override
  State<EducationalScreen> createState() => _EducationalScreenState();
}

class _EducationalScreenState extends State<EducationalScreen> {
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
    final cardColor = _themeLanguageProvider.isLightMode ? const Color(0xfff0f5f7) : const Color(0xff1e1e1e);

    final List<Map<String, String>> videos = [
      {'title': getTranslation('video1', translations), 'url': 'https://youtu.be/Tqq7YkZOM6A?si=smYLM-xMYT3AoaVf'},
      {'title': getTranslation('video2', translations), 'url': 'https://youtu.be/G3XYtc-JHmE?si=677ivMBtfQgTAg1k'},
      {'title': getTranslation('video3', translations), 'url': 'https://youtu.be/bJLqhgM1rmE?si=nLYH0EkrrPoo7wFU'},
      {'title': getTranslation('video4', translations), 'url': 'https://youtu.be/K1zcu9Ffe5A?si=KY4SmdaVO4PrNjU5'},
      {'title': getTranslation('video5', translations), 'url': 'https://youtu.be/0pYq9IavBIw?si=_Z6ZnCc2NEJ8uhDE'},
      {'title': getTranslation('video6', translations), 'url': 'https://youtu.be/TscGNPle0AQ?si=2p9kdSYs6rjSiQXh'},
      {'title': getTranslation('video7', translations), 'url': 'https://youtu.be/gF-4adFXA6U?si=5REO9-TY6WXYEUk0'},
      {'title': getTranslation('video8', translations), 'url': 'https://youtu.be/Q7kTU-13ziM?si=3io5suTvBDTZq73z'},
      {'title': getTranslation('video9', translations), 'url': 'https://youtu.be/rfJfi9KrcV0?si=QA-ipnk4XogW-D4M'},
      {'title': getTranslation('video10', translations), 'url': 'https://youtu.be/nwiQ8uuCWzg?si=QTUuCdJw6ivyBVf7'},
      {'title': getTranslation('video11', translations), 'url': 'https://youtu.be/TC_EFbfae64?si=H7zgFRcvjuRj-TaM'},
      {'title': getTranslation('video12', translations), 'url': 'https://youtu.be/Y3Gl8AZw5OI?si=MwADF3jGcgDoA-A-'}
    ];


    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff4e3c96),
        title: Text(
          getTranslation('edu', translations),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 1, // Adjust the number of columns
          childAspectRatio: 6, // Adjust the aspect ratio to make rectangles
          children: videos.map((video) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: buildVideoButton(video['title']!, video['url']!, textColor, cardColor),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildVideoButton(String title, String url, Color textColor, Color cardColor) {
    return GestureDetector(
      onTap: () {
        _launchURL(url);
      },
      child: Card(
        color: cardColor,
        elevation: 2,
        margin: const EdgeInsets.all(2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10), // Adjust padding if needed
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'IBM Plex Sans Arabic',
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10), // Adjust padding if needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
