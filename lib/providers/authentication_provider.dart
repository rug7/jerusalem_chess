import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chess_1/constants.dart';
import 'package:flutter_chess_1/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthenticationProvider extends ChangeNotifier{
  bool _isLoading = false;
  bool _isSignedIn = false;
  String? _uid;
  UserModel? _userModel;

  //getters
  bool get isLoading => _isLoading;
  bool get isSigned => _isSignedIn;

  UserModel? get userModel => _userModel;
  String? get uid => _uid;

  void setIsLoading({required bool value}){
    _isLoading = value;
    notifyListeners();
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  //create user with email and password

  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
})async{
    _isLoading = true;
    notifyListeners();
    UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    _uid = userCredential.user!.uid;
    notifyListeners();

    return userCredential;
  }
  //log in user with email and password
  Future<UserCredential?> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  })async{
    _isLoading = true;
    notifyListeners();
    UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    _uid = userCredential.user!.uid;
    notifyListeners();

    return userCredential;
  }

  //check if the user exists
  Future<bool> checkUserExists() async{
    DocumentSnapshot  documentSnapshot = await firebaseFirestore.collection(Constants.users).doc(uid).get();

    if(documentSnapshot.exists){
      return true;
    }else{
      return false;
    }
  }

  //get user data from firestore
  Future getUserDataFromFireStore() async {
    await firebaseFirestore
        .collection(Constants.users)
        .doc(firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot){
      _userModel = UserModel.fromMap(documentSnapshot.data() as Map<String,dynamic>);
      _uid = _userModel!.uid;
      notifyListeners();
    });
  }

  //store user data to shared preferences
  Future saveUserDataToSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        Constants.userModel,
        jsonEncode(userModel!.toMap()
        ));
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
    required Function (String) onFail,

  }) async{
    try{
      //check if the file image is not null
      if(fileImage != null){
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
      _isLoading =false;
      notifyListeners();

    }on FirebaseException catch (e){
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
        await firebaseFirestore
            .collection(Constants.users)
            .doc(uid)
            .update({'image': ''}); // Update 'image' field to empty string in Firestore

        // Update local userModel in AuthenticationProvider
        _userModel!.image = ''; // Assuming _userModel is already fetched
      } else {
        String imageUrl = await storeFileImageToStorage(
          reference: '${Constants.userImages}/$uid.png',
          file: fileImage,
        );

        // Update the user's image URL in Firestore
        await firebaseFirestore.collection(Constants.users).doc(uid).update({
          'image': imageUrl,
        });

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

  Future<void> signOutUser()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await firebaseAuth.signOut();
    _isSignedIn = false;
    sharedPreferences.clear();
    notifyListeners();
  }

  void showSnackBar({required BuildContext context, required String content,  Color? color}) {
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




}

