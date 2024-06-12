import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_1/authentication/login_screen.dart';
import 'package:flutter_chess_1/main_screens/home_screen.dart';
import 'package:flutter_chess_1/models/user_model.dart';
import 'package:flutter_chess_1/providers/authentication_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../helper/helper_methods.dart';
import '../providers/theme_language_provider.dart';
import '../widgets/main_auth_button.dart';
import '../widgets/widgets.dart';
import 'loading.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  File? finalFileImage;
  String fileImageUrl = '';
  late String name;
  late String email;
  late String password;
  late String confirmPassword;
  bool obscureText = true;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // final TextEditingController nameController = TextEditingController();
  // final TextEditingController emailController = TextEdi tingController();
  // final TextEditingController passwordController = TextEditingController();


  late Map<String, dynamic> _translations;
  late ThemeLanguageProvider _themeLanguageProvider;

  void selectImage({required bool fromCamera})async{
    finalFileImage= await pickImage(
        fromCamera: fromCamera,
        onFail: (e){
          showSnackBar(context: context, content: e.toString());
        });

    if(finalFileImage != null){
      cropImage(finalFileImage!.path);
    }
    else{
      popCropDialog();
    }
  }

  void cropImage(String path) async{
    CroppedFile ? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      maxHeight: 800,
      maxWidth: 800,
    );
    popCropDialog();

    if(croppedFile != null){
      setState(() {
        finalFileImage = File(croppedFile.path);
      });

      // print('imagePath: $finalFileImage');
    }else{
      popCropDialog();
    }


  }

  void popCropDialog(){
    Navigator.pop(context);
  }



  void showImagePickerDialog(){
    showDialog(
        context: context,
        builder: (context){
          return  AlertDialog(
            title: const Text("Select an Option",style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700,),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: (){
                    //choose image from camera
                    selectImage(fromCamera: true);

                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text("Gallery"),
                  onTap: (){
                    //choose image from gallery
                    selectImage(fromCamera: false);

                  },
                ),
              ],
            ),
          );
        });
  }

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
    // nameController.dispose();
    // emailController.dispose();
    // passwordController.dispose();
    super.dispose();
  }

  // Function to handle language changes
  void _onLanguageChanged() {
    _loadTranslations(); // Reload translations when the language changes
  }

  //signUp user in fireStore
  // signUp user in fireStore
  // void signUpUser() async {
  //   final authProvider = context.read<AuthenticationProvider>();
  //
  //   if (formKey.currentState!.validate()) {
  //     // Save the form
  //     formKey.currentState!.save();
  //
  //     try {
  //       UserCredential? userCredential = await authProvider.createUserWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //       );
  //
  //       if (userCredential != null) {
  //         // User created - save to firestore
  //         print('User created: ${userCredential.user!.uid}');
  //
  //         UserModel userModel = UserModel(
  //           uid: userCredential.user!.uid,
  //           name: name,
  //           email: email,
  //           image: '',
  //           createdAt: '',
  //         );
  //
  //         authProvider.saveUserDataToFireStore(
  //           currentUser: userModel,
  //           fileImage: finalFileImage,
  //           onSuccess: () async {
  //             formKey.currentState!.reset();
  //
  //             // Sign out the user and navigate to the login screen
  //             authProvider.showSnackBar(context: context, content: 'Signed Up Successfully',color: Colors.green);
  //
  //             await authProvider.sighOutUser().whenComplete(() {
  //               Navigator.pushAndRemoveUntil(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => const HomeScreen()),
  //                     (Route<dynamic> route) => false,
  //               );
  //             });
  //           },
  //           onFail: (error) {
  //             authProvider.showSnackBar(context: context, content: error.toString());
  //           },
  //         );
  //       }
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'email-already-in-use') {
  //         // Handle the case where the user's email already exists
  //         authProvider.showSnackBar(context: context, content: 'The email address is already in use.',color: Colors.red);
  //       } else {
  //         // Handle other FirebaseAuthExceptions
  //         authProvider.showSnackBar(context: context, content: 'Sign up failed. ${e.message}',color: Colors.red);
  //       }
  //       authProvider.setIsLoading(value: false);
  //     } catch (e) {
  //       // Handle other exceptions
  //       authProvider.showSnackBar(context: context, content: 'Sign up failed. $e',color: Colors.red);
  //     }
  //   } else {
  //     authProvider.showSnackBar(context: context, content: 'Please fill all fields',color: Colors.red);
  //   }
  // }

  // signUp user in fireStore
  void signUpUser() async {
    final authProvider = context.read<AuthenticationProvider>();

    if (formKey.currentState!.validate()) {
      // Save the form
      formKey.currentState!.save();

      if (password != confirmPassword) {
        authProvider.showSnackBar(context: context, content: getTranslation('passwordMismatch', _translations), color: Colors.red);
        return;
      }

      try {
        // Set loading state to true
        authProvider.setIsLoading(value: true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoadingScreen()),
        );
        // Set loading state to true

        UserCredential? userCredential = await authProvider.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential != null) {
          // User created - save to firestore
          //print('User created: ${userCredential.user!.uid}');

          UserModel userModel = UserModel(
            uid: userCredential.user!.uid,
            name: name,
            email: email,
            image: '',
            createdAt: '',
            playerRating: 700,
          );

          authProvider.saveUserDataToFireStore(
            currentUser: userModel,
            fileImage: finalFileImage,
            onSuccess: () async {


              formKey.currentState!.reset();
              // Save user data to shared preferences
              await authProvider.saveUserDataToSharedPref();

              // Set the signed-in state
              await authProvider.setSignedIn();

              // Sign out the user and navigate to the login screen
              authProvider.showSnackBar(context: context, content: getTranslation('signUpSuccess', _translations),color: Colors.green);

              authProvider.setIsLoading(value: false);

              // Navigate to the home screen
              navigateToHome();
            },
            onFail: (error) {
              // Show error snackbar
              authProvider.showSnackBar(context: context, content: error.toString(),color: Colors.red);
              // Pop the loading screen
              Navigator.pop(context);

              // Set loading state to false
              authProvider.setIsLoading(value: false);
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          authProvider.setIsLoading(value: false);
          Navigator.pop(context);
          // Handle the case where the user's email already exists
          authProvider.showSnackBar(context: context, content: getTranslation('emailAuth', _translations),color: Colors.red);

        } else {
          // Set loading state to false
          authProvider.setIsLoading(value: false);

          // Pop the loading screen
          Navigator.pop(context);
          // Handle other FirebaseAuthExceptions
          authProvider.showSnackBar(context: context, content: '${getTranslation('signUpAuth',_translations)} ${e.message}',color: Colors.red);
        }
      } catch (e) {
        // Set loading state to false
        authProvider.setIsLoading(value: false);

        // Pop the loading screen
        Navigator.pop(context);
        // Handle other exceptions
        authProvider.showSnackBar(context: context, content: '${getTranslation('signUpAuth',_translations)} $e',color: Colors.red);
      } finally {
        // Set loading state to false
        authProvider.setIsLoading(value: false);
      }
    } else {

      authProvider.showSnackBar(context: context, content: getTranslation('fillFields',_translations),color: Colors.red);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                  finalFileImage != null ?
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFf0f5f7),
                        backgroundImage: FileImage(File(finalFileImage!.path)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff4e3c96),
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
                              onPressed: (){
                                showImagePickerDialog();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ):
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
                            color: const Color(0xff4e3c96),
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
                              onPressed: (){
                                showImagePickerDialog();
                              },
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
                      textInputAction: TextInputAction.next,
                      maxLength: 25,
                      maxLines: 1,
                      style: TextStyle(color: oppColor),
                      textAlign: textAlignCheck,
                      textDirection: textDirectionCheck,
                      decoration: textFormDecoration.copyWith(
                        counterText: '',
                        labelText: getTranslation('yourName', _translations),
                        hintText: getTranslation('yourName', _translations),
                      ),
                      //TODO majd you need to replace the return and make it dynamically
                      validator: (value){
                        if(value!.isEmpty){
                          return getTranslation('nameValidator', _translations);
                        }
                        else if(value.length < 3){
                          return getTranslation('nameLenValidator', _translations);
                        }
                        return null;
                      },
                      onChanged: (value){
                        setState(() {
                          name = value.trim();

                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Directionality(
                    textDirection: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      style: TextStyle(color: oppColor),
                      textAlign: textAlignCheck,
                      textDirection: textDirectionCheck,
                      decoration: textFormDecoration.copyWith(
                        counterText: '',
                        labelText: getTranslation('yourEmail', _translations),
                        hintText: getTranslation('yourEmail', _translations),
                      ),
                      //TODO majd you need to replace the return and make it dynamically
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
                  const SizedBox(height: 20,),
                  Directionality(
                    textDirection: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      maxLength: 12,
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
                        else if(value.length < 8){
                          return getTranslation('passwordLenValidator', _translations);
                        }
                        return null;
                      },
                      onChanged: (value){
                        password = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Directionality(
                    textDirection: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      maxLength: 12,
                      maxLines: 1,
                      style: TextStyle(color: oppColor),
                      textAlign: textAlignCheck,
                      textDirection: textDirectionCheck,
                      decoration: textFormDecoration.copyWith(
                        counterText: '',
                        labelText: getTranslation('confirmPass', _translations),
                        hintText: getTranslation('confirmPass', _translations),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          icon: Icon(
                            obscureText ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                      obscureText: obscureText,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return getTranslation('passwordValidator', _translations);
                        } else if (value.length < 8) {
                          return getTranslation('passwordLenValidator', _translations);
                        } else if (value != password) {
                          return getTranslation('passwordMismatch', _translations);
                        }
                        return null;
                      },
                      onChanged: (value) {
                        confirmPassword = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 20,),

                  authProvider.isLoading ?  // Set the color to transparent to allow the animation to be full screen
                  Lottie.asset(
                      'assets/animations/signUpLoading.json',height: 100,width: 100,
                  )
                      :
                  MainAuthButton(
                      label: getTranslation('signup', _translations),
                      onPressed: (){
                        signUpUser();
                      },
                      fontSize: 20
                  ),

                  const SizedBox(height: 40,),
                  HaveAccountWidget(
                      label: getTranslation('gotAccount', _translations),
                      labelAction: getTranslation('sign_in', _translations),
                      onPressed: (){
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
