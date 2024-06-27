import 'package:chatview/chatview.dart';
import 'package:example/pages/friend_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:provider/provider.dart';

import '../chatscreen.dart';
import '../models/SettingsProvider.dart';
import '../notification.dart';
// final ChatUser currentUser;
// final List<Message> messageList;
// final ChatController chatController;
// final String user,name;
// final photo;
var getmessage;
var auth=FirebaseAuth.instance;
Widget Chat_Widget(var currentUser, var messageList, var chatController,  var user,var getmessage, var name, var photo,var bio,var token) {
  _onSendTap(
      String message,
      ReplyMessage replyMessage,
      MessageType messageType,
      )async{
    // print("/////////////${replyMessage}");
    String documentPath = 'accounts/${auth.currentUser?.email}/mess/${user}';
    bool exists = await doesDocumentExist(documentPath);
    String documentPath2 = 'accounts/${user}/mess/${auth.currentUser?.email}';
    bool exists2 = await doesDocumentExist(documentPath2);
    !exists?await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(user).set({"time": DateTime.now(),"firstmessage":true,"isblocked":false}):
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(user).update({"time": DateTime.now()});
    !exists2?await FirebaseFirestore.instance.collection("accounts").doc("${user}").collection("mess").doc("${auth.currentUser?.email}").set({"time": DateTime.now(),"firstmessage":true}):
    await FirebaseFirestore.instance.collection("accounts").doc("${user}").collection("mess").doc("${auth.currentUser?.email}").update({"time": DateTime.now()});
    // print('Document exists: $exists');
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(user).collection("chat")
        .add({
      "id": get_random().toString(),
      "text": "${message}",
      "replyMessage":replyMessage.message,
      "istext": messageType.isText,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {print("doneeeeee");});
    await FirebaseFirestore.instance.collection("accounts").doc(user).collection("mess").doc("${auth.currentUser?.email}").collection("chat")
        .add({
      "id": get_random().toString(),
      "text": "${message}",
      "replyMessage":replyMessage.message,
      "istext": messageType.isText,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {
      // var notify=Notification_();
      // print("doneeeeee${DateTime.now()}");
      // notify.sendPushNotification(
      //     "$token"
      //     ,"$name",
      //     "${message}");
    });
  }
  return Consumer<SettingsProvider>(builder: (context, provide, child){
    var theme = provide.isDarkTheme ? DarkTheme() : LightTheme();
    return ChatView(
      currentUser: currentUser,isBlocked:provide.isblock,
      loadingWidget:CircularProgressIndicator(),
      chatController:chatController,
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
          Get.to(()=>friend_profile(name,user,bio,photo));
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
            onPressed:(){},
            icon: Icon(Icons.call,
              color: theme.themeIconColor,size:30,
            ),
          ),
          // IconButton(
          //   tooltip: 'Toggle TypingIndicator',
          //   onPressed: ()async{
          //   },
          //   icon: Icon(
          //     Icons.keyboard,
          //     color: theme.themeIconColor,size:30,
          //   ),
          // ),
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
        onMoreTap:(message) {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return forward_to(message: message,);
            },
            isScrollControlled: true,
          );
        },DeleteTap: (message)async{
          chatController.removeMessage(message);
          int index = messageList.indexWhere((obj) => obj.id.toString()== '${message.id}');
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection("accounts").doc("${auth.currentUser?.email}").collection("mess")
              .doc(user).collection("chat").orderBy("Time")
              .get();
          // print(querySnapshot.docs[index].get("text"));
          // print(querySnapshot2.docs[index].get("text"));
          DocumentSnapshot lastDocument = querySnapshot.docs[index];

          await FirebaseFirestore.instance
              .collection("accounts")
              .doc("${auth.currentUser?.email}")
              .collection("mess")
              .doc(user)
              .collection("chat").doc(lastDocument.id).delete().then((value)async=>print("deleted"));
        //  Navigator.of(context).p op();rint(message.message);
        },
        onUnsendTap:(Message)async{
          await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(user).collection("chat");
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
                                chatController.removeMessage(Message);
                                // _messageStreamController.addStream(widget.getmessage);
                                Navigator.of(context).pop();
                                int index = messageList.indexWhere((obj) => obj.id.toString()== '${Message.id}');
                                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                    .collection("accounts").doc("${auth.currentUser?.email}").collection("mess")
                                    .doc(user).collection("chat").orderBy("Time")
                                    .get();
                                QuerySnapshot querySnapshot2 =await FirebaseFirestore.instance.
                                collection("accounts").doc(user).collection("mess").
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
                                    .doc(user)
                                    .collection("chat").doc(lastDocument.id).delete().then((value)async=>
                                await FirebaseFirestore.instance.
                                collection("accounts").
                                doc(user).
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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shareIconConfig: ShareIconConfiguration(onPressed:(message){
            // Get.to(()=>forward_to());
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
          // color: provide.isDarkTheme?Colors.black:Colors.white,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25,
        ),
        replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
      ),
      swipeToReplyConfig: SwipeToReplyConfiguration(
        replyIconColor: theme.swipeToReplyIconColor,
      ),
    );},
  );
}
