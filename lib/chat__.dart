import 'package:chatview/chatview.dart';
import 'package:example/pages/friend_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/pages/forward_to.dart';
import 'package:flutter/widgets.dart';
import 'package:chatview/chatview.dart';
import 'package:example/models/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'dart:math';

import 'package:http/http.dart';
import 'chatscreen.dart';
import 'models/theme.dart';

class ChatViewWidget extends StatefulWidget {
  final ChatUser currentUser;
  final List<Message> messageList;
  final ChatController chatController;
  final String user,name;
  final photo;
  var getmessage;
  // Assuming GlobalKeys are used somewhere in this widget or its children
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  ChatViewWidget({
    required this.currentUser,
    required this.messageList,
    required this.chatController,
    required this.user,
    this.getmessage, required this.name, required this.photo,
  });

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
        frienfprofile:(){
          Get.to(()=>friend_profile(name,widget.user,"busy",photo));
          print("object");
        },
        elevation: theme.elevation,
        backGroundColor: theme.appBarColor,
        profilePicture: photo,
        backArrowColor: theme.backArrowColor,
        chatTitle: "${name}",
        chatTitleTextStyle: TextStyle(
          color: theme.appBarTitleTextStyle,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 0.25,
        ),
        // userStatus: "online",
        userStatusTextStyle: const TextStyle(color: Colors.grey),
        actions: [
          IconButton(
            onPressed: _onThemeIconTap,
            icon: Icon(
              isDarkTheme
                  ? Icons.brightness_4_outlined
                  : Icons.dark_mode_outlined,
              color: theme.themeIconColor,size:30,
            ),
          ),
          IconButton(
            tooltip: 'Toggle TypingIndicator',
            onPressed: ()async{
              int randomNumber = 0;
              var random = Random();
              setState(() {
                randomNumber = random.nextInt(1000000000); // Generates a random number between 0 and 99
              });
              print(randomNumber.toString());
            },
            icon: Icon(
              Icons.keyboard,
              color: theme.themeIconColor,size:30,
            ),
          ),
          SizedBox(width:10,)
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
          onMessageRead: (message)async{
          },
          senderNameTextStyle:TextStyle(color: theme.inComingChatBubbleTextColor),
          color: theme.inComingChatBubbleColor,
        ),
      ),
      replyPopupConfig: ReplyPopupConfiguration(
        forward:(message) => print("111111111111111"),
        onMoreTap:(Message  , replyMessage, messageType) {
          print(Message);
          print("*****-------------*********");
        },
        onUnsendTap:(Message)async{
          print(Message.message);
          await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat");
          print(check.toString());
          showDialog(context: context, builder:(context) {
            return AlertDialog(
                shape:const UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                //OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text("Delete Message ?",textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
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
                              onPressed: ()async{
                                widget.chatController.removeMessage(Message);
                                // _messageStreamController.addStream(widget.getmessage);
                                Navigator.of(context).pop();
                                int index = widget.messageList.indexWhere((obj) => obj.id.toString()== '${Message.id}');
                                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                    .collection("accounts").doc("${auth.currentUser?.email}").collection("mess")
                                    .doc(widget.user).collection("chat").orderBy("Time")
                                    .get();
                                QuerySnapshot querySnapshot2 =await FirebaseFirestore.instance.
                                collection("accounts").doc(widget.user).collection("mess").
                                doc("${auth.currentUser?.email}").collection("chat")
                                    .orderBy("Time")
                                    .get();
                                // print(querySnapshot.docs[index].get("text"));
                                // print(querySnapshot2.docs[index].get("text"));
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
        },
        backgroundColor: theme.replyPopupColor,
        buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
        topBorderColor: theme.replyPopupTopBorderColor,
      ),
      messageConfig: MessageConfiguration(
        imageMessageConfig: ImageMessageConfiguration(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          shareIconConfig: ShareIconConfiguration(onPressed:(message){
            // Get.to(()=>forward_to());
            print(message.sendBy);
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return forward_to(message: message,);

              },
              isScrollControlled: true,
            );
          },
            defaultIconBackgroundColor: theme.shareIconBackgroundColor,
            defaultIconColor: theme.shareIconColor,
          ),
        ),
      ),
      profileCircleConfig: const ProfileCircleConfiguration(
        profileImageUrl:"",
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

  _onSendTap(
      String message,
      ReplyMessage replyMessage,
      MessageType messageType,
      )async{
    // print("/////////////${replyMessage}");
    String documentPath = 'accounts/${auth.currentUser?.email}/mess/${widget.user}';
    bool exists = await doesDocumentExist(documentPath);
    String documentPath2 = 'accounts/${widget.user}/mess/${auth.currentUser?.email}';
    bool exists2 = await doesDocumentExist(documentPath2);
    !exists?await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).set({"time": DateTime.now(),"firstmessage":true}):null;
    !exists2?await FirebaseFirestore.instance.collection("accounts").doc("${widget.user}").collection("mess").doc("${auth.currentUser?.email}").set({"time": DateTime.now(),"firstmessage":true}):null;
    // print('Document exists: $exists');
    print("Ssssssssss5");
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat")
        .add({
      "id": get_random().toString(),
      "text": "${message}",
      "replyMessage":replyMessage.message,
      "istext": messageType.isText,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {print("doneeeeee");});
    await FirebaseFirestore.instance.collection("accounts").doc(widget.user).collection("mess").doc("${auth.currentUser?.email}").collection("chat")
        .add({
      "id": get_random().toString(),
      "text": "${message}",
      "replyMessage":replyMessage.message,
      "istext": messageType.isText,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {
      print("doneeeeee${DateTime.now()}");
    });
  }
}