import 'package:example/bot.dart';
import 'package:example/ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/data.dart';
import 'package:example/models/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class chat extends StatefulWidget {
  var doc,user;
   chat(this.doc,this.user);

  @override
  State<chat> createState() => _chatState();
}

AppTheme theme = LightTheme();
bool isDarkTheme = false;
final currentUser = ChatUser(
  id: '1',
  name: 'Flutter',
  profilePhoto: Data.profileImage,
);
final _chatController = ChatController(
  initialMessageList: Data.messageList,
  scrollController: ScrollController(),
  chatUsers: [
    ChatUser(
      id: '2',
      name: 'Simform',
      profilePhoto: Data.profileImage,
    ),
  ],
);

void _showHideTypingIndicator() {
  _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
}

var auth=FirebaseAuth.instance;
var _messagecont=TextEditingController();

var user=FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess");
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
class _chatState extends State<chat> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title:Text(widget.user),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              // stream:FirebaseFirestore.instance.collection("${auth.currentUser?.email}").doc(widget.doc).collection("mess").snapshots(),
              // stream:FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat").orderBy('time').snapshots(),
              stream:FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  // Data is fetched successfully
                  final data = snapshot.data!;
                  return SizedBox(height: 250,
                    child: ListView.builder(shrinkWrap:true,
                      itemCount: data.docs.length,
                      itemBuilder: (context, index) {
                        final doc = data.docs[index];
                        var c=FirebaseAuth.instance.currentUser!.email;
                        return SizedBox(
                          height: 250,
                          child: ChatView(
                            currentUser: currentUser,
                            chatController: _chatController,
                            onSendTap: _onSendTap,
                            // featureActiveConfig: const FeatureActiveConfig(
                            //   lastSeenAgoBuilderVisibility: true,
                            //   receiptsBuilderVisibility: true,
                            // ),
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
                            // appBar: ChatViewAppBar(
                            //   elevation: theme.elevation,
                            //   backGroundColor: theme.appBarColor,
                            //   profilePicture: Data.profileImage,
                            //   backArrowColor: theme.backArrowColor,
                            //   chatTitle: "Chat view",
                            //   chatTitleTextStyle: TextStyle(
                            //     color: theme.appBarTitleTextStyle,
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 18,
                            //     letterSpacing: 0.25,
                            //   ),
                            //   userStatus: "online",
                            //   userStatusTextStyle: const TextStyle(color: Colors.grey),
                            //   actions: [
                            //     IconButton(
                            //       onPressed: _onThemeIconTap,
                            //       icon: Icon(
                            //         isDarkTheme
                            //             ? Icons.brightness_4_outlined
                            //             : Icons.dark_mode_outlined,
                            //         color: theme.themeIconColor,
                            //       ),
                            //     ),
                            //     IconButton(
                            //       tooltip: 'Toggle TypingIndicator',
                            //       onPressed: _showHideTypingIndicator,
                            //       icon: Icon(
                            //         Icons.keyboard,
                            //         color: theme.themeIconColor,
                            //       ),
                            //     ),
                            //   ],
                            // ),
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
                                onMessageRead: (message) {
                                  /// send your message reciepts to the other client
                                  debugPrint('Message Read');
                                },
                                senderNameTextStyle:
                                TextStyle(color: theme.inComingChatBubbleTextColor),
                                color: theme.inComingChatBubbleColor,
                              ),
                            ),
                            replyPopupConfig: ReplyPopupConfiguration(
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
                          ),
                        );

                          messstyle(text:doc.data()['text'].toString(),isUser:doc.data()['sendby'].toString()==auth.currentUser?.email.toString()?true:false,messageTime:doc.data()['Time'] ,);
                        // );
                      },
                    ),
                  );
                }
              },
            ),
          ),
      // Stack(
          //   children:[ GestureDetector(
          //     child: Container(
          //       height:60,
          //       width:MediaQuery.of(context).size.width,alignment:Alignment.centerRight, margin:EdgeInsets.all(10),
          //       child:TextFormField(
          //         cursorColor: Colors.indigo,
          //       style: TextStyle(fontSize: 19),controller: _messagecont,
          //         decoration: InputDecoration(
          //             hintText: "Type your message..",
          //             errorBorder: OutlineInputBorder(
          //                 borderSide: BorderSide(color: Colors.red)),
          //             border: OutlineInputBorder(
          //                 borderRadius: BorderRadius.only(topRight: Radius.circular(50),
          //                   topLeft: Radius.circular(50),
          //                   bottomRight: Radius.circular(50),
          //                   bottomLeft: Radius.circular(50),)),
          //             // suffixIcon:
          //         ),
          //       ),
          //     ),
          //   ),
          //     Align(alignment:Alignment.bottomRight,
          //       child: IconButton(
          //           onPressed: () async {
          //             String documentPath = 'accounts/${auth.currentUser?.email}/mess/${widget.user}';
          //             bool exists = await doesDocumentExist(documentPath);
          //             String documentPath2 = 'accounts/${widget.user}/mess/${auth.currentUser?.email}';
          //             bool exists2 = await doesDocumentExist(documentPath2);
          //             !exists?await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).set({"time": DateTime.now()}):null;
          //             !exists2?await FirebaseFirestore.instance.collection("accounts").doc("${widget.user}").collection("mess").doc("${auth.currentUser?.email}").set({"time": DateTime.now()}):null;
          //             print('Document exists: $exists');
          //             await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat")
          //                 .add({
          //               "text": "${_messagecont.text}",
          //               "sendby": auth.currentUser?.email,
          //               "Time": DateTime.now()
          //             }).then((value) {print("doneeeeee");});
          //             await FirebaseFirestore.instance.collection("accounts").doc(widget.user).collection("mess").doc("${auth.currentUser?.email}").collection("chat")
          //                 .add({
          //               "text": "${_messagecont.text}",
          //               "sendby": auth.currentUser?.email,
          //               "Time": DateTime.now()
          //             }).then((value) {print("doneeeeee");});
          //             _messagecont.clear();
          //           },
          //           icon: CircleAvatar(radius:31,
          //               backgroundColor:Colors.blue,child: Icon(Icons.send,
          //             color: Colors.white,size:35,))),
          //     )
          // ]),
        ],
      )
    );
  }

  void _onSendTap(String message,ReplyMessage replyMessage,MessageType messageType,) {
    final id = int.parse(Data.messageList.last.id) + 1;
    _chatController.addMessage(
      Message(
        id: id.toString(),
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
      ),
    );
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   _chatController.initialMessageList.last.setStatus =
    //       MessageStatus.undelivered;
    // });
    // Future.delayed(const Duration(seconds: 1), () {
    //   _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    // });
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
class messstyle extends StatelessWidget {
  final String text;
  final bool isUser;
  var messageTime;

   messstyle({
    required this.text,
    required this.isUser,
    required this.messageTime,
  });
  @override
  Widget build(BuildContext context) {
    var userColor=Colors.blueAccent;
    var repleycolor=Colors.grey;
    var userIcon=Icon(Icons.person);
    var repleyIcon=Icon(Icons.android);
    DateTime roundDateTimeToMinute(DateTime dateTime) {
      return dateTime.subtract(Duration(
          minutes: dateTime.minute % 1,
          seconds: dateTime.second,
          milliseconds: dateTime.millisecond,
          microseconds: dateTime.microsecond));
    }
    return Column(
      crossAxisAlignment:
      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: userColor,
                    radius: 20.0,
                    child: repleyIcon,
                  ),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                margin: EdgeInsets.only(top:10),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isUser ? userColor :  repleycolor,
                  borderRadius: isUser
                      ? const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  )
                      : const BorderRadius.only(
                    topRight: Radius.circular(12.0),
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (isUser)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: userColor,
                    radius:20.0,
                    child: userIcon,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Text(
            "${messageTime}",
            // "${messageTime.hour}:${messageTime.minute}:${messageTime.second}",
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }


}