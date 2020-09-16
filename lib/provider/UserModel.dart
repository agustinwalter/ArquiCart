import 'package:arquicart/models/ArqUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserModel extends ChangeNotifier {
  ArqUser currentUser;

  Future<ArqUser> getCurrentUser() async {
    User fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      DocumentSnapshot userSnap =
          await FirebaseFirestore.instance.doc('users/${fbUser.uid}').get();
      if (userSnap.exists) {
        Map<String, dynamic> userData = userSnap.data();
        if (userData['category'] != null) {
          currentUser = ArqUser(
            uid: fbUser.uid,
            name: fbUser.displayName,
            email: fbUser.email,
            photo: fbUser.photoURL,
            category: userData['category'],
          );
          notifyListeners();
          return currentUser;
        }
      } else {
        print('object');
        await FirebaseFirestore.instance.doc('users/${fbUser.uid}').set({
          'email': fbUser.email,
          'photo': fbUser.photoURL,
        });
      }
      currentUser = ArqUser(
        uid: fbUser.uid,
        name: fbUser.displayName,
        email: fbUser.email,
        photo: fbUser.photoURL,
      );
      notifyListeners();
      return currentUser;
    }
    return null;
  }

  Future<ArqUser> signInWithGoogle() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User user = userCredential.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    currentUser = await getCurrentUser();
    return currentUser;
  }

  Future<void> setCategory(String category) async {
    await FirebaseFirestore.instance.doc('users/${currentUser.uid}').update({
      'category': category.toString(),
    });
    currentUser.category = category;
    notifyListeners();
    return;
  }

  Future<void> closeSession() async {
    await FirebaseAuth.instance.signOut();
    currentUser = null;
    notifyListeners();
    return;
  }
}
