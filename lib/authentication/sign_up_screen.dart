import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../authentication/login_screen.dart';
import '../main_screens/home_screen.dart';
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
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
  late String phoneNumber;
  String _selectedPrefix = '050'; // Default initial value



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
    super.dispose();
  }

  // Function to handle language changes
  void _onLanguageChanged() {
    _loadTranslations(); // Reload translations when the language changes
  }

  // signUp user in fireStore
  void signUpUser() async {
    final authProvider = context.read<AuthenticationProvider>();

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (password != confirmPassword) {
        authProvider.showSnackBar(context: context, content: getTranslation('passwordMismatch', _translations), color: Colors.red);
        return;
      }

      try {
        authProvider.setIsLoading(value: true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoadingScreen()),
        );

        UserCredential? userCredential = await authProvider.createUserWithEmailAndPassword(
          email: email,
          password: password,
          phoneNumber: phoneNumber, // Pass the phone number
        );

        if (userCredential != null) {
          UserModel userModel = UserModel(
            uid: userCredential.user!.uid,
            name: name,
            email: email,
            image: '',
            createdAt: '',
            playerRating: 700,
            phoneNumber: phoneNumber, // Save the phone number
          );

          authProvider.saveUserDataToFireStore(
            currentUser: userModel,
            fileImage: finalFileImage,
            onSuccess: () async {
              formKey.currentState!.reset();
              await authProvider.saveUserDataToSharedPref();
              await authProvider.setSignedIn();
              authProvider.showSnackBar(context: context, content: getTranslation('signUpSuccess', _translations), color: Colors.green);
              authProvider.setIsLoading(value: false);
              navigateToHome();
            },
            onFail: (error) {
              authProvider.showSnackBar(context: context, content: error.toString(), color: Colors.red);
              Navigator.pop(context);
              authProvider.setIsLoading(value: false);
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        authProvider.setIsLoading(value: false);
        Navigator.pop(context);
        authProvider.showSnackBar(context: context, content: getTranslation('emailAuth', _translations), color: Colors.red);
      } catch (e) {
        authProvider.setIsLoading(value: false);
        Navigator.pop(context);
        authProvider.showSnackBar(context: context, content: '${getTranslation('signUpAuth', _translations)} $e', color: Colors.red);
      } finally {
        authProvider.setIsLoading(value: false);
      }
    } else {
      authProvider.showSnackBar(context: context, content: getTranslation('fillFields', _translations), color: Colors.red);
    }
  }

  bool isNumeric(String input) {
    final numericRegExp = RegExp(r'^[0-9]+$');
    return numericRegExp.hasMatch(input);
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
                    textDirection: TextDirection.ltr, // Always LTR for the overall Row direction
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: _selectedPrefix,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPrefix = newValue!;
                              phoneNumber = newValue; // Reset the phone number with the new prefix
                            });
                          },
                          items: <String>['050', '052', '053', '054', '058']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        Expanded(
                          child: Directionality(
                            textDirection: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              maxLength: 7, // Adjust as per your requirements
                              maxLines: 1,
                              style: TextStyle(color: oppColor),
                              textAlign: _themeLanguageProvider.currentLanguage == 'Arabic' ? TextAlign.right : TextAlign.left,
                              decoration: textFormDecoration.copyWith(
                                counterText: '',
                                labelText: getTranslation('enteryourphonenumber', _translations), // Translate this as needed
                                hintText: getTranslation('enteryourphonenumber', _translations), // Translate this as needed
                              ),
                              validator: (value) {
                                // Add validation logic as needed
                                if (value == null || value.isEmpty || value.length < 7 || !isNumeric(value)) {
                                  return getTranslation('invalidPhoneNumber', _translations); // Translate this as needed
                                }
                                return null;
                              },

                              onChanged: (value) {
                                setState(() {
                                  phoneNumber = _selectedPrefix + value;

                                });
                              },
                            ),
                          ),
                        ),
                      ],
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