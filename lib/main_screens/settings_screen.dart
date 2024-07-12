import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chess_1/providers/authentication_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import '../authentication/login_screen.dart';
import '../helper/helper_methods.dart';
import '../providers/theme_language_provider.dart';
import '../service/assests_manager.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool rememberLoginDetails = true;
  String profileImage = 'assets/profile_picture.png'; // Initial profile image path
  late ThemeLanguageProvider _themeLanguageProvider;
  Map<String, dynamic> translations = {};
  File? finalFileImage;

  void selectImage({required bool fromCamera}) async {
    try {
      finalFileImage = await pickImage(
        fromCamera: fromCamera,
        onFail: (e) {
          if (mounted) {
            showSnackBar(context: context, content: e.toString());
          }
        },
      );

      if (finalFileImage != null) {
        cropImage(finalFileImage!.path);
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  void cropImage(String path) async {
    try {
      final authProvider = context.read<AuthenticationProvider>();
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        maxHeight: 800,
        maxWidth: 800,
      );

      if (croppedFile != null) {
        finalFileImage = File(croppedFile.path);
        void _loadTranslations(String language) async {
          try {
            var translations = await loadTranslations(language);
            if (mounted) {
              setState(() {
                this.translations = translations;
              });
            }
          } catch (e) {
            print('Error loading translations: $e');
          }
        }

        setState(() {
          profileImage = finalFileImage!.path; // Update profile image optimistically
        });

        // Update user image
        authProvider.updateUserImage(
          uid: authProvider.userModel!.uid, // Replace with actual user ID
          fileImage: finalFileImage!,
          onSuccess: () {
            if (mounted) {
              authProvider.showSnackBar(context: context,
                  content: 'Profile image updated successfully.', color: Colors.green);
            }
          },
          onFail: (error) {
            if (mounted) {
              showSnackBar(context: context,
                  content: 'Failed to update profile image: $error');
            }
          },
        );
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error cropping image: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final textColor = _themeLanguageProvider.isLightMode ? Colors.black : Colors.white;
    final backgroundColor = _themeLanguageProvider.isLightMode ? Colors.white : const Color(0xFF121212);
    final userModel = context.watch<AuthenticationProvider>().userModel;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff4e3c96),
        title: Text(getTranslation('settings', translations),
            style: const TextStyle(color: Colors.white, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showProfileImageDialog(userModel?.image ?? '');
                  },
                  child: Stack(
                    children: [
                      ClipOval(
                        child: Image.network(
                          userModel?.image.isEmpty ?? true ? AssetsManager.userIcon : userModel!.image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage(AssetsManager.userIcon), // Fallback image
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            showOptionsDialog();
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt, color: textColor,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userModel!.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: Text(getTranslation('DarkMode', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
            value: !_themeLanguageProvider.isLightMode,
            onChanged: (bool value) {
              _themeLanguageProvider.toggleThemeMode();
            },
          ),
          SwitchListTile(
            title: Text(getTranslation('Remember Login Details', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
            value: rememberLoginDetails,
            onChanged: (bool value) {
              setState(() {
                rememberLoginDetails = value;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(getTranslation('helpSupport', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
            onTap: () {
              // Add help/support functionality
            },
          ),

          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(getTranslation('notifications', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
            onTap: () {
              // Add notifications settings functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(getTranslation('privacySecurity', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
            onTap: () {
              showPrivacySecurityDialog();
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(getTranslation('signOut', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
            onTap: () {
              context.read<AuthenticationProvider>()
                  .signOutUser()
                  .whenComplete(() {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              });
            },
          ),
        ],
      ),

    );
  }
  void showPrivacySecurityDialog() {
    final textColor = _themeLanguageProvider.isLightMode ? Colors.black : Colors.white;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslation('Privacy & Security', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.lock),
                title: Text('Change Password', style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
                onTap: () {
                  // Implement password change functionality
                  Navigator.pop(context); // Close the dialog after action
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: Text('Two-Factor Authentication', style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
                onTap: () {
                  // Implement two-factor authentication settings
                  Navigator.pop(context); // Close the dialog after action
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showProfileImageDialog(String imageUrl) {
    final defaultImage = AssetImage(AssetsManager.userIcon);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageUrl.isEmpty ? defaultImage : NetworkImage(imageUrl) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showOptionsDialog() async {
    final textColor = _themeLanguageProvider.isLightMode ? Colors.black : Colors.white;
    try {
      final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslation('Change Profile Picture', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(getTranslation('Take Photo', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(context, 'camera');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: Text(getTranslation('Choose from Gallery', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(context, 'gallery');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text(getTranslation('Delete Current Photo', translations), style: TextStyle(color: textColor, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(context, 'delete');
                  },
                ),
              ],
            ),
          );
        },
      );

      if (result == 'camera') {
        selectImage(fromCamera: true);
      } else if (result == 'gallery') {
        selectImage(fromCamera: false);
      } else if (result == 'delete') {
        deleteCurrentPhoto();
      }
    } catch (e) {
      print('Error showing options dialog: $e');
    }
  }

  void deleteCurrentPhoto() async {
    try {
      final authProvider = context.read<AuthenticationProvider>();
      final defaultImage = AssetsManager.userIcon; // Replace with your default image path

      // Update local state optimistically
      setState(() {
        profileImage = defaultImage; // Set to default image path after deletion
        finalFileImage = null;
      });

      // Update Firestore or backend
      authProvider.updateUserImage(
        uid: authProvider.userModel!.uid,
        fileImage: null, // Pass null to indicate deletion
        onSuccess: () {
          // Show success message if needed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile image deleted successfully.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onFail: (error) {
          // Handle failure to delete image
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update profile image: $error'),
                backgroundColor: Colors.red,
              ),
            );

            // Rollback state update on failure if necessary
            setState(() {
              profileImage = authProvider.userModel?.image ?? defaultImage;
            });
          }
        },
      );
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
