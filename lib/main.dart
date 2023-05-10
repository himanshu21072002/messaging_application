
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'models/firebaseHelper.dart';

var uuid =Uuid();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  User? currentUser= FirebaseAuth.instance.currentUser;
  if(currentUser!=null){
    UserModel? thisUserModel = await  FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel!= null){
      runApp(LoggedInMyApp(userModel: thisUserModel, firebaseUser: currentUser));
    }
    else{
      runApp(const MyApp());
    }
  }
  else{
    runApp(const MyApp());
  }

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoggedInMyApp extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const LoggedInMyApp({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}

