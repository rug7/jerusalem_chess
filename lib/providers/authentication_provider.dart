import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chess_1/constants.dart';
import 'package:flutter_chess_1/models/user_model.dart';

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

  void setIsSignedIn({required bool value}){
    _isSignedIn = value;
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

  Future<void> sighOutUser()async{
    await firebaseAuth.signOut();
  }

}

