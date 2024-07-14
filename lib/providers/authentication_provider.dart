import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_1/constants.dart';
import 'package:flutter_chess_1/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSignedIn = false;
  String? _uid;
  UserModel? _userModel;

  //getters
  bool get isLoading => _isLoading;
  bool get isSigned => _isSignedIn;
  UserModel? get userModel => _userModel;
  String? get uid => _uid;

  void setIsLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;


  // Create user with email and password
  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String phoneNumber, // Add phone number parameter
  }) async {
    _isLoading = true;
    notifyListeners();
    UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    _uid = userCredential.user!.uid;

    // Store user data in Firestore
    await firebaseFirestore.collection(Constants.users).doc(_uid).set({
      'email': email,
      'phoneNumber': phoneNumber, // Store phone number in Firestore
      // other fields...
    });

    // Also store user data locally
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('user_email_$phoneNumber', email); // Store email with phone number as key

    notifyListeners();
    return userCredential;
  }



  //log in user with email and password
  Future<UserCredential?> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    _uid = userCredential.user!.uid;
    notifyListeners();

    return userCredential;
  }

  //check if the user exists
  Future<bool> checkUserExists() async {
    DocumentSnapshot documentSnapshot = await firebaseFirestore.collection(Constants.users).doc(uid).get();

    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkPhoneNumberMatch(String enteredPhoneNumber) async {
    try {
      User? currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        print('User not authenticated');
        return false;
      }

      DocumentSnapshot snapshot = await firebaseFirestore.collection('users').doc(currentUser.uid).get();
      if (!snapshot.exists) {
        print('User document does not exist in Firestore');
        return false;
      }

      String? phoneNumber = snapshot.get('phoneNumber'); // Adjust 'phoneNumber' according to your Firestore field name
      if (phoneNumber == null) {
        print('Phone number not found in user document');
        return false;
      }

      return phoneNumber == enteredPhoneNumber;
    } catch (e) {
      print('Error checking phone number match: $e');
      return false;
    }
  }

  //get user data from firestore
  Future getUserDataFromFireStore() async {
    await firebaseFirestore.collection(Constants.users).doc(firebaseAuth.currentUser!.uid).get().then((DocumentSnapshot documentSnapshot) {
      _userModel = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      _uid = _userModel!.uid;
      notifyListeners();
    });
  }

  //store user data to shared preferences
  Future saveUserDataToSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(Constants.userModel, jsonEncode(userModel!.toMap()));
  }

  //get user data to shared preferences
  Future getUserDataToSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String data = sharedPreferences.getString(Constants.userModel) ?? '';

    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  //set user as signed in
  Future setSignedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(Constants.isSignedIn, true);
    _isSignedIn = true;
    notifyListeners();
  }

  //set user as signed in
  Future<bool> checkIsSignedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _isSignedIn = sharedPreferences.getBool(Constants.isSignedIn) ?? false;
    notifyListeners();
    return _isSignedIn;
  }

  //save user data to firestore
  void saveUserDataToFireStore({
    required UserModel currentUser,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    try {
      //check if the file image is not null
      if (fileImage != null) {
        //upload the image to firestore storage
        String imageUrl = await storeFileImageToStorage(
          reference: '${Constants.userImages}/$uid.jpg',
          file: fileImage,
        );
        currentUser.image = imageUrl;
      }

      currentUser.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = currentUser;

      //save data to firestore
      await firebaseFirestore.collection(Constants.users).doc(uid).set(currentUser.toMap());

      onSuccess();
      _isLoading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  void updateUserImage({
    required String uid,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    try {
      if (fileImage == null) {
        // Handle deletion case, set profile image to an empty string in Firestore
        await firebaseFirestore.collection(Constants.users).doc(uid).update({'image': ''}); // Update 'image' field to empty string in Firestore

        // Update local userModel in AuthenticationProvider
        _userModel!.image = ''; // Assuming _userModel is already fetched
      } else {
        String imageUrl = await storeFileImageToStorage(
          reference: '${Constants.userImages}/$uid.png',
          file: fileImage,
        );

        // Update the user's image URL in Firestore
        await firebaseFirestore.collection(Constants.users).doc(uid).update({'image': imageUrl});

        // Update local userModel in AuthenticationProvider
        _userModel!.image = imageUrl; // Assuming _userModel is already fetched
      }

      onSuccess();
      notifyListeners(); // Notify listeners of the change
    } catch (e) {
      onFail(e.toString());
    }
  }

  //store image to storage and return the download url
  Future<String> storeFileImageToStorage({
    required String reference,
    required File file,
  }) async {
    UploadTask uploadTask = firebaseStorage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> signOutUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await firebaseAuth.signOut();
    _isSignedIn = false;
    sharedPreferences.clear();
    notifyListeners();
  }

  void showSnackBar({required BuildContext context, required String content, Color? color}) {
    final snackBar = SnackBar(
      content: Text(content),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool> checkIfSignedIn() async {
    User? user = firebaseAuth.currentUser;
    return user != null;
  }



  Future<UserCredential?> signInWithPhoneNumberAndPassword({
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Sign in the user anonymously to ensure authentication
      await firebaseAuth.signInAnonymously();

      // Perform Firestore query to get the user's email by phone number
      QuerySnapshot querySnapshot = await firebaseFirestore
          .collection(Constants.users)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Assuming phone numbers are unique, get the first matching document
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      String email = userDoc.get('email');

      // Sign in using the email associated with the phone number
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _uid = userCredential.user!.uid;
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error: $e');
      return null;
    }
  }




  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      //showSnackBar(context: context, content: 'Password reset email sent.', color: Colors.green);
    } catch (e) {
      //showSnackBar(context: context, content: 'Error: $e', color: Colors.red);
    }
  }

  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      final user = firebaseAuth.currentUser;
      final email = user?.email;

      if (email == null) return false;

      // Reauthenticate user
      final credential = EmailAuthProvider.credential(email: email, password: oldPassword);
      await user?.reauthenticateWithCredential(credential);

      // Update password
      await user?.updatePassword(newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> changeName({required String newName}) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return;

      await firebaseFirestore.collection(Constants.users).doc(user.uid).update({'name': newName});

      // Update local user model
      _userModel?.name = newName;
      notifyListeners();
    } catch (e) {
      print('Failed to update name: $e');
    }
  }
}
