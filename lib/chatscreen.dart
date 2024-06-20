import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/pages/forward_to.dart';
import 'package:example/pages/friend_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chatview/chatview.dart';
import 'package:example/data.dart';
import 'package:example/models/theme.dart';
import 'dart:math';

import 'chat__.dart';
var _chatController;
var name,photo;
bool isselected=false;
get_random(){
  int randomNumber = 0;
  var random = Random();
  randomNumber = random.nextInt(1000000000); // Generates a random number between 0 and 99
  return randomNumber;
}
class ChatScreen extends StatefulWidget {
  var doc,user;
  ChatScreen(this.doc,this.user);

  @override
  State<ChatScreen> createState() => _chatState();
}

AppTheme theme = DarkTheme();
bool isDarkTheme = false;
var auth=FirebaseAuth.instance;
late Stream<List<Message>> _messageStream;
final currentUser = ChatUser(
  id: '${auth.currentUser?.uid}',
  name: '${auth.currentUser?.displayName}',
  profilePhoto: Data.profileImage,
);
bool isMessageExists(Message messageToFind, List<Message> messageList) {
  // Iterate through the list
  for (Message message in messageList) {
    // Compare each message with the message to find
    if (message.id == messageToFind.id &&
        message.message == messageToFind.message &&
        message.createdAt == messageToFind.createdAt &&
        message.sendBy == messageToFind.sendBy) {
      return true;
    }
  }
  return false;
}
Future<bool> doesDocumentExist(String documentPath) async {
  try {
    DocumentReference docRef = FirebaseFirestore.instance.doc(documentPath);
    DocumentSnapshot docSnapshot = await docRef.get();
    return docSnapshot.exists;
  } catch (e) {
    print('Error checking document existence: $e');
    return false; // Return false in case of error
  }
}
var check;
// late StreamController<List<Message>> _messageStreamController;
class _chatState extends State<ChatScreen> {
  @override
  Future<void> getCHECKFromDocument() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess")
        .doc(widget.user)
        .get();
    if (docSnapshot.exists) {
      // Access the data from the document
      var data = docSnapshot.data();
      if (data!.containsKey('firstmessage')) {
        check = data['firstmessage'];
      } else {
        print("Time field does not exist in the document.");
      }
    } else {
      print("Document does not exist.");
    }
  }
  Future<void> updateCHECKInDocument(var b) async {
    // Get a reference to the document
    var documentReference = FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess")
        .doc(widget.user);
    getCHECKFromDocument();
    await documentReference.update({'firstmessage':b});
    await getCHECKFromDocument();
  }
  Future<void> _getAccountDetails() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .doc(widget.doc)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          name = docSnapshot['name'] ?? 'No name';
          photo = docSnapshot['photo'] ?? 'No photo';
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }
  // void initState() {
  //   // print("//////${widget.doc}*************//////////${widget.user}");
  //   _messageStreamController = StreamController<List<Message>>();
  //   _messageStreamController.addStream(getMessageStream());
  //    _getAccountDetails();
  //    getCHECKFromDocument();
  //   print("start");
  //   super.initState();
  // }
  void initState() {
    super.initState();
     _chatController = ChatController(
      initialMessageList:messageList,
      scrollController: ScrollController(),
      chatUsers: [
        ChatUser(
          id: '${widget.user}',
          name:'${name}',
          profilePhoto: '${photo}',
        ),
      ],
    );
    _getAccountDetails();
    _initializeMessageStream();
    auth = FirebaseAuth.instance;
  }
  void _initializeMessageStream() {
    _messageStream = FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess")
        .doc(widget.user)
        .collection("chat")
        .orderBy('Time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Message(
        id: data['id'],
        message: data['text'],
        createdAt: data['Time'].toDate(),
        messageType: data['istext'] ? MessageType.text : MessageType.image,
        replyMessage: ReplyMessage(
          message: data['replyMessage'],
          messageType: MessageType.text,
          replyBy: data['sendby'],
          replyTo: widget.user,
          messageId: data['id'].toString(),
        ),
        sendBy: data['sendby'],
      );
    }).toList());
  }
  @override
  void dispose() {
    _messageStream.drain();
    _messageStream.drain<List<void>>();
    super.dispose();
  }
  // List<Message> messages=[];
  Stream<List<Message>> getMessageStream() async* {
    await for (var snapshot in FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess")
        .doc(widget.user)
        .collection("chat")
        .orderBy('Time', descending: false)
        .snapshots()) {

      List<Message> messages = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Message(
          id: data['id'],
          message: data['text'],
          createdAt: data['Time'].toDate(),
          messageType: data['istext'] ? MessageType.text : MessageType.image,
          replyMessage: ReplyMessage(
            message: data['replyMessage'],
            messageType: MessageType.text,
            replyBy: data['sendby'],
            replyTo: widget.user,
            messageId: data['id'].toString(),
          ),
          sendBy: data['sendby'],
        );
      }).toList();

      yield messages;
    }
  }

  AppTheme theme = LightTheme();
  bool isDarkTheme = false;

  final currentUser = ChatUser(
    id: '${auth.currentUser?.email}',
    name:'${auth.currentUser?.displayName}',
    profilePhoto: '${auth.currentUser?.photoURL}',
  );

  List<Message> messageList=[];
  List<Message> messageLength=[];
  List<Message> messagefl=[];
  // var message_length=0;

  @override
  Widget build(BuildContext context) {
    //  _chatController = ChatController(
    //   initialMessageList:messageList,
    //   scrollController: ScrollController(),
    //   chatUsers: [
    //     ChatUser(
    //       id: '${widget.user}',
    //       name:'${name}',
    //       profilePhoto: '${photo}',
    //     ),
    //   ],
    // );

    return Scaffold(
        body:StreamBuilder<List<Message>>(
            stream: _messageStream,
            builder: (context, snapshot){
              // getCHECKFromDocument();
                if (snapshot.connectionState == ConnectionState.waiting) {
                 return Center( child: CircularProgressIndicator(),);
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),);
                } else {
                  // getCHECKFromDocument();
                  if (snapshot.data!.length == 0) {
                    // print("//////$name *************//////////$photo");
                    getCHECKFromDocument();
                    messageList = snapshot.data!;
                    messagefl=messageList;
                    messageLength.isEmpty ? messageLength = messageList : null;
                    updateCHECKInDocument(true);
                    // print(name);
                    return ChatViewWidget(
                        currentUser: currentUser,
                        messageList: snapshot.data ?? [],
                        chatController: _chatController,
                        user: widget.user,name: name,photo: photo,
                    );
                  }else{
                  messageList = snapshot.data!;getCHECKFromDocument();
                  messageLength.isEmpty ? messageLength = messageList : null;
                  messageLength.toSet().toList();
                  _chatController.initialMessageList =messageLength.toSet().toList();
                  if (messageLength!= messageList) {
                    if (messageLength.isNotEmpty) {
                        for (final message in messageList) {
                          if (!isMessageExists(message, messageLength)) {
                            _chatController.addMessage(message);
                            messageLength = messageList;
                          }
                        }
                        print("don't Added");
                    }
                    print("not exisit");
                  }
                  else {
                    if(messageList.first==messageList.last){
                            if(check.toString()=='null'||check.toString()=='true'){
                              if(!isMessageExists(messageList.last, messageLength)){
                              _chatController.addMessage(
                              Message(
                                  id: "${messageList.last.id}",
                                  createdAt: DateTime.now(),
                                  message:messageList.last.message,
                                  // messageType: messageType?MessageType.text:MessageType.image,
                                  // replyMessage: messageList.last.replyMessage,
                                  sendBy: messageList.last.sendBy
                              ),);
                              _chatController.removeMessage(messageLength.last);
                              // messageLength=messageList;
                              updateCHECKInDocument(false);
                            print("message added2");
                          }else{
                                print("don't Added");
                              }
                       }else print("nenene");
                        print("message added3");
                    } else print("lists equall");}

                  return ChatViewWidget(
                    currentUser: currentUser,
                    messageList: snapshot.data ?? [],
                    chatController: _chatController,
                    user: widget.user,
                    getmessage: getMessageStream(),name: name,photo: photo,
                  );
                }
            }}
        )
    );
  }
}