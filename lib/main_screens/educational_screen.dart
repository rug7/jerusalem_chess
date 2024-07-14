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

    final List<Map<String, String>> videos = [
      {'title': 'أساسيات الرقعة والقطع', 'url': 'https://youtu.be/Tqq7YkZOM6A?si=smYLM-xMYT3AoaVf'},
      {'title': 'القلعة', 'url': 'https://youtu.be/G3XYtc-JHmE?si=677ivMBtfQgTAg1k'},
      {'title': 'الفيل', 'url': 'https://youtu.be/bJLqhgM1rmE?si=nLYH0EkrrPoo7wFU'},
      {'title': 'الملك والوزير', 'url': 'https://youtu.be/K1zcu9Ffe5A?si=KY4SmdaVO4PrNjU5'},
      {'title': 'الحصان', 'url': 'https://youtu.be/0pYq9IavBIw?si=_Z6ZnCc2NEJ8uhDE'},
      {'title': 'الجندي', 'url': 'https://youtu.be/TscGNPle0AQ?si=2p9kdSYs6rjSiQXh'},
      {'title': 'الكش ملك والكش مات', 'url': 'https://youtu.be/gF-4adFXA6U?si=5REO9-TY6WXYEUk0'},
      {'title': 'قيم القطع', 'url': 'https://youtu.be/Q7kTU-13ziM?si=3io5suTvBDTZq73z'},
      {'title': 'أهمية موقع القطعة', 'url': 'https://youtu.be/rfJfi9KrcV0?si=QA-ipnk4XogW-D4M'},
      {'title': 'أفضل طريقة للعب', 'url': 'https://youtu.be/nwiQ8uuCWzg?si=QTUuCdJw6ivyBVf7'},
      {'title': 'التبييت: حركة خاصة للملك', 'url': 'https://youtu.be/TC_EFbfae64?si=H7zgFRcvjuRj-TaM'},
      {'title': 'قصة الشطرنج', 'url': 'https://youtu.be/Y3Gl8AZw5OI?si=MwADF3jGcgDoA-A-'},
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
          crossAxisCount: 2,
          childAspectRatio: 2,
          children: videos.map((video) {
            return buildVideoButton(video['title']!, video['url']!);
          }).toList(),
        ),
      ),
    );
  }

  Widget buildVideoButton(String title, String url) {
    return GestureDetector(
      onTap: () {
        _launchURL(url);
      },
      child: Card(
        color: const Color(0xfff0f5f7),
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
        ),
      ),
    );
  }
}
