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
//TODO validation for the game time and stop stockfish!!

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late Map<String, dynamic> _translations;
  late ThemeLanguageProvider _themeLanguageProvider;
  late String email;
  late String password;
  bool obscureText = true;

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


  // sign in user in fireStore
  void signInUser() async {
    final authProvider = context.read<AuthenticationProvider>();

    if (formKey.currentState!.validate()) {
      // Save the form
      formKey.currentState!.save();

      try {
        UserCredential? userCredential = await authProvider.signInUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential != null) {
          // Check if this user exists in Firestore
          bool userExist = await authProvider.checkUserExists();

          if (userExist) {
            // Get user's data from Firestore
            await authProvider.getUserDataFromFireStore();

            // Save user data to shared preferences -- local storage
            await authProvider.saveUserDataToSharedPref();

            // Save this user as signed in
            await authProvider.setSignedIn();
            formKey.currentState!.reset();

            authProvider.setIsLoading(value: false);

            // Navigate to home screen
            navigate(isSignedIn: true);
          } else {
            // Navigate to user information screen
            navigate(isSignedIn: false);
          }
        }
      } on FirebaseAuthException catch (e) {
        // Handle different authentication exceptions
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          // Show red notification for incorrect email or password
          authProvider.showSnackBar(context: context, content: getTranslation('incEmailOrPass', _translations), color: Colors.red);
        } else {
          authProvider.showSnackBar(context: context, content: getTranslation('incEmailOrPass', _translations), color: Colors.red);
        }

        // Stop the loading indicator
        authProvider.setIsLoading(value: false);
      } catch (e) {
        // Handle other exceptions
        authProvider.showSnackBar(context: context, content: '${getTranslation('errorOccurred',_translations)} $e', color: Colors.red);

        // Stop the loading indicator
        authProvider.setIsLoading(value: false);
      }
    } else {
      authProvider.showSnackBar(context: context, content: getTranslation('fillFields', _translations), color: Colors.red);
    }
  }






  navigate({required bool isSignedIn}){
    if(isSignedIn){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
      );
    }
    else{
      //navigate to user information screen
    }
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
            child: Form(
              key: formKey,
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
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      style: TextStyle(color: oppColor),
                      decoration: textFormDecoration.copyWith(
                        labelText: getTranslation('yourEmail', _translations),
                        hintText: getTranslation('yourEmail', _translations),
                      ),
                      validator: (value){
                        if(value!.isEmpty){
                          return getTranslation('emailValidator', _translations);
                        }
                        else if(value.length < 3){
                          return getTranslation('emailLenValidator', _translations);
                        }
                        else if(!validateEmail(value)){
                          return getTranslation('emailNotValid', _translations);
                        }
                        else if(validateEmail(value)){
                          return null;
                        }
                        return null;
                      },
                      onChanged: (value){
                        email = value.trim();
                      },
                    ),
                  ),

                  const SizedBox(height: 10,),
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
                          onPressed: (){
                            setState(() {
                              obscureText = !obscureText;
                            });
                          }, icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        ),
                      ),
                      obscureText: obscureText,
                      //TODO majd you need to replace the return and make it dynamically
                      validator: (value){
                        if(value!.isEmpty){
                          return  getTranslation('passwordValidator', _translations);
                        }
                        else if(value.length < 5){
                          return getTranslation('passwordLenValidator', _translations);
                        }
                        return null;
                      },
                      onChanged: (value){
                        password = value;
                      },
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
                          color:Color(0xff4e3c96),
                        ),
                    ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  authProvider.isLoading ? Lottie.asset(
                    'assets/animations/landing.json',
                    height: 100,
                    width: 100,
                  ) :
                  MainAuthButton(
                      label: getTranslation('login', _translations),

                      onPressed: (){
                        signInUser();
                      },
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
      ),
    );
  }
}


