import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chatview/chatview.dart';
import 'package:example/data.dart';
import 'package:example/models/theme.dart';
import 'package:get/get.dart';
var _chatController;
class ChatScreen extends StatefulWidget {
  var doc,user;
  ChatScreen(this.doc,this.user);

  @override
  State<ChatScreen> createState() => _chatState();
}

AppTheme theme = LightTheme();
bool isDarkTheme = false;
var auth=FirebaseAuth.instance;
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
late StreamController<List<Message>> _messageStreamController;
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

  void initState() {
    _messageStreamController = StreamController<List<Message>>();
    _messageStreamController.addStream(getMessageStream());
     getCHECKFromDocument();
    print("start");
    super.initState();
  }
  // List<Message> messages=[];
  Stream<List<Message>> getMessageStream(){
    return FirebaseFirestore.instance
        .collection("accounts")
        .doc("${auth.currentUser?.email}")
        .collection("mess")
        .doc(widget.user)
        .collection("chat").orderBy('Time', descending: true)
        .snapshots()
        .map((snapshot) {
      List<Message>messages = [];
      snapshot.docs.forEach((doc) {
        // index.add(value)
        messages.add(Message(
          id: doc.data()['id'],
          message: doc.data()['text'],
          createdAt: doc.data()['Time'].toDate(),
          sendBy: doc.data()['sendby'],
        ));
      });
      return messages;
    });
  }
  AppTheme theme = LightTheme();
  bool isDarkTheme = false;

  final currentUser = ChatUser(
    id: '${auth.currentUser?.email}',
    name: 'Flutter',
    profilePhoto: Data.profileImage,
  );

  List<Message> messageList=[];
  List<Message> messageLength=[];
  List<Message> messagefl=[];
  // var message_length=0;

  @override
  Widget build(BuildContext context) {
     _chatController = ChatController(
      initialMessageList:messageList,
      scrollController: ScrollController(),
      chatUsers: [
        ChatUser(
          id: '${widget.user}',
          name:'${widget.user}',
          profilePhoto: Data.profileImage,
        ),
      ],
    );
    return Scaffold(
        body:StreamBuilder(
            stream:_messageStreamController.stream,
            builder: (context, snapshot){
              getCHECKFromDocument();
                if (snapshot.connectionState == ConnectionState.waiting) {
                 return Center( child: CircularProgressIndicator(),);
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),);
                } else {
                  getCHECKFromDocument();
                  if (snapshot.data!.length == 0) {
                    messageList = snapshot.data!;
                    messagefl=messageList;
                    print("objecT---${messageList.length}");
                    messageLength.isEmpty ? messageLength = messageList : null;
                    updateCHECKInDocument(true);
                    print("objecT---${messageLength.length}");
                    return ChatViewWidget(
                        currentUser: currentUser,
                        messageList: snapshot.data ?? [],
                        chatController: _chatController,
                        user: widget.user
                    );
                  }else{
                  messageList = snapshot.data!;
                  // messageList.sort((a, b) =>a.createdAt.compareTo(b.createdAt));
                  messageLength.isEmpty ? messageLength = messageList : null;
                  // messageLength.sort((a, b) =>a.createdAt.compareTo(b.createdAt));
                  print("dddddddddddddddddd${snapshot.data!.last.message}");
                  print("dddddddddddddddddd////////$check");
                  print("dddddddddddddddddd");
                  messageLength.toSet().toList();
                  _chatController.initialMessageList =messageLength.toSet().toList();
                  print("dddddddddddddddddd${messageList.last.createdAt}///${messageList.last.message}");
                  print("dddddddddddddddddd${messageLength.last.createdAt}///${messageLength.last.message}");
                  // print("${messageList.indexOf(Message(
                  //     message: messageLength.first.message,
                  //     createdAt: messageLength.last.createdAt,
                  //     sendBy: messageLength.last.sendBy))}");
                  if (messageLength!= messageList) {
                    if (messageLength.isNotEmpty) {
                      // Future<bool> _checkMessagesExist(List<Message> messageList) async {
                        for (final message in messageList) {
                          if (!isMessageExists(message, messageLength)) {
                            _chatController.addMessage(message);
                              // Message(
                              //     id: "${messageList.last.id}",
                              //     createdAt: DateTime.now(),
                              //     message: messageList.last.message,
                              //     sendBy: messageList.last.sendBy
                              // ),);
                            messageLength = messageList;print("message added1");
                          }
                        }print("don't Added");
                        // return true;
                      // }
                      // if (isMessageExists(messageList.last, messageLength)) {
                      //   print("11***11");
                      //
                      //
                      // } else {
                      //
                      // }
                    }
                    print("not exisit");
                  }
                  else {
                    if(messageList.first==messageList.last){
                        print(messageLength.first.message);
                        print(messageList.first.message);
                        print("---${messageLength.length}");
                        print("---${messageList.length}");
                        print(isMessageExists(messageLength.last, messageList));
                        // print("---${messageLength.length}");
                        // print(messageLength.contains(messageList.first.message));
                        //   if(messageLength.length==1){
                            if(check.toString()=='null'||check.toString()=='true'){
                              // messageList.removeLast();
                              if(isMessageExists(messageList.last, messageLength)){
                              print("---${messageList.length}");
                              _chatController.addMessage(
                              Message(
                                  id: "${messageList.last.id}",
                                  createdAt: DateTime.now(),
                                  message:messageList.last.message,
                                  sendBy: messageList.last.sendBy
                              ),);
                              _chatController.removeMessage(messageLength.last);
                              // messageLength=messageList;
                              updateCHECKInDocument(false);
                            print("message added2");
                          }else{print("don't Added");}}
                        print("message added3");
                    } else print("lists equall");}

                  return ChatViewWidget(
                    currentUser: currentUser,
                    messageList: snapshot.data ?? [],
                    chatController: _chatController,
                    user: widget.user,
                    getmessage: getMessageStream(),
                  );
                }
            }}
        )
    );
  }
    void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
      }
    });
  }
}
class ChatViewWidget extends StatefulWidget {
  final ChatUser currentUser;
  final List<Message> messageList;
  final ChatController chatController;
  final String user;
  var getmessage;

