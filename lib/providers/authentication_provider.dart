import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return userCredential;
  }

}