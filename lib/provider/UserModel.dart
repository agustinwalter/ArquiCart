import 'package:arquicart/models/User.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  User currentUser;
  
  Future<User> getCurrentUser(){
    return Future.delayed(const Duration(milliseconds: 500), () {
      currentUser = User(
        uid: 'some_uid',
        name: 'Agustín Walter',
        email: 'agus@gmail.com',
        category: Categories.Estudiante
      );
      notifyListeners();
      return currentUser;
    });
  }

  Future<User> signInWithGoogle(){
    return null;
  }

  Future<bool> updateCategory(Categories category){
    return null;
  }

  closeSession(){

  }
}