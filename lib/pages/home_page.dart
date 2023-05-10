import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/firebaseHelper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/pages/chatRoomPage.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Chat'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const LoginPage()));
                },
                icon: const Icon(Icons.exit_to_app))
          ],
        ),
        body: Container(
            color: Colors.white,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .where("participants.${widget.userModel.uid}",
                        isEqualTo: true)

                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot =
                          snapshot.data as QuerySnapshot;
                      return ListView.builder(
                          itemCount: chatRoomSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                                chatRoomSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            Map<String, dynamic> participants =
                                chatRoomModel.participants!;
                            List<String> participantsKeys =
                                participants.keys.toList();
                            participantsKeys.remove(widget.userModel.uid);
                            return FutureBuilder(
                                future: FirebaseHelper.getUserModelById(
                                    participantsKeys[0]),
                                builder: (context, userData) {
                                  if (userData.connectionState ==
                                      ConnectionState.done) {
                                    if (userData.data != null) {
                                      UserModel targetUser =
                                          userData.data as UserModel;
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 1),
                                        color: Colors.grey[200],
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatRoomPage(
                                                            targetUser:
                                                                targetUser,
                                                            chatroom:
                                                                chatRoomModel,
                                                            userModel:
                                                                widget.userModel,
                                                            firebaseUser: widget
                                                                .firebaseUser)));
                                          },
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.grey[200],
                                            backgroundImage: NetworkImage(
                                                targetUser.profilepic.toString()),
                                          ),
                                          title: Text(
                                              targetUser.fullname.toString()),
                                          subtitle: chatRoomModel.lastMessage!=""?Text(chatRoomModel.lastMessage
                                              .toString()):const Text('Say hi to your new friend!',style: TextStyle(color: Colors.blueAccent),),
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  } else {
                                    return Container();
                                  }
                                });
                          });
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const Center(
                        child: Text('No text'),
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchPage(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser)));
          },
          child: const Icon(Icons.search),
        ),
      ),
    );
  }
}
