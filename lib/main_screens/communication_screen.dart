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
  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri uri = Uri.parse("https://wa.me/$phoneNumber");
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _themeLanguageProvider.isLightMode ? Colors.black : Colors
        .white;
    final backgroundColor = _themeLanguageProvider.isLightMode
        ? Colors.white
        : const Color(0xFF121212);
    final cardColor = _themeLanguageProvider.isLightMode ? const Color(0xfff0f5f7) : const Color(0xff1e1e1e);


    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff4e3c96),
        title: Text(
          getTranslation('communication', translations),
          style: const TextStyle(color: Colors.white,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700),
        ),
        actions: [
          // Dark mode toggle button
          IconButton(
            icon: Icon(
                _themeLanguageProvider.isLightMode ? Icons.light_mode : Icons
                    .dark_mode),
            color: _themeLanguageProvider.isLightMode
                ? const Color(0xfff0c230)
                : const Color(0xfff0f5f7),
            onPressed: _themeLanguageProvider.toggleThemeMode,
          ),
          // Language change button
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (String selectedLanguage) {
              _themeLanguageProvider.changeLanguage(selectedLanguage);
              reloadTranslations(selectedLanguage);
            },
            itemBuilder: (BuildContext context) =>
            [
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildContactCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  context: context,
                  logoPath: 'assets/images/new_facebook_logo.png',
                  title: 'Facebook',
                  subtitle: getTranslation('contactUsFacebook', translations),
                  url: 'https://www.facebook.com/Shah2Range/',
                ),
                const SizedBox(height: 20),
                buildContactCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  context: context,
                  logoPath: 'assets/images/instagram_logo.png',
                  title: 'Instagram',
                  subtitle: getTranslation('contactUsInstagram', translations),
                  url: 'https://www.instagram.com/shah2range/',
                ),
                const SizedBox(height: 20),
                buildWhatsAppContactCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  context: context,
                  logoPath: 'assets/images/whatsapp_logo.png',
                  title: 'WhatsApp',
                  subtitle: getTranslation('contactUsWhatsApp', translations),
                  phoneNumber: '+972587130219', // Replace with the actual phone number
                ),
                const SizedBox(height: 20),
                buildContactCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  context: context,
                  logoPath: 'assets/images/youtube_logo.png',
                  title: 'YouTube',
                  subtitle: getTranslation('contactUsYouTube', translations),
                  url: 'https://www.youtube.com/channel/UCNywSWs67G8ML-8goaYUy0A',
                ),
                const SizedBox(height: 20),
                buildContactCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  context: context,
                  logoPath: 'assets/images/linkedin_logo.png',
                  title: 'LinkedIn',
                  subtitle: getTranslation('contactUsLinkedIn', translations),
                  url: 'https://www.linkedin.com/company/shah2range/?originalSubdomain=il',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContactCard({
    required BuildContext context,
    required String logoPath,
    required String title,
    required String subtitle,
    required String url,
    required Color cardColor,
    required Color textColor,
  }) {
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
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  logoPath,
                  height: 50,
                  width: 50,
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style:  TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: textColor
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style:  TextStyle(
                  fontSize: 16,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w400,
                  color: textColor

                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildWhatsAppContactCard({
    required BuildContext context,
    required String logoPath,
    required String title,
    required String subtitle,
    required String phoneNumber,
    required Color cardColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () {
        _launchWhatsApp(phoneNumber);
      },
      child: Card(
        color: cardColor,
        elevation: 2,
        margin: const EdgeInsets.all(2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  logoPath,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style:  TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: textColor
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style:  TextStyle(
                  fontSize: 16,
                  fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w400,
                  color: textColor
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}