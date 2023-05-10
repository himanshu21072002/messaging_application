import 'dart:developer';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;
  const ChatRoomPage(
      {Key? key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "") {
      MessageModel newMessage = MessageModel(
          messageId: uuid.v1(),
          sender: widget.userModel.uid,
          createdOn: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());
      widget.chatroom.lastMessage=msg;
      // widget.chatroom.createdOn=DateTime.now();
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatRoomId)
          .set(widget.chatroom.toMap());
      log("message sent");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    NetworkImage(widget.targetUser.profilepic.toString()),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(widget.targetUser.fullname.toString()),
            ],
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                  child: Container(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(widget.chatroom.chatRoomId)
                        .collection("messages")
                        .orderBy("createdOn", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;
                          return ListView.builder(
                              reverse: true,
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                MessageModel currentMessage =
                                    MessageModel.fromMap(
                                        dataSnapshot.docs[index].data()
                                            as Map<String, dynamic>);
                                return Row(
                                  mainAxisAlignment: currentMessage.sender ==
                                          widget.userModel.uid
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 1),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: currentMessage.sender ==
                                                widget.userModel.uid
                                            ? Colors.blue
                                            : Colors.purple,
                                        borderRadius: currentMessage.sender ==
                                                widget.userModel.uid
                                            ? const BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(0),
                                                bottomRight:
                                                    Radius.circular(15),
                                                bottomLeft: Radius.circular(15))
                                            : const BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                topRight: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                                bottomLeft:
                                                    Radius.circular(10)),
                                      ),
                                      child: Text(
                                        currentMessage.text.toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                                "An error occurred! Please check your internet connection."),
                          );
                        } else {
                          return const Center(
                            child: Text(" Say hi to your new friend"),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              )),
              Container(
                color: Colors.grey[200],
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        maxLines: null,
                        controller: messageController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter message"),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
