import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/Constant/colors.dart';
import 'package:example/chatscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatview/chatview.dart';
class forward_to extends StatefulWidget {
  forward_to({
    required this.message,
  });

  final Message message;

  @override
  State<forward_to> createState() => _ForwardToState();
}

class _ForwardToState extends State<forward_to> {
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> searchList = [];
  bool isSearch = false;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  void search(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      return;
    } else {
      searchList = _chats
          .where((user) =>
      user['name'] != null &&
          user['name'].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  Future<void> getUsers() async {
    try {
      String? userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("accounts")
            .doc(userEmail)
            .collection("mess")
            .get();

        List<Map<String, dynamic>> chats = [];
        for (var doc in querySnapshot.docs) {
          var nameSnapshot = await FirebaseFirestore.instance
              .collection("accounts")
              .doc(doc.id)
              .get();
          chats.add({
            'id': doc.id,
            'name': nameSnapshot.data()?['name'],
            'photo': nameSnapshot.data()?['photo'],
            'isselected': false
          });
        }

        setState(() {
          _chats = chats;
        });
      }
    } catch (e) {
      // Handle errors here
    }
  }

  List<String> selectedUsers() {
    return _chats
        .where((item) => item["isselected"] == true)
        .map((item) => item["id"] as String)
        .toList();
  }

  Future<void> forwardFunction(
      String message, ReplyMessage replyMessage, MessageType messageType, List<String> users) async {
    for (String userId in users) {
      await FirebaseFirestore.instance
          .collection("accounts")
          .doc(FirebaseAuth.instance.currentUser?.email)
          .collection("mess")
          .doc(userId)
          .collection("chat")
          .add({
        "id": get_random().toString(),
        "text": message,
        "replyMessage": replyMessage.message,
        "istext": messageType.isText,
        "sendby": FirebaseAuth.instance.currentUser?.email,
        "Time": DateTime.now()
      });
      await FirebaseFirestore.instance
          .collection("accounts")
          .doc(FirebaseAuth.instance.currentUser?.email)
          .collection("mess")
          .doc(FirebaseAuth.instance.currentUser?.email)
          .collection("chat")
          .add({
        "id": get_random().toString(),
        "text": message,
        "replyMessage": replyMessage.message,
        "istext": messageType.isText,
        "sendby": FirebaseAuth.instance.currentUser?.email,
        "Time": DateTime.now()
      }).then((value) => print("Message forwarded successfully"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 50,
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: 17, color: Colors.black),
                        ),
                      ),
                      const Text(
                        "Send to",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: selectedUsers().isEmpty
                            ? null
                            : () async {
                          await forwardFunction(
                            widget.message.message,
                            widget.message.replyMessage,
                            widget.message.messageType,
                            selectedUsers(),
                          );
                        },
                        child: Text(
                          "Forward",
                          style: TextStyle(
                            fontSize: 19,
                            color: selectedUsers().isEmpty
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: lightwhite,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    margin: EdgeInsets.all(10),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          isSearch = value.isNotEmpty;
                          search(value);
                        });
                      },
                      style: TextStyle(fontSize: 19),
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 30),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "RECENT CHATS",
                    style: TextStyle(color: theme.textFieldTextColor),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(7),
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: ListView.builder(
                  itemCount: isSearch ? searchList.length : _chats.length,
                  itemBuilder: (context, i) {
                    var chat = isSearch ? searchList[i] : _chats[i];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                chat['isselected'] = !chat['isselected'];
                              });
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(chat['photo']),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  chat['name'],
                                  style: TextStyle(fontSize: 20),
                                ),
                                Spacer(),
                                Container(
                                  decoration: ShapeDecoration(
                                    shape: CircleBorder(
                                      side: BorderSide(
                                        color: Colors.black,
                                        style: BorderStyle.solid,
                                        width: 1.3,
                                      ),
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: chat['isselected']
                                        ? Colors.green
                                        : Colors.white,
                                    child: chat['isselected']
                                        ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 3),
                              ],
                            ),
                          ),
                        ),
                        Divider(height: 3),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}