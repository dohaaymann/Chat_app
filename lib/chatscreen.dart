import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/pages/forward_to.dart';
import 'package:example/pages/friend_profile.dart';
import 'package:example/widgets/ChatWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chatview/chatview.dart';
import 'package:example/data.dart';
import 'package:example/models/theme.dart';
import 'package:get/get.dart';
import 'dart:math';

import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import 'models/SettingsProvider.dart';
import 'notification.dart';
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
  var name,email,bio,photo,token;
  ChatScreen(this.name,this.email,this.bio,this.photo,this.token);

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
    if (docSnapshot.exists) {
      return docSnapshot.exists;
    }
    else {
      return false;
    }

  } catch (e) {
    print('Error checking document existence: $e');
    return false; // Return false in case of error
  }
}
var check,Isblocked;
// late StreamController<List<Message>> _messageStreamController;
class _chatState extends State<ChatScreen> {
  @override
  Future<void> getCHECKFromDocument() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess")
        .doc(widget.email)
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
    var documentReference = FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess")
        .doc(widget.email);

    // Check if the document exists
    var docSnapshot = await documentReference.get();
    if (docSnapshot.exists) {
      return;
    } else {
      return ;
    }
    await getCHECKFromDocument();
  }
  MediaQueryData? mediaQueryData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mediaQueryData = MediaQuery.maybeOf(context);
  }
    void initState() {
    super.initState();
    _chatController = ChatController(
      initialMessageList:messageList,
      scrollController: ScrollController(),
      chatUsers: [
        ChatUser(
          id: '${widget.email}',
          name:'${widget.name}',
          profilePhoto: '${widget.photo}',
        ),
      ],
    );

    // _getmyAccountDetails();
    _initializeMessageStream();
    auth = FirebaseAuth.instance;
  }
  void _initializeMessageStream() {
    _messageStream = FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess")
        .doc(widget.email)
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
          replyTo: widget.email,
          messageId: data['id'].toString(),
        ),
        sendBy: data['sendby'],
      );
    }).toList());
  }
  @override
  void dispose() {
    _messageStream.drain();
    // _messageStream.drain();
    if (mediaQueryData != null) {
      // Perform actions that need the MediaQueryData reference
    }
    super.dispose();
  }
  // List<Message> messages=[];
  Stream<List<Message>> getMessageStream() async* {
    await for (var snapshot in FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess")
        .doc(widget.email)
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
            replyTo: widget.email,
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  _onSendTap(
      String message,
      ReplyMessage replyMessage,
      MessageType messageType,
      )async{
    // print("/////////////${replyMessage}");
    var r=get_random().toString();
    String documentPath = 'accounts/${auth.currentUser?.email}/mess/${widget.email}';
    bool exists = await doesDocumentExist(documentPath);
    String documentPath2 = 'accounts/${widget.email}/mess/${auth.currentUser?.email}';
    bool exists2 = await doesDocumentExist(documentPath2);
    !exists?await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.email).set({"time": DateTime.now(),"firstmessage":true,"isblocked":false}):
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.email).update({"time": DateTime.now()});
    !exists2?await FirebaseFirestore.instance.collection("accounts").doc("${widget.email}").collection("mess").doc("${auth.currentUser?.email}").set({"time": DateTime.now(),"firstmessage":true,"isblocked":false}):
    await FirebaseFirestore.instance.collection("accounts").doc("${widget.email}").collection("mess").doc("${auth.currentUser?.email}").update({"time": DateTime.now()});
    // print('Document exists: $exists');
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.email).collection("chat")
        .add({
      "id": r,
      "text": "${message}",
      "replyMessage":replyMessage.message,
      "istext": messageType.isText,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {print("doneeeeee");});
    await FirebaseFirestore.instance.collection("accounts").doc(widget.email).collection("mess").doc("${auth.currentUser?.email}").collection("chat")
        .add({
      "id": r,
      "text": "${message}",
      "replyMessage":replyMessage.message,
      "istext": messageType.isText,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {
      var notify=Notification_();
      print("doneeeeee${DateTime.now()}");
      notify.sendPushNotification(
          "${widget.token}"
          ,"${widget.name}",
          "${message}");
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
      body:Consumer<SettingsProvider>(builder: (context, provide, child){
      var theme = provide.isDarkTheme ? DarkTheme() : LightTheme();
          return StreamBuilder<List<Message>>(
              stream: _messageStream,
              builder: (context, snapshot){
                // getCHECKFromDocument();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center( child: CircularProgressIndicator(),);
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),);
                } else {
                  if (snapshot.data!.isEmpty) {
                    // Handle first message scenario
                    print("//////emptyyyy first message");
                    // getCHECKFromDocument();
                    messageList = snapshot.data!;
                    messagefl = messageList;

                    print("Snapshot data is empty: ${snapshot.data!.isEmpty}");
                    print("Message length is empty: ${messageLength.isEmpty}");

                    if (messageLength.isEmpty) {
                      messageLength = snapshot.data!;
                    }

                    // updateCHECKInDocument(true);

                    print("Snapshot data is empty: ${snapshot.data!.isEmpty}");
                    print("Message length is empty: ${messageLength.isEmpty}");

                    return Chat_Widget(currentUser,snapshot.data ?? [], _chatController,widget.email,getMessageStream(),widget.name,widget.photo,widget.bio,widget.token);
                  } else {
                    // Handle subsequent messages
                    messageList = snapshot.data!;
                    // getCHECKFromDocument();

                    // Initialize messageLength if it's empty
                    if (messageLength.isEmpty && snapshot.data!.isNotEmpty) {
                      messageLength = snapshot.data!;
                    }

                    // Ensure uniqueness in messageList and initialMessageList
                    messageList = messageList.toSet().toList();
                    _chatController.initialMessageList = messageList;

                    // Check and print the last messages
                    if (messageLength.isNotEmpty) {
                      print("Last message from snapshot: ${snapshot.data!.last.message}");
                      print("Last message from messageLength: ${messageLength.last.message}");
                    }

                    // Check if new messages have been received
                    if (messageLength.length != snapshot.data!.length) {
                      print("New messages received");
                      Set<String> existingMessageIds = messageLength.map((m) => m.id).toSet();
                      for (final message in snapshot.data!) {
                        if (!existingMessageIds.contains(message.id)) {
                          print("Adding new message: ${message.message}");
                          _chatController.addMessage(message);
                          messageLength.add(message); // Add to messageLength list
                        }
                      }
                      messageLength = snapshot.data!;
                      print("Messages added");
                    }
                    else {
                      if(snapshot.data!.first==snapshot.data!.last){
                        print(snapshot.data!.last.message);
                        print(messageLength.last.message);
                        if(check.toString()=='null'||check.toString()=='true'){
                          // if(!isMessageExists(snapshot.data!.last, messageLength)){
                          messageLength.toSet().toList();
                            _chatController.addMessage(
                              Message(
                                  id: "${messageList.last.id}",
                                  createdAt: DateTime.now(),
                                  message:messageList.last.message,
                                  messageType: messageList.last.messageType,
                                  replyMessage: messageList.last.replyMessage,
                                  sendBy: messageList.last.sendBy
                              ),);
                            _chatController.removeMessage(messageLength.last);
                            // messageLength=messageList;
                            // updateCHECKInDocument(false);
                            print("message added2");
                        }else print("nenen");
                        print("message added3");
                      } else print("lists equall");}
                    // return  Chat_Widget(currentUser, snapshot.data ?? [], _chatController, widget.email, getMessageStream(), widget.name,widget.photo,widget.bio,widget.token);
                  return ChatView(
                    // key: UniqueKey(),
                    currentUser: currentUser,
                    isBlocked: provide.block,
                    loadingWidget: CircularProgressIndicator(color: Colors.red,),
                    chatController: _chatController,
                    onSendTap: _onSendTap,
                    chatViewState: ChatViewState.hasMessages,
                    chatViewStateConfig: ChatViewStateConfiguration(
                      loadingWidgetConfig: ChatViewStateWidgetConfiguration(
                        loadingIndicatorColor: theme.outgoingChatBubbleColor,
                      ),
                      onReloadButtonTap: () {},
                    ),
                    typeIndicatorConfig: TypeIndicatorConfiguration(
                      flashingCircleBrightColor: theme.flashingCircleBrightColor,
                      flashingCircleDarkColor: theme.flashingCircleDarkColor,
                    ),
                    appBar: ChatViewAppBar(
                      frienfprofile: () {
                        Get.to(() => friend_profile(widget.name, widget.email, widget.bio, widget.photo, provide.isblock));
                      },
                      elevation: theme.elevation,
                      backGroundColor: theme.appBarColor,
                      profilePicture: widget.photo,
                      backArrowColor: theme.backArrowColor,
                      chatTitle: "${widget.name}",
                      chatTitleTextStyle: TextStyle(
                        color: theme.appBarTitleTextStyle,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.25,
                      ),
                      userStatusTextStyle: const TextStyle(color: Colors.grey),
                      actions: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.call, color: theme.themeIconColor, size: 30),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    chatBackgroundConfig: ChatBackgroundConfiguration(
                      messageTimeIconColor: theme.messageTimeIconColor,
                      messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
                      defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
                        textStyle: TextStyle(
                          color: theme.chatHeaderColor,
                          fontSize: 17,
                        ),
                      ),
                      backgroundColor: theme.backgroundColor,
                    ),
                    sendMessageConfig: SendMessageConfiguration(
                      imagePickerIconsConfig: ImagePickerIconsConfiguration(
                        cameraIconColor: theme.cameraIconColor,
                        galleryIconColor: theme.galleryIconColor,
                      ),
                      replyMessageColor: theme.replyMessageColor,
                      defaultSendButtonColor: theme.sendButtonColor,
                      replyDialogColor: theme.replyDialogColor,
                      replyTitleColor: theme.replyTitleColor,
                      textFieldBackgroundColor: theme.textFieldBackgroundColor,
                      closeIconColor: theme.closeIconColor,
                      textFieldConfig: TextFieldConfiguration(
                        onMessageTyping: (status) {
                          debugPrint(status.toString());
                        },
                        compositionThresholdTime: const Duration(seconds: 1),
                        textStyle: TextStyle(color: theme.textFieldTextColor),
                      ),
                      micIconColor: theme.replyMicIconColor,
                      voiceRecordingConfiguration: VoiceRecordingConfiguration(
                        backgroundColor: theme.waveformBackgroundColor,
                        recorderIconColor: theme.recordIconColor,
                        waveStyle: WaveStyle(
                          showMiddleLine: false,
                          waveColor: theme.waveColor ?? Colors.white,
                          extendWaveform: true,
                        ),
                      ),
                    ),
                    chatBubbleConfig: ChatBubbleConfiguration(
                      outgoingChatBubbleConfig: ChatBubble(
                        linkPreviewConfig: LinkPreviewConfiguration(
                          backgroundColor: theme.linkPreviewOutgoingChatColor,
                          bodyStyle: theme.outgoingChatLinkBodyStyle,
                          titleStyle: theme.outgoingChatLinkTitleStyle,
                        ),
                        receiptsWidgetConfig: const ReceiptsWidgetConfig(
                          showReceiptsIn: ShowReceiptsIn.all,
                        ),
                        color: theme.outgoingChatBubbleColor,
                      ),
                      inComingChatBubbleConfig: ChatBubble(
                        linkPreviewConfig: LinkPreviewConfiguration(
                          linkStyle: TextStyle(
                            color: theme.inComingChatBubbleTextColor,
                            decoration: TextDecoration.underline,
                          ),
                          backgroundColor: theme.linkPreviewIncomingChatColor,
                          bodyStyle: theme.incomingChatLinkBodyStyle,
                          titleStyle: theme.incomingChatLinkTitleStyle,
                        ),
                        textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                        onMessageRead: (message) async {},
                        senderNameTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                        color: theme.inComingChatBubbleColor,
                      ),
                    ),
                    replyPopupConfig: ReplyPopupConfiguration(
                      onMoreTap: (message) {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return forward_to(message: message);
                          },
                          isScrollControlled: true,
                        );
                      },
                      DeleteTap: (message) async {
                        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                            .collection("accounts")
                            .doc("${auth.currentUser?.email}")
                            .collection("mess")
                            .doc(widget.email)
                            .collection("chat")
                            .where('id', isEqualTo: '${message.id}')
                            .get();

                        for (QueryDocumentSnapshot document in querySnapshot.docs) {
                          await document.reference.delete();
                        }
                        print("Documents have been deleted.");
                        print(message.id);
                        _chatController.removeMessage(message);
                      },
                      onUnsendTap: (Message) async {
                        print(Message.id);

                        await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.email).collection("chat");
                        showDialog(context: context, builder: (context) {
                          return AlertDialog(
                            shape: const UnderlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            title: const Text(
                              "Delete Message?",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            actions: [
                              Column(
                                children: [
                                  Text(
                                    "This message will be deleted for you and other people",
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(padding: EdgeInsetsDirectional.all(5)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        margin: EdgeInsetsDirectional.only(top: 10, end: 5),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Cancel",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsetsDirectional.only(top: 10, end: 5),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            _chatController.removeMessage(Message);
                                            Navigator.of(context).pop();
                                            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                .collection("accounts")
                                                .doc("${auth.currentUser?.email}")
                                                .collection("mess")
                                                .doc(widget.email)
                                                .collection("chat")
                                                .where('id', isEqualTo: '${Message.id}')
                                                .get();
                                            QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
                                                .collection("accounts")
                                                .doc(widget.email)
                                                .collection("mess")
                                                .doc("${auth.currentUser?.email}")
                                                .collection("chat")
                                                .where('id', isEqualTo: '${Message.id}')
                                                .get();

                                            for (QueryDocumentSnapshot document in querySnapshot.docs) {
                                              await document.reference.delete();
                                            }
                                            for (QueryDocumentSnapshot document in querySnapshot2.docs) {
                                              await document.reference.delete();
                                            }

                                            QuerySnapshot remainingMessagesCurrentUser = await FirebaseFirestore.instance
                                                .collection("accounts")
                                                .doc("${auth.currentUser?.email}")
                                                .collection("mess")
                                                .doc(widget.email)
                                                .collection("chat")
                                                .get();

                                            if (remainingMessagesCurrentUser.docs.isEmpty) {
                                              await FirebaseFirestore.instance
                                                  .collection("accounts")
                                                  .doc("${auth.currentUser?.email}")
                                                  .collection("mess")
                                                  .doc(widget.email)
                                                  .delete();
                                            }

                                            // Check if the other user's subcollection is empty and delete the parent document if it is
                                            QuerySnapshot remainingMessagesOtherUser = await FirebaseFirestore.instance
                                                .collection("accounts")
                                                .doc(widget.email)
                                                .collection("mess")
                                                .doc("${auth.currentUser?.email}")
                                                .collection("chat")
                                                .get();

                                            if (remainingMessagesOtherUser.docs.isEmpty) {
                                              await FirebaseFirestore.instance
                                                  .collection("accounts")
                                                  .doc(widget.email)
                                                  .collection("mess")
                                                  .doc("${auth.currentUser?.email}")
                                                  .delete();
                                            }
                                          },
                                          child: Text(
                                            "Delete",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        });
                      },
                      backgroundColor: theme.replyPopupColor,
                      buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
                      topBorderColor: theme.replyPopupTopBorderColor,
                    ),
                    messageConfig: MessageConfiguration(
                      imageMessageConfig: ImageMessageConfiguration(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shareIconConfig: ShareIconConfiguration(onPressed: (message) {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return forward_to(message: message);
                            },
                            isScrollControlled: true,
                          );
                        }),
                      ),
                    ),
                    profileCircleConfig: const ProfileCircleConfiguration(
                      profileImageUrl: "",
                    ),
                    repliedMessageConfig: RepliedMessageConfiguration(
                      backgroundColor: theme.repliedMessageColor,
                      verticalBarColor: theme.verticalBarColor,
                      repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
                        enableHighlightRepliedMsg: true,
                        highlightColor: Colors.pinkAccent.shade100,
                        highlightScale: 1.1,
                      ),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.25,
                      ),
                      replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
                    ),
                    swipeToReplyConfig: SwipeToReplyConfiguration(
                      replyIconColor: theme.swipeToReplyIconColor,
                    ),
                  );
                  }
                }}
          );
        }
      )
  );
  }
}
 Chat_Widget(var currentUser, var messageList, var chatController,  var user,var getmessage, var name, var photo,var bio,var token) {

  // var sql=SQLDB();
  return Consumer<SettingsProvider>(builder: (context, provide, child){
    var theme = provide.isDarkTheme ? DarkTheme() : LightTheme();
    // return ChatView(
    //   // key: UniqueKey(),
    //   // key: UniqueKey(),
    //   currentUser: currentUser,
    //   isBlocked: provide.block,
    //   loadingWidget: CircularProgressIndicator(color: Colors.red,),
    //   chatController: chatController,
    //   onSendTap: _onSendTap,
    //   chatViewState: ChatViewState.hasMessages,
    //   chatViewStateConfig: ChatViewStateConfiguration(
    //     loadingWidgetConfig: ChatViewStateWidgetConfiguration(
    //       loadingIndicatorColor: theme.outgoingChatBubbleColor,
    //     ),
    //     onReloadButtonTap: () {},
    //   ),
    //   typeIndicatorConfig: TypeIndicatorConfiguration(
    //     flashingCircleBrightColor: theme.flashingCircleBrightColor,
    //     flashingCircleDarkColor: theme.flashingCircleDarkColor,
    //   ),
    //   appBar: ChatViewAppBar(
    //     frienfprofile: () {
    //       Get.to(() => friend_profile(name, user, bio, photo, provide.isblock));
    //     },
    //     elevation: theme.elevation,
    //     backGroundColor: theme.appBarColor,
    //     profilePicture: photo,
    //     backArrowColor: theme.backArrowColor,
    //     chatTitle: "$name",
    //     chatTitleTextStyle: TextStyle(
    //       color: theme.appBarTitleTextStyle,
    //       fontWeight: FontWeight.bold,
    //       fontSize: 18,
    //       letterSpacing: 0.25,
    //     ),
    //     userStatusTextStyle: const TextStyle(color: Colors.grey),
    //     actions: [
    //       IconButton(
    //         onPressed: () {},
    //         icon: Icon(Icons.call, color: theme.themeIconColor, size: 30),
    //       ),
    //       SizedBox(width: 10),
    //     ],
    //   ),
    //   chatBackgroundConfig: ChatBackgroundConfiguration(
    //     messageTimeIconColor: theme.messageTimeIconColor,
    //     messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
    //     defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
    //       textStyle: TextStyle(
    //         color: theme.chatHeaderColor,
    //         fontSize: 17,
    //       ),
    //     ),
    //     backgroundColor: theme.backgroundColor,
    //   ),
    //   sendMessageConfig: SendMessageConfiguration(
    //     imagePickerIconsConfig: ImagePickerIconsConfiguration(
    //       cameraIconColor: theme.cameraIconColor,
    //       galleryIconColor: theme.galleryIconColor,
    //     ),
    //     replyMessageColor: theme.replyMessageColor,
    //     defaultSendButtonColor: theme.sendButtonColor,
    //     replyDialogColor: theme.replyDialogColor,
    //     replyTitleColor: theme.replyTitleColor,
    //     textFieldBackgroundColor: theme.textFieldBackgroundColor,
    //     closeIconColor: theme.closeIconColor,
    //     textFieldConfig: TextFieldConfiguration(
    //       onMessageTyping: (status) {
    //         debugPrint(status.toString());
    //       },
    //       compositionThresholdTime: const Duration(seconds: 1),
    //       textStyle: TextStyle(color: theme.textFieldTextColor),
    //     ),
    //     micIconColor: theme.replyMicIconColor,
    //     voiceRecordingConfiguration: VoiceRecordingConfiguration(
    //       backgroundColor: theme.waveformBackgroundColor,
    //       recorderIconColor: theme.recordIconColor,
    //       waveStyle: WaveStyle(
    //         showMiddleLine: false,
    //         waveColor: theme.waveColor ?? Colors.white,
    //         extendWaveform: true,
    //       ),
    //     ),
    //   ),
    //   chatBubbleConfig: ChatBubbleConfiguration(
    //     outgoingChatBubbleConfig: ChatBubble(
    //       linkPreviewConfig: LinkPreviewConfiguration(
    //         backgroundColor: theme.linkPreviewOutgoingChatColor,
    //         bodyStyle: theme.outgoingChatLinkBodyStyle,
    //         titleStyle: theme.outgoingChatLinkTitleStyle,
    //       ),
    //       receiptsWidgetConfig: const ReceiptsWidgetConfig(
    //         showReceiptsIn: ShowReceiptsIn.all,
    //       ),
    //       color: theme.outgoingChatBubbleColor,
    //     ),
    //     inComingChatBubbleConfig: ChatBubble(
    //       linkPreviewConfig: LinkPreviewConfiguration(
    //         linkStyle: TextStyle(
    //           color: theme.inComingChatBubbleTextColor,
    //           decoration: TextDecoration.underline,
    //         ),
    //         backgroundColor: theme.linkPreviewIncomingChatColor,
    //         bodyStyle: theme.incomingChatLinkBodyStyle,
    //         titleStyle: theme.incomingChatLinkTitleStyle,
    //       ),
    //       textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
    //       onMessageRead: (message) async {},
    //       senderNameTextStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
    //       color: theme.inComingChatBubbleColor,
    //     ),
    //   ),
    //   replyPopupConfig: ReplyPopupConfiguration(
    //     onMoreTap: (message) {
    //       showModalBottomSheet(
    //         context: context,
    //         builder: (BuildContext context) {
    //           return forward_to(message: message);
    //         },
    //         isScrollControlled: true,
    //       );
    //     },
    //     DeleteTap: (message) async {
    //       final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //           .collection("accounts")
    //           .doc("${auth.currentUser?.email}")
    //           .collection("mess")
    //           .doc(user)
    //           .collection("chat")
    //           .where('id', isEqualTo: '${message.id}')
    //           .get();
    //
    //       for (QueryDocumentSnapshot document in querySnapshot.docs) {
    //         await document.reference.delete();
    //       }
    //       print("Documents have been deleted.");
    //       print(message.id);
    //       chatController.removeMessage(message);
    //     },
    //     onUnsendTap: (Message) async {
    //       print(Message.id);
    //
    //       await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(user).collection("chat");
    //       showDialog(context: context, builder: (context) {
    //         return AlertDialog(
    //           shape: const UnderlineInputBorder(
    //             borderRadius: BorderRadius.all(Radius.circular(10)),
    //           ),
    //           title: const Text(
    //             "Delete Message?",
    //             textAlign: TextAlign.center,
    //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //           ),
    //           actions: [
    //             Column(
    //               children: [
    //                 Text(
    //                   "This message will be deleted for you and other people",
    //                   style: TextStyle(fontSize: 18),
    //                   textAlign: TextAlign.center,
    //                 ),
    //                 Padding(padding: EdgeInsetsDirectional.all(5)),
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                   children: [
    //                     Container(
    //                       margin: EdgeInsetsDirectional.only(top: 10, end: 5),
    //                       child: ElevatedButton(
    //                         onPressed: () {
    //                           Navigator.pop(context);
    //                         },
    //                         child: Text(
    //                           "Cancel",
    //                           textAlign: TextAlign.center,
    //                           style: TextStyle(fontSize: 20),
    //                         ),
    //                       ),
    //                     ),
    //                     Container(
    //                       margin: EdgeInsetsDirectional.only(top: 10, end: 5),
    //                       child: ElevatedButton(
    //                         onPressed: () async {
    //                           chatController.removeMessage(Message);
    //                           Navigator.of(context).pop();
    //                           QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //                               .collection("accounts")
    //                               .doc("${auth.currentUser?.email}")
    //                               .collection("mess")
    //                               .doc(user)
    //                               .collection("chat")
    //                               .where('id', isEqualTo: '${Message.id}')
    //                               .get();
    //                           QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
    //                               .collection("accounts")
    //                               .doc(user)
    //                               .collection("mess")
    //                               .doc("${auth.currentUser?.email}")
    //                               .collection("chat")
    //                               .where('id', isEqualTo: '${Message.id}')
    //                               .get();
    //
    //                           for (QueryDocumentSnapshot document in querySnapshot.docs) {
    //                             await document.reference.delete();
    //                           }
    //                           for (QueryDocumentSnapshot document in querySnapshot2.docs) {
    //                             await document.reference.delete();
    //                           }
    //
    //                           QuerySnapshot remainingMessagesCurrentUser = await FirebaseFirestore.instance
    //                               .collection("accounts")
    //                               .doc("${auth.currentUser?.email}")
    //                               .collection("mess")
    //                               .doc(user)
    //                               .collection("chat")
    //                               .get();
    //
    //                           if (remainingMessagesCurrentUser.docs.isEmpty) {
    //                             await FirebaseFirestore.instance
    //                                 .collection("accounts")
    //                                 .doc("${auth.currentUser?.email}")
    //                                 .collection("mess")
    //                                 .doc(user)
    //                                 .delete();
    //                           }
    //
    //                           // Check if the other user's subcollection is empty and delete the parent document if it is
    //                           QuerySnapshot remainingMessagesOtherUser = await FirebaseFirestore.instance
    //                               .collection("accounts")
    //                               .doc(user)
    //                               .collection("mess")
    //                               .doc("${auth.currentUser?.email}")
    //                               .collection("chat")
    //                               .get();
    //
    //                           if (remainingMessagesOtherUser.docs.isEmpty) {
    //                             await FirebaseFirestore.instance
    //                                 .collection("accounts")
    //                                 .doc(user)
    //                                 .collection("mess")
    //                                 .doc("${auth.currentUser?.email}")
    //                                 .delete();
    //                           }
    //                         },
    //                         child: Text(
    //                           "Delete",
    //                           textAlign: TextAlign.center,
    //                           style: TextStyle(fontSize: 20),
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ],
    //         );
    //       });
    //     },
    //     backgroundColor: theme.replyPopupColor,
    //     buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
    //     topBorderColor: theme.replyPopupTopBorderColor,
    //   ),
    //   messageConfig: MessageConfiguration(
    //     imageMessageConfig: ImageMessageConfiguration(
    //       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    //       shareIconConfig: ShareIconConfiguration(onPressed: (message) {
    //         showModalBottomSheet(
    //           context: context,
    //           builder: (BuildContext context) {
    //             return forward_to(message: message);
    //           },
    //           isScrollControlled: true,
    //         );
    //       }),
    //     ),
    //   ),
    //   profileCircleConfig: const ProfileCircleConfiguration(
    //     profileImageUrl: "",
    //   ),
    //   repliedMessageConfig: RepliedMessageConfiguration(
    //     backgroundColor: theme.repliedMessageColor,
    //     verticalBarColor: theme.verticalBarColor,
    //     repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
    //       enableHighlightRepliedMsg: true,
    //       highlightColor: Colors.pinkAccent.shade100,
    //       highlightScale: 1.1,
    //     ),
    //     textStyle: const TextStyle(
    //       color: Colors.white,
    //       fontWeight: FontWeight.bold,
    //       letterSpacing: 0.25,
    //     ),
    //     replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
    //   ),
    //   swipeToReplyConfig: SwipeToReplyConfiguration(
    //     replyIconColor: theme.swipeToReplyIconColor,
    //   ),
    // );
    return Text("data");
  });
}
