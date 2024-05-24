import 'package:flutter_chess_1/constants.dart';
import 'package:flutter/material.dart';

class UserModel{
  String uid;
  String name;
  String email;
  String image;
  String createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.createdAt,
  });

  Map<String,dynamic> toMap(){
    return{
      Constants.uid : uid,
      Constants.name : name,
      Constants.email : email,
      Constants.image : image,
      Constants.createdAt : createdAt,
    };
  }

  factory UserModel.fromMap(Map<String,dynamic>data){
    return UserModel(
        uid: data[Constants.uid] ?? '',
        name: data[Constants.name] ?? '',
        email: data[Constants.email] ?? '',
        image: data[Constants.image] ?? '',
        createdAt: data[Constants.createdAt] ?? ''
    );
  }

}