   ChatViewWidget({
    Key? key,
    required this.currentUser,
    required this.messageList,
    required this.chatController,
    required this.user,
     this.getmessage,
  }) : super(key: key);

  @override
  State<ChatViewWidget> createState() => _ChatViewWidgetState();
}

class _ChatViewWidgetState extends State<ChatViewWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = isDarkTheme ? DarkTheme() : LightTheme();
    return ChatView(
      currentUser: widget.currentUser,
      loadingWidget:CircularProgressIndicator(),
      chatController:widget.chatController,
      onSendTap: _onSendTap,
      featureActiveConfig: const FeatureActiveConfig(
        lastSeenAgoBuilderVisibility: true,
        receiptsBuilderVisibility: true,
      ),
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
        elevation: theme.elevation,
        backGroundColor: theme.appBarColor,
        profilePicture: Data.profileImage,
        backArrowColor: theme.backArrowColor,
        chatTitle: "${widget.user.replaceAll("@gmail.com", '')}",
        chatTitleTextStyle: TextStyle(
          color: theme.appBarTitleTextStyle,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 0.25,
        ),
        userStatus: "online",
        userStatusTextStyle: const TextStyle(color: Colors.grey),
        actions: [
          IconButton(
            onPressed: _onThemeIconTap,
            icon: Icon(
              isDarkTheme
                  ? Icons.brightness_4_outlined
                  : Icons.dark_mode_outlined,
              color: theme.themeIconColor,
            ),
          ),
          IconButton(
            tooltip: 'Toggle TypingIndicator',
            onPressed: ()async{
              // initState();
            },
            icon: Icon(
              Icons.keyboard,
              color: theme.themeIconColor,
            ),
          ),
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
          galleryIconColor: theme.galleryIconColor, ),
        replyMessageColor: theme.replyMessageColor,
        defaultSendButtonColor: theme.sendButtonColor,
        replyDialogColor: theme.replyDialogColor,
        replyTitleColor: theme.replyTitleColor,
        textFieldBackgroundColor: theme.textFieldBackgroundColor,
        closeIconColor: theme.closeIconColor,
        textFieldConfig: TextFieldConfiguration(
          onMessageTyping: (status) {
            /// Do with status
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
          receiptsWidgetConfig:
          const ReceiptsWidgetConfig(showReceiptsIn: ShowReceiptsIn.all),
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
          onMessageRead: (message)async{
          },
          senderNameTextStyle:TextStyle(color: theme.inComingChatBubbleTextColor),
          color: theme.inComingChatBubbleColor,
        ),
      ),
      replyPopupConfig: ReplyPopupConfiguration(
        onUnsendTap:(Message)async{
          // await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat")
          print(check.toString());
          showDialog(context: context, builder:(context) {
            return AlertDialog(
                shape:UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                //OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                title: Text("Delete Message ?",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                actions:[
                  Column(
                    children:[
                      Text("This message will be deleted for you and other people",style: TextStyle(fontSize: 18),textAlign:TextAlign.center),
                      Padding(padding: EdgeInsetsDirectional.all(5)),
                      Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container( margin:EdgeInsetsDirectional.only(top: 10,end: 5),child: ElevatedButton(
                              onPressed: (){
                              Navigator.pop(context);
                              },
                              child:Text("Cancel",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),))),


                          Container( margin:EdgeInsetsDirectional.only(top: 10,end: 5),child: ElevatedButton(
                              onPressed: () async{
                                widget.chatController.removeMessage(Message);
                                // _messageStreamController.addStream(widget.getmessage);
                                Navigator.of(context).pop();
                                int index = widget.messageList.indexWhere((obj) => obj.createdAt.toString()== '${Message.createdAt}');
                                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                    .collection("accounts").doc("${auth.currentUser?.email}").collection("mess")
                                    .doc(widget.user).collection("chat").orderBy("Time")
                                    .get();
                                QuerySnapshot querySnapshot2 =await FirebaseFirestore.instance.
                                    collection("accounts").doc(widget.user).collection("mess").
                                    doc("${auth.currentUser?.email}").collection("chat")
                                    .orderBy("Time")
                                    .get();
                                  print(querySnapshot.docs[index].get("text"));
                                  print(querySnapshot2.docs[index].get("text"));
                                  DocumentSnapshot lastDocument = querySnapshot.docs[index];
                                  DocumentSnapshot lastDocument2 = querySnapshot2.docs[index];

                                await FirebaseFirestore.instance
                                   .collection("accounts")
                                   .doc("${auth.currentUser?.email}")
                                   .collection("mess")
                                   .doc(widget.user)
                                   .collection("chat").doc(lastDocument.id).delete().then((value)async=>
                               await FirebaseFirestore.instance.
                               collection("accounts").
                               doc(widget.user).
                               collection("mess").
                               doc("${auth.currentUser?.email}")
                               .collection("chat").doc(lastDocument2.id).delete());
                               //  Navigator.of(context).p op();

                              },
                              child:Text("Delete",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),))),
                        ],)],
                  ),
                ]
            );
          });

          //     .where(field).de
          // print(message.message);
        },
        backgroundColor: theme.replyPopupColor,
        buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
        topBorderColor: theme.replyPopupTopBorderColor,
      ),
      reactionPopupConfig: ReactionPopupConfiguration(
        shadow: BoxShadow(
          color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
          blurRadius: 20,
        ),
        backgroundColor: theme.reactionPopupColor,
      ),
      messageConfig: MessageConfiguration(
        messageReactionConfig: MessageReactionConfiguration(
          backgroundColor: theme.messageReactionBackGroundColor,
          borderColor: theme.messageReactionBackGroundColor,
          reactedUserCountTextStyle:
          TextStyle(color: theme.inComingChatBubbleTextColor),
          reactionCountTextStyle:
          TextStyle(color: theme.inComingChatBubbleTextColor),
          reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
            backgroundColor: theme.backgroundColor,
            reactedUserTextStyle: TextStyle(
              color: theme.inComingChatBubbleTextColor,
            ),
            reactionWidgetDecoration: BoxDecoration(
              color: theme.inComingChatBubbleColor,
              boxShadow: [
                BoxShadow(
                  color: isDarkTheme ? Colors.black12 : Colors.grey.shade200,
                  offset: const Offset(0, 20),
                  blurRadius: 40,
                )
              ],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        imageMessageConfig: ImageMessageConfiguration(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          shareIconConfig: ShareIconConfiguration(
            defaultIconBackgroundColor: theme.shareIconBackgroundColor,
            defaultIconColor: theme.shareIconColor,
          ),
        ),
      ),
      profileCircleConfig: const ProfileCircleConfiguration(
        profileImageUrl: Data.profileImage,
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

  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
      }
    });
  }

  void _onSendTap(
      String message,
      ReplyMessage replyMessage,
      MessageType messageType,
      ) async{
    // print("****************$MessageType");
    // print("/////////////$replyMessage");
    String documentPath = 'accounts/${auth.currentUser?.email}/mess/${widget.user}';
    bool exists = await doesDocumentExist(documentPath);
    String documentPath2 = 'accounts/${widget.user}/mess/${auth.currentUser?.email}';
    bool exists2 = await doesDocumentExist(documentPath2);
    !exists?await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).set({"time": DateTime.now(),"firstmessage":true}):null;
    !exists2?await FirebaseFirestore.instance.collection("accounts").doc("${widget.user}").collection("mess").doc("${auth.currentUser?.email}").set({"time": DateTime.now(),"firstmessage":true}):null;
    print('Document exists: $exists');
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat")
        .add({
      "id": auth.currentUser?.email,
      "text": "${message}",
      // "replyMessage": replyMessage,
      // "messageType": messageType,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {print("doneeeeee");});
    await FirebaseFirestore.instance.collection("accounts").doc(widget.user).collection("mess").doc("${auth.currentUser?.email}").collection("chat")
        .add({
      "id": auth.currentUser?.email,
      "text": "${message}",
      // "replyMessage": replyMessage,
      // "messageType": messageType,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {
      print("doneeeeee${DateTime.now()}");
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.initialMessageList.last.setStatus =
          MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    });
  }
}