import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helper/helper_methods.dart';
import '../providers/theme_language_provider.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late ThemeLanguageProvider _themeLanguageProvider;
  Map<String, dynamic> translations = {};

  final List<Map<String, String>> news = [
    {
      'title': 'title1',
      'description': 'des1',
      'link': 'https://www.facebook.com/share/p/Bw2AwLz2DJUxkpVE/?mibextid=oFDknk',
    },
    {
      'title': 'title2',
      'description': 'des2',
      'link': 'https://www.facebook.com/share/p/ZoVbaiypkmMT5tav/?mibextid=oFDknk',
    },
    {
      'title': 'title3',
      'description': 'des3',
      'link': 'https://www.facebook.com/share/p/GaCQ6tXmjVEoLUCB/?mibextid=oFDknk',
    },
    {
      'title': 'title4',
      'description': 'des4',
      'link': 'https://www.facebook.com/share/p/YomyMBsqCUxwYWgR/?mibextid=oFDknk',
    },
    {
      'title': 'title5',
      'description': 'des5',
      'link': 'https://www.facebook.com/share/p/P2E3edjBqGGdHFUR/?mibextid=oFDknk',
    },
    {
      'title': 'title6',
      'description': 'des6',
      'link': 'https://www.facebook.com/share/p/QuSp3cuQjvPXDY5b/?mibextid=oFDknk',
    },
    {
      'title': 'title7',
      'description': 'des7',
      'link': 'https://www.facebook.com/share/p/Q5qQAZSKTbEJTHQd/?mibextid=oFDknk',
    },
    {
      'title': 'title8',
      'description': 'des8',
      'link': 'https://www.facebook.com/share/p/hVBtUZTHjHtJRn1z/?mibextid=oFDknk',
    },
  ];

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
    final textAlignCheck = _themeLanguageProvider.currentLanguage == 'Arabic' ? TextAlign.right : TextAlign.left;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff4e3c96),
        title: Text(
          getTranslation('news', translations),
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: news.length,
        itemBuilder: (context, index) {
          return Card(
            color: _themeLanguageProvider.isLightMode ? Colors.white : Colors.grey[800],
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: _themeLanguageProvider.currentLanguage == 'Arabic' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslation(news[index]['title']!, translations),
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    textAlign: textAlignCheck,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getTranslation(news[index]['description']!, translations),
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: textColor,
                    ),
                    textAlign: textAlignCheck,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: _themeLanguageProvider.currentLanguage == 'Arabic' ? Alignment.centerLeft : Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => _launchURL(news[index]['link']!),
                      style: ElevatedButton.styleFrom(
                        iconColor: const Color(0xff4e3c96),
                      ),
                      child: Text(
                        getTranslation('readMore', translations),
                        style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
