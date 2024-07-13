import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_1/authentication/sign_up_screen.dart';
import 'package:flutter_chess_1/helper/helper_methods.dart';
import 'package:flutter_chess_1/widgets/main_auth_button.dart';
import 'package:flutter_chess_1/widgets/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../main_screens/home_screen.dart';
import '../providers/authentication_provider.dart';
import '../providers/theme_language_provider.dart';
import '../widgets/social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Map<String, dynamic> _translations;
  late ThemeLanguageProvider _themeLanguageProvider;
  late String email;
  late String password;
  late String phoneNumber;
  bool obscureText = true;
  bool isEnteringPhone = false; // Track if entering phone number

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _translations = {}; // Initialize translations map
    _checkIfSignedIn();
  }

  Future<void> _checkIfSignedIn() async {
    final authProvider = context.read<AuthenticationProvider>();

    bool isSignedIn = await authProvider.checkIfSignedIn();
    if (isSignedIn) {
      navigateToHome();
    }
  }

  void navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeLanguageProvider = context.read<ThemeLanguageProvider>();
    _loadTranslations();
    _themeLanguageProvider.addListener(_onLanguageChanged);
  }

  Future<void> _loadTranslations() async {
    final language = _themeLanguageProvider.currentLanguage;
    final jsonContent = await loadTranslations(language);
    if (mounted) {
      setState(() {
        _translations = jsonContent;
      });
    }
  }

  @override
  void dispose() {
    _themeLanguageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _loadTranslations();
  }

  void signInUser() async {
    final authProvider = context.read<AuthenticationProvider>();

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      try {
        UserCredential? userCredential;

        if (isEnteringPhone) {
          // Proceed with signing in with phone number and password
          userCredential = await authProvider.signInWithPhoneNumberAndPassword(
            phoneNumber: phoneNumber,
            password: password,
          );

          if (userCredential == null) {
            authProvider.showSnackBar(context: context, content: 'Phone number or password is incorrect', color: Colors.red);
            return;
          }
        } else {
          // Sign in with email and password
          userCredential = await authProvider.signInUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        }

        if (userCredential != null) {
          // Handle success, navigate to home or other screen
          bool userExists = await authProvider.checkUserExists();

          if (userExists) {
            await authProvider.getUserDataFromFireStore();
            await authProvider.saveUserDataToSharedPref();
            await authProvider.setSignedIn();
            formKey.currentState!.reset();

            authProvider.setIsLoading(value: false);
            navigate(isSignedIn: true);
          } else {
            // Handle case where user does not exist (optional)
            authProvider.showSnackBar(context: context, content: 'User does not exist', color: Colors.red);
          }
        }
      } on FirebaseAuthException catch (e) {
        // Handle FirebaseAuthException for email/password sign-in
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          authProvider.showSnackBar(context: context, content: getTranslation('incEmailOrPass', _translations), color: Colors.red);
        } else {
          authProvider.showSnackBar(context: context, content: getTranslation('incEmailOrPass', _translations), color: Colors.red);
        }

        authProvider.setIsLoading(value: false);
      } catch (e) {
        // Handle other errors
        authProvider.showSnackBar(context: context, content: '${getTranslation('errorOccurred', _translations)} $e', color: Colors.red);
        authProvider.setIsLoading(value: false);
      }
    } else {
      // Form validation failed
      authProvider.showSnackBar(context: context, content: getTranslation('fillFields', _translations), color: Colors.red);
    }
  }

  void navigate({required bool isSignedIn}) {
    if (isSignedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
      );
    }
    // Else handle navigation for non-signed-in case
  }

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String resetEmail = '';
        return AlertDialog(
          title: Text(getTranslation('forgotPass', _translations)),
          content: TextFormField(
            decoration: InputDecoration(
              labelText: getTranslation('yourEmail', _translations),
              hintText: getTranslation('yourEmail', _translations),
            ),
            onChanged: (value) {
              resetEmail = value.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(getTranslation('cancel', _translations)),
            ),
            TextButton(
              onPressed: () {
                if (resetEmail.isNotEmpty) {
                  final authProvider = context.read<AuthenticationProvider>();
                  authProvider.sendPasswordResetEmail(resetEmail);
                  Navigator.pop(context);
                }
              },
              child: Text(getTranslation('send', _translations)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    final isLightMode = _themeLanguageProvider.isLightMode;
    final textColor = isLightMode ? Colors.white : Colors.black;
    final oppColor = isLightMode ? Colors.black : Colors.white;
    final textAlignCheck = _themeLanguageProvider.currentLanguage == 'Arabic' ? TextAlign.right : TextAlign.left;
    final textDirectionCheck = _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr;

    return Scaffold(
      backgroundColor: textColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff4e3c96),
        title: Text(
          getTranslation('homeTitle', _translations),
          style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(isLightMode ? Icons.light_mode : Icons.dark_mode),
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
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {},
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
                    style: TextStyle(color: oppColor, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Directionality(
                    textDirection: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      style: TextStyle(color: oppColor),
                      decoration: textFormDecoration.copyWith(
                        labelText: isEnteringPhone ? getTranslation('enteryourphonenumber', _translations) : getTranslation('yourEmail', _translations),
                        hintText: isEnteringPhone ? getTranslation('enteryourphonenumber', _translations) : getTranslation('yourEmail', _translations),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return isEnteringPhone ? getTranslation('invalidPhoneNumber', _translations) : getTranslation('emailValidator', _translations);
                        } else if (!isEnteringPhone && !validateEmail(value)) {
                          return getTranslation('emailNotValid', _translations);
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (isEnteringPhone) {
                          phoneNumber = value.trim();
                        } else {
                          email = value.trim();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Directionality(
                    textDirection: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      style: TextStyle(color: oppColor),
                      textAlign: textAlignCheck,
                      textDirection: textDirectionCheck,
                      decoration: textFormDecoration.copyWith(
                        counterText: '',
                        labelText: getTranslation('yourPass', _translations),
                        hintText: getTranslation('yourPass', _translations),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                      obscureText: obscureText,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return getTranslation('passwordValidator', _translations);
                        } else if (value.length < 5) {
                          return getTranslation('passwordLenValidator', _translations);
                        }
                        return null;
                      },
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showPasswordResetDialog,
                      child: Text(
                        getTranslation('forgotPass', _translations),
                        style: const TextStyle(color: Color(0xff4e3c96)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  authProvider.isLoading
                      ? Lottie.asset(
                    'assets/animations/landing.json',
                    height: 100,
                    width: 100,
                  )
                      : MainAuthButton(
                    label: getTranslation('login', _translations),
                    onPressed: signInUser,
                    fontSize: 20,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    getTranslation('orSocial', _translations),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isLightMode ? Colors.black26 : Colors.white24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SocialButtons(
                        label: getTranslation('facebook', _translations),
                        assetImage: 'assets/images/facebook_logo.png',
                        height: 55.0,
                        width: 55.0,
                        onTap: () {
                          // Handle Facebook login
                        },
                      ),
                      SocialButtons(
                        label: getTranslation('email', _translations),
                        assetImage: 'assets/images/email_logo.png',
                        height: 55.0,
                        width: 55.0,
                        onTap: () {
                          setState(() {
                            isEnteringPhone = false; // Switch to email input
                          });
                        },
                      ),
                      SocialButtons(
                        label: getTranslation('phone', _translations),
                        assetImage: 'assets/images/Phone_logo.png',
                        height: 55.0,
                        width: 55.0,
                        onTap: () {
                          setState(() {
                            isEnteringPhone = true; // Switch to phone number input
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  HaveAccountWidget(
                    label: getTranslation('noAccount', _translations),
                    labelAction: getTranslation('signup', _translations),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
