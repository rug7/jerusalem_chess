import 'package:flutter/material.dart';
import 'package:flutter_chess_1/authentication/sign_up_screen.dart';
import 'package:flutter_chess_1/helper/helper_methods.dart';
import 'package:flutter_chess_1/widgets/main_auth_button.dart';
import 'package:flutter_chess_1/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../main_screens/color_option_screen.dart';
import '../main_screens/home_screen.dart';
import '../providers/theme_language_provider.dart';
import '../widgets/social_button.dart';
//TODO validation for the game time and stop stockfish!!

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

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
                InkWell(
                  onTap: (){
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.asset(
                      'assets/images/black_login_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Text(
                  getTranslation('login', _translations),
                  style: TextStyle(
                      color: oppColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Directionality(
                  textDirection: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                  child: TextFormField(
                    style: TextStyle(color: oppColor),
                    decoration: textFormDecoration.copyWith(
                      labelText: getTranslation('yourEmail', _translations),
                      hintText: getTranslation('yourEmail', _translations),
                    ),
                  ),
                ),

                const SizedBox(height: 10,),
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
                const SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: (){
                    //forgot password method and page

                  }, child: Text(
                      getTranslation('forgotPass', _translations,),
                      style: const TextStyle(
                        color:Color(0xFF663d99),
                      ),
                  ),
                  ),
                ),
                const SizedBox(height: 10,),
                MainAuthButton(
                    label: getTranslation('login', _translations),
                    onPressed: (){},
                    fontSize: 20
                ),
                const SizedBox(height: 15,),
                Text(
                  getTranslation('orSocial', _translations),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isLightMode ? Colors.black26 : Colors.white24,
                      fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SocialButtons(
                        label: getTranslation('facebook', _translations),
                        assetImage: 'assets/images/facebook_logo.png',
                        height: 55.0,
                        width: 55.0,
                        onTap: (){
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                                (Route<dynamic> route) => false,
                          );
                        }
                    ),
                    SocialButtons(
                        label: getTranslation('email', _translations),
                        assetImage: 'assets/images/email_logo.png',
                        height: 55.0,
                        width: 55.0,
                        onTap: (){
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                                (Route<dynamic> route) => false,
                          );
                        }
                    ),
                    SocialButtons(
                        label: getTranslation('phone', _translations),
                        assetImage: 'assets/images/Phone_logo.png',
                        height: 55.0,
                        width: 55.0,
                        onTap: (){
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                                (Route<dynamic> route) => false,
                          );
                        }
                    ),
                  ],
                ),
                const SizedBox(height: 30,),
                HaveAccountWidget(label: getTranslation('noAccount', _translations),labelAction: getTranslation('signup', _translations), onPressed: (){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        (Route<dynamic> route) => false,
                  );
                }),
              ],
            ),
          ),
       ),
      ),
    );
  }
}


