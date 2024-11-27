// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:toastification/toastification.dart';

class FirebaseAuthService {
  Future<UserCredential> signInAnonymously() async {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    return userCredential;
  }

  Future<UserCredential> registerUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user!;
      user.sendEmailVerification();
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential> signInUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    //create new credentials for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    try {
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      ShowToasitification().showToast(
          context: context,
          toastificationType: ToastificationType.error,
          title: e.code);
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
