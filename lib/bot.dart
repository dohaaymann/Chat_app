import 'package:chatview/chatview.dart';
import 'package:example/data.dart';
import 'package:example/models/theme.dart';
import 'package:flutter/material.dart';
//
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatView(
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
        appBar: ChatViewAppBar(
          elevation: theme.elevation,
          backGroundColor: theme.appBarColor,
          profilePicture: Data.profileImage,
          backArrowColor: theme.backArrowColor,
          chatTitle: "Chat view",
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
              onPressed: _showHideTypingIndicator,
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
  }}


// import 'package:example/sql.dart';
// import 'package:example/ui.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/widgets.dart';
//
// import 'database.dart';
// import 'links.dart';
//
// class bot extends StatefulWidget {
//   var doc,user;
//   bot();
//
//   @override
//   State<bot> createState() => _botState();
// }
// var auth=FirebaseAuth.instance;
// var _messagecont=TextEditingController();
//
// // var user=FirebaseFirestore.instance.collection("${auth.currentUser?.uid}").doc(widget.doc).collection("mess");
// Future<bool> doesDocumentExist(String documentPath) async {
//   try {
//     DocumentReference docRef = FirebaseFirestore.instance.doc(documentPath);
//     DocumentSnapshot docSnapshot = await docRef.get();
//     return docSnapshot.exists;
//   } catch (e) {
//     print('Error checking document existence: $e');
//     return false; // Return false in case of error
//   }
// }
// class _botState extends State<bot> {
//   @override
//   List msg=[];
//   List messages=[];
//   SQLDB sql=SQLDB();
//   readdata()async{
//     messages=[];
//     var res=await sql.read('chatbot');
//     messages.addAll(res);
//     if(this.mounted){
//       setState(() { });
//     }
//   }
//   @override
//   void initState() {
//     // TODO: implement initState
//     readdata();
//     super.initState();
//   }
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar:AppBar(
//           title:Text("Chat Bot"),
//         ),
//         body: SingleChildScrollView(physics: ClampingScrollPhysics(),
//           child: Column(
//             children: [
//                ListView.builder(itemCount:messages.length,
//                  shrinkWrap: true,physics: ClampingScrollPhysics(),
//                  itemBuilder: (context, index) {
//                  return messstyle(text:messages[index]['content'], isme:messages[index]['role']=='user'?true:false);
//                },),
//                Align(alignment: AlignmentDirectional.bottomEnd,
//                  child: Stack(
//                     children:[ GestureDetector(
//                       child: Container(
//                         height:60,
//                         width:MediaQuery.of(context).size.width,alignment:Alignment.centerRight, margin:EdgeInsets.all(10),
//                         child:TextFormField(
//                           cursorColor: Colors.indigo,
//                           style: TextStyle(fontSize: 19),controller: _messagecont,
//                           decoration: InputDecoration(
//                             hintText: "Type your message..",
//                             errorBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.red)),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.only(topRight: Radius.circular(50),
//                                   topLeft: Radius.circular(50),
//                                   bottomRight: Radius.circular(50),
//                                   bottomLeft: Radius.circular(50),)),
//                             // suffixIcon:
//                           ),
//                         ),
//                       ),
//                     ),
//                       Align(alignment:Alignment.bottomRight,
//                         child: IconButton(
//                             onPressed: () async {
//                               // await sql.insert(_messagecont.text,"${DateTime.now()}","user");
//                               var db=database();
//                               print(_messagecont.text);
//                               var w=await db.postRequest(start,_messagecont.text);
//                               print(w['text']);
//                               // await sql.insert(w['text'],"${DateTime.now()}","sys");
//                               //  setState(()async{
//                               //    await readdata();
//                               // });
//                               _messagecont.clear();
//                             },
//                             icon: CircleAvatar(radius:31,
//                                 backgroundColor:Colors.blue,child: Icon(Icons.send,
//                                   color: Colors.white,size:35,))),
//                       )
//                     ]),
//                ),
//             ],
//           ),
//         )
//     );
//   }
// }
// class messstyle extends StatelessWidget {
//   final String? text;
//   final bool isme;
//   messstyle({required this.text,required this.isme});
//   @override
//   Widget build(BuildContext context) {
//     return
//       Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment:isme? CrossAxisAlignment.end:CrossAxisAlignment.start,
//           children: [
//             Padding(padding: EdgeInsetsDirectional.all(1)),
//             InkWell( onLongPress: (){
//               showDialog(context: context, builder:(context) {
//                 return AlertDialog(
//                     shape:UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
//                     //OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//                     title: Text("Delete Message ?",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//                     actions:[
//                       Column(
//                         children:[
//                           Text("This message will be deleted for you and other people",style: TextStyle(fontSize: 18),textAlign:TextAlign.center),
//                           Padding(padding: EdgeInsetsDirectional.all(5)),
//                           Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Container( margin:EdgeInsetsDirectional.only(top: 10,end: 5),child: ElevatedButton(
//                                   onPressed: (){
//                                     Navigator.pop(context);
//                                   },
//                                   child:Text("Cancel",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),))),
//
//
//                               Container( margin:EdgeInsetsDirectional.only(top: 10,end: 5),child: ElevatedButton(
//                                   onPressed: () async{
//
//                                   },
//                                   child:Text("Delete",textAlign: TextAlign.center,style: TextStyle(fontSize: 20),))),
//                             ],)],
//                       ),
//                     ]
//                 );
//               },);},
//               child: Row(
//                 children: [
//                   // CircleAvatar(radius: 10,backgroundColor: Colors.red,),
//                   Material(
//                     color: isme?Colors.teal:Colors.cyan,
//                     borderRadius:isme?
//                     BorderRadiusDirectional.only(
//                         topEnd: Radius.circular(1),topStart:Radius.circular(25),bottomEnd: Radius.circular(15),bottomStart: Radius.circular(25) ):
//                     BorderRadiusDirectional.only(
//                         topEnd: Radius.circular(25),topStart:Radius.circular(1),bottomEnd: Radius.circular(25),bottomStart: Radius.circular(15) )
//                     ,
//                     //   shape:
//                     // OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Text("$text",style: TextStyle(fontSize: 20,color: Colors.white)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//   }}