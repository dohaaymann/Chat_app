import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/data.dart';
import 'package:example/models/theme.dart';
import 'package:example/pages/forward_to.dart';
import 'package:example/pages/friend_profile.dart';
import 'package:example/widgets/ChatWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import 'chatscreen.dart';
import 'models/SettingsProvider.dart';
import 'notification.dart';

class chat_ extends StatefulWidget {
  final String name;
  final String email;
  final String bio;
  final String photo;
  final String token;

  chat_(this.name, this.email, this.bio, this.photo, this.token);

  @override
  State<chat_> createState() => _chat_State();
}

class _chat_State extends State<chat_> {
  late ChatController _chatController;
  late Stream<List<Message>> _messageStream;
  // late FirebaseAuth auth;
  var auth=FirebaseAuth.instance;
  bool isDarkTheme = false;
  AppTheme theme = LightTheme();
  List<Message> messageList = [];
  List<Message> messageLength=[];
  var check_=false;
  final currentUser = ChatUser(
    id: '${FirebaseAuth.instance.currentUser?.email}',
    name:'${FirebaseAuth.instance.currentUser?.displayName}',
    profilePhoto: '${FirebaseAuth.instance.currentUser?.photoURL}',
  );
  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    _chatController = ChatController(
      initialMessageList: [],
      scrollController: ScrollController(),
      chatUsers: [
        ChatUser(
          id: widget.email,
          name: widget.name,
          profilePhoto: widget.photo,
        ),
        // Add the current user as well
      ],
    );
    _initializeMessageStream();
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
        messageType: data['istext'] ? MessageType.text : data['isvoice']?MessageType.voice:MessageType.image,
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

  _onSendTap(
      String message,
      ReplyMessage replyMessage,
      MessageType messageType,
      )async{
    // print("/////////////${replyMessage}");
    var r=get_random().toString();
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.email).collection("chat")
        .add({
      "id": r,
      "text": "${message}",
      "replyMessage":replyMessage.message,
      "istext": messageType.isText,
      "isvoice":messageType.isVoice,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {print("doneeeeee");});
    await FirebaseFirestore.instance.collection("accounts").doc(widget.email).collection("mess").doc("${auth.currentUser?.email}").collection("chat")
        .add({
      "id": r,
      "text": "${message}",
      "replyMessage":replyMessage.message,
      "istext": messageType.isText,
      "isvoice":messageType.isVoice,
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
    String documentPath = 'accounts/${auth.currentUser?.email}/mess/${widget.email}';
    bool exists = await doesDocumentExist(documentPath);
    String documentPath2 = 'accounts/${widget.email}/mess/${auth.currentUser?.email}';
    bool exists2 = await doesDocumentExist(documentPath2);
    !exists?await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.email).set({"time": DateTime.now(),"firstmessage":true,"isblocked":false}):
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.email).update({"time": DateTime.now()});
    !exists2?await FirebaseFirestore.instance.collection("accounts").doc("${widget.email}").collection("mess").doc("${auth.currentUser?.email}").set({"time": DateTime.now(),"firstmessage":true,"isblocked":false}):
    await FirebaseFirestore.instance.collection("accounts").doc("${widget.email}").collection("mess").doc("${auth.currentUser?.email}").update({"time": DateTime.now()});
    // print('Document exists: $exists');

  }
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Consumer<SettingsProvider>(builder: (context, provide, child){
        var theme = provide.isDarkTheme ? DarkTheme() : LightTheme();
        return StreamBuilder<List<Message>>(
          stream: _messageStream,
          builder: (context, snapshot) {
            // print(snapshot.data!);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                print("//////emptyyyy/////////////");
                messageList = snapshot.data!;
                check_=true;
                // messagefl = messageList;

                print("Snapshot data is empty: ${snapshot.data!.isEmpty}");
                print("Message length is empty: ${messageLength.isEmpty}");
                // return Text("data");
              }
              else{
              messageList = snapshot.data ?? [];
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
                  // print("message added");
                }
                // print("not exist so it added");
              }
              else {
                // print("///////${messageLength.length}");
                // print("///////+${check_}");
                // print("///////${messageList.length}");
                if(messageList.first==messageList.last){
                  if(check.toString()=='null'||check.toString()=='true'){
                    if(check_){
                      _chatController.addMessage(messageList.last);
                      // print("first message added");
                    }else{
                      // print("don't Added");
                    }
                  }else print("nenene");
                  // print("lists not equal");
                } else print("lists equal");
              }}
              // return Chat_Widget(currentUser,snapshot.data ?? [], _chatController,widget.email,getMessageStream(),widget.name,widget.photo,widget.bio,widget.token);
              return ChatView(
                currentUser: currentUser,
                isBlocked: provide.block,
                // loadingWidget: CircularProgressIndicator(color: Colors.red,),
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
          },
        );
      }
      ),
    );
  }
}
