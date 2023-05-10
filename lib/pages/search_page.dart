import 'dart:async';
import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/chatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/chat_room_model.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatroom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatroom = existingChatRoom;
      log('Chatroom already exists');
    } else {
      // create a new one
      ChatRoomModel newChatRoom =
          ChatRoomModel(chatRoomId: uuid.v1(), lastMessage: "",participants: {
        widget.userModel.uid.toString(): true,
        targetUser.uid.toString(): true,
      });

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());
      chatroom = newChatRoom;
      log('new chatroom created');
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search"), centerTitle: true),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Email Address",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CupertinoButton(
                color: Colors.blue,
                onPressed: () {
                  setState(() {});
                },
                child: const Text('Search')),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: searchController.text)
                    .where('email', isNotEqualTo: widget.userModel.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      if (dataSnapshot.docs.isNotEmpty) {
                        Map<String, dynamic> userMap =
                            dataSnapshot.docs[0].data() as Map<String, dynamic>;
                        UserModel searchedUser = UserModel.fromMap(userMap);
                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatRoomModel =
                                await getChatRoomModel(searchedUser);
                            if (chatRoomModel != null) {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                            targetUser: searchedUser,
                                            userModel: widget.userModel,
                                            firebaseUser: widget.firebaseUser,
                                            chatroom: chatRoomModel,
                                          )));
                            }
                          },
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 22,
                            child: ClipOval(
                              child: Image.network(
                                searchedUser.profilepic.toString(),
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          title: Text(searchedUser.fullname!),
                          subtitle: Text(searchedUser.email!),
                        );
                      } else {
                        return const Text("No result found!");
                      }
                    } else if (snapshot.hasError) {
                      return const Text('An error occurred!');
                    } else {
                      return const Text("No result found!");
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          ],
        ),
      ),
    );
  }
}
