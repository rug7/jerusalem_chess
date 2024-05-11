import 'package:flutter/material.dart';
import 'package:flutter_chess_1/authentication/login_screen.dart';
import 'package:provider/provider.dart';
import '../helper/helper_methods.dart';
import '../main_screens/color_option_screen.dart';
import '../providers/theme_language_provider.dart';
import '../widgets/main_auth_button.dart';
import '../widgets/widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  late Map<String, dynamic> _translations;
  late ThemeLanguageProvider _themeLanguageProvider;

  @override
  void initState() {
    super.initState();
    _translations = {}; // Initialize translations map
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeLanguageProvider = context.read<ThemeLanguageProvider>(); // Initialize theme language provider
    // Load translations when the screen initializes
    _loadTranslations();
    // Listen for changes in language and reload translations accordingly
    _themeLanguageProvider.addListener(_onLanguageChanged);
  }

  // Load translations from JSON files based on the current language
  Future<void> _loadTranslations() async {
    final language = _themeLanguageProvider.currentLanguage; // Use _themeLanguageProvider here
    final jsonContent = await loadTranslations(language);
    setState(() {
      _translations = jsonContent;
    });
  }

  @override
  void dispose() {
    // Dispose the listener to avoid memory leaks
    _themeLanguageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  // Function to handle language changes
  void _onLanguageChanged() {
    _loadTranslations(); // Reload translations when the language changes
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = _themeLanguageProvider.isLightMode;
    final textColor = isLightMode ? Colors.white : Colors.black;
    final oppColor = isLightMode ? Colors.black : Colors.white;
    final textAlignCheck = _themeLanguageProvider.currentLanguage == 'Arabic' ? TextAlign.right : TextAlign.left;
    final textDirectionCheck = _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr;


    return Scaffold(
      backgroundColor: textColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF663d99),
        title: Text(
          getTranslation('homeTitle', _translations),
          style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(isLightMode ? Icons.light_mode : Icons.dark_mode,),
            color: isLightMode ? const Color(0xfff0c230) : const Color(0xfff0f5f7),
            onPressed: _themeLanguageProvider.toggleThemeMode,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.language, color: textColor),
            onSelected: _themeLanguageProvider.changeLanguage,
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
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  getTranslation('signup', _translations),
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: oppColor,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                 Stack(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFFf0f5f7),
                      backgroundImage: AssetImage('assets/images/user_logo3.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF663d99),
                          border: Border.all(width: 2,color: Colors.white,),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: (){},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 40,
                ),
                Directionality(
                  textDirection: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                  child: TextFormField(
                    style: TextStyle(color: oppColor),
                    textAlign: textAlignCheck,
                    textDirection: textDirectionCheck,
                    decoration: textFormDecoration.copyWith(
                      labelText: getTranslation('yourName', _translations),
                      hintText: getTranslation('yourName', _translations),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Directionality(
                  textDirection: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                  child: TextFormField(
                    style: TextStyle(color: oppColor),
                    textAlign: textAlignCheck,
                    textDirection: textDirectionCheck,
                    decoration: textFormDecoration.copyWith(
                      labelText: getTranslation('yourEmail', _translations),
                      hintText: getTranslation('yourEmail', _translations),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Directionality(
                  textDirection: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                  child: TextFormField(
                    style: TextStyle(color: oppColor),
                    textAlign: textAlignCheck,
                    textDirection: textDirectionCheck,
                    decoration: textFormDecoration.copyWith(
                      labelText: getTranslation('yourPass', _translations),
                      hintText: getTranslation('yourPass', _translations),
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20,),
                MainAuthButton(
                    label: getTranslation('signup', _translations),
                    onPressed: (){},
                    fontSize: 20
                ),

                const SizedBox(height: 40,),
                HaveAccountWidget(
                    label: getTranslation('gotAccount', _translations),
                    labelAction: getTranslation('sign_in', _translations),
                    onPressed: (){

                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
