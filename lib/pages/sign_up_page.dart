import 'dart:developer';

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/complete_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if (email == '' || password == '' || cPassword == '') {
      Fluttertoast.showToast(gravity: ToastGravity.TOP,msg: 'Please fill all the details' ,textColor: Colors.red);
      log('Please fill all the details');
    } else if (password != cPassword) {
      log("passwords do not match");
      Fluttertoast.showToast(gravity: ToastGravity.TOP,msg: 'passwords do not match' ,textColor: Colors.red);
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;

    try{
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex){
      Fluttertoast.showToast(gravity: ToastGravity.TOP,msg: ex.message.toString() ,textColor: Colors.red);
      log(ex.message.toString());
    }

    if(credential!=null){
      String uid =credential.user!.uid;
      UserModel newUser= UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",);
      await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toMap()).then((value){
        log("New User Created!!");
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return CompleteProfilePage(userModel: newUser, firebaseUser: credential!.user!) ;
        })) ;
      });
    }

   }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        "Chat App",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Email',
                          labelText: 'Email Address',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter Password',
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: cPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter Password',
                          labelText: 'Confirm Password',
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      CupertinoButton(
                        onPressed: () {
                          checkValues();
                        },
                        color: Colors.blueAccent,
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ),
              ),
            )),
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(fontSize: 16),
                ),
                CupertinoButton(
                    child: const Text(
                      'Sign in',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            ),
          ),
        ));
  }
}
