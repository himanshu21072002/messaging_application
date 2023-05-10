import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const CompleteProfilePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();
  bool isLoading = false;

  void selectImage(ImageSource source) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      cropImage(pickedImage);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: file.path,compressQuality: 30);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotosOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                  ),
                  title: const Text('Take a photo'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(
                    Icons.photo,
                    color: Colors.purple,
                  ),
                  title: const Text('Select form Gallery'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      imageFile = null;
                    });
                  },
                  leading: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: const Text('Delete'),
                ),
              ],
            ),
          );
        });
  }

  void checkValues() {
    String fullName = fullNameController.text.trim();
    if (fullName == "" || imageFile == null) {
      log("Please fill all the details");
      Fluttertoast.showToast(
          gravity: ToastGravity.TOP,
          msg: "Please fill all the details",
          textColor: Colors.red);
    } else {
      uploadData();
    }
  }

  void uploadData() async {

    setState(() {
      isLoading = true;
    });

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullName = fullNameController.text.trim();
    widget.userModel.fullname = fullName;
    widget.userModel.profilepic = imageUrl;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage(userModel: widget.userModel,firebaseUser: widget.firebaseUser,)));
      log("Data uploaded");
    });
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
            appBar: AppBar(
              title: const Text('Complete Profile'),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    CupertinoButton(
                        child: CircleAvatar(
                          backgroundImage:
                              imageFile == null ? null : FileImage(imageFile!),
                          radius: 60,
                          child: imageFile == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                )
                              : null,
                        ),
                        onPressed: () {
                          showPhotosOptions();
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter Full Name',
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
                      child:isLoading?const CircularProgressIndicator(color: Colors.white):const Text('Submit'),
                    ),
                  ],
                )),
          ),
        ));
  }
}
