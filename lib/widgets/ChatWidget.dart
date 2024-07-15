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
import '../models/sql.dart';
import '../notification.dart';

var getmessage;
var auth = FirebaseAuth.instance;

class Chat_Widget extends StatefulWidget {
  final ChatUser currentUser;
  final List<Message> messageList;
  final ChatController chatController;
  final String user;
  final String name;
  var getmessage;
  final String photo;
  final String bio;
  final String token;

  Chat_Widget(
      this.currentUser,
      this.messageList,
      this.chatController,
      this.user,
      this.getmessage,
      this.name,
      this.photo,
      this.bio,
      this.token,
      );

  @override
  _Chat_WidgetState createState() => _Chat_WidgetState();
}

class _Chat_WidgetState extends State<Chat_Widget> {
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  _onSendTap(
      String message,
      ReplyMessage replyMessage,
      MessageType messageType,
      )async{
    // print("/////////////${replyMessage}");
    var r=get_random().toString();
    String documentPath = 'accounts/${auth.currentUser?.email}/mess/${widget.user}';
    bool exists = await doesDocumentExist(documentPath);
    String documentPath2 = 'accounts/${widget.user}/mess/${auth.currentUser?.email}';
    bool exists2 = await doesDocumentExist(documentPath2);
    !exists?await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).set({"time": DateTime.now(),"firstmessage":true,"isblocked":false}):
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).update({"time": DateTime.now()});
    !exists2?await FirebaseFirestore.instance.collection("accounts").doc("${widget.user}").collection("mess").doc("${auth.currentUser?.email}").set({"time": DateTime.now(),"firstmessage":true,"isblocked":false}):
    await FirebaseFirestore.instance.collection("accounts").doc("${widget.user}").collection("mess").doc("${auth.currentUser?.email}").update({"time": DateTime.now()});
    // print('Document exists: $exists');
    await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat")
        .add({
      "id": r,
      "text": "${message}",
      "replyMessage":replyMessage.message,
      "istext": messageType.isText,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {print("doneeeeee");});
    await FirebaseFirestore.instance.collection("accounts").doc(widget.user).collection("mess").doc("${auth.currentUser?.email}").collection("chat")
        .add({
      "id": r,
      "text": "${message}",
      "replyMessage":replyMessage.message,
      "istext": messageType.isText,
      "sendby": auth.currentUser?.email,
      "Time": DateTime.now()
    }).then((value) {
      // var notify=Notification_();
      // print("doneeeeee${DateTime.now()}");
      // notify.sendPushNotification(
      //     "${widget.token}"
      //     ,"${widget.name}",
      //     "${message}");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (context, provide, child) {
      var theme = provide.isDarkTheme ? DarkTheme() : LightTheme();
      print("99900000000000000000000999");
      return ChatView(
        currentUser:currentUser,
        // key: UniqueKey(), // Add unique key here
        // currentUser: widget.currentUser,
        isBlocked: provide.block,
        loadingWidget: CircularProgressIndicator(color: Colors.red),
        chatController: widget.chatController,
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
            Get.to(() => friend_profile(widget.name, widget.user, widget.bio, widget.photo, provide.isblock));
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
                .doc(widget.user)
                .collection("chat")
                .where('id', isEqualTo: '${message.id}')
                .get();

            for (QueryDocumentSnapshot document in querySnapshot.docs) {
              await document.reference.delete();
            }
            print("Documents have been deleted.");
            print(message.id);
            widget.chatController.removeMessage(message);
          },
          onUnsendTap: (Message) async {
            print(Message.id);

            await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat");
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
                                widget.chatController.removeMessage(Message);
                                Navigator.of(context).pop();
                                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                    .collection("accounts")
                                    .doc("${auth.currentUser?.email}")
                                    .collection("mess")
                                    .doc(widget.user)
                                    .collection("chat")
                                    .where('id', isEqualTo: '${Message.id}')
                                    .get();
                                QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
                                    .collection("accounts")
                                    .doc(widget.user)
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
                                    .doc(widget.user)
                                    .collection("chat")
                                    .get();

                                if (remainingMessagesCurrentUser.docs.isEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection("accounts")
                                      .doc("${auth.currentUser?.email}")
                                      .collection("mess")
                                      .doc(widget.user)
                                      .delete();
                                }

                                // Check if the other user's subcollection is empty and delete the parent document if it is
                                QuerySnapshot remainingMessagesOtherUser = await FirebaseFirestore.instance
                                    .collection("accounts")
                                    .doc(widget.user)
                                    .collection("mess")
                                    .doc("${auth.currentUser?.email}")
                                    .collection("chat")
                                    .get();

                                if (remainingMessagesOtherUser.docs.isEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection("accounts")
                                      .doc(widget.user)
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
    });
  }

  // void _onSendTap(
  //     String message,
  //     ReplyMessage replyMessage,
  //     MessageType messageType,
  //     ) async {
  //   var r = get_random().toString();
  //   String documentPath = 'accounts/${auth.currentUser?.email}/mess/${widget.user}';
  //   bool exists = await doesDocumentExist(documentPath);
  //   String documentPath2 = 'accounts/${widget.user}/mess/${auth.currentUser?.email}';
  //   bool exists2 = await doesDocumentExist(documentPath2);
  //   if (!exists) {
  //     await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).set({
  //       "time": DateTime.now(),
  //       "firstmessage": true,
  //       "isblocked": false
  //     });
  //   } else {
  //     await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).update({
  //       "time": DateTime.now()
  //     });
  //   }
  //   if (!exists2) {
  //     await FirebaseFirestore.instance.collection("accounts").doc("${widget.user}").collection("mess").doc("${auth.currentUser?.email}").set({
  //       "time": DateTime.now(),
  //       "firstmessage": true,
  //       "isblocked": false
  //     });
  //   } else {
  //     await FirebaseFirestore.instance.collection("accounts").doc("${widget.user}").collection("mess").doc("${auth.currentUser?.email}").update({
  //       "time": DateTime.now()
  //     });
  //   }
  //   await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").collection("mess").doc(widget.user).collection("chat").add({
  //     "id": r,
  //     "text": "${message}",
  //     "replyMessage": replyMessage.message,
  //     "istext": messageType.isText,
  //     "sendby": auth.currentUser?.email,
  //     "Time": DateTime.now()
  //   }).then((value) {
  //     print("doneeeeee");
  //   });
  //   await FirebaseFirestore.instance.collection("accounts").doc(widget.user).collection("mess").doc("${auth.currentUser?.email}").collection("chat").add({
  //     "id": r,
  //     "text": "${message}",
  //     "replyMessage": replyMessage.message,
  //     "istext": messageType.isText,
  //     "sendby": auth.currentUser?.email,
  //     "Time": DateTime.now()
  //   }).then((value) {
  //     var notify = Notification_();
  //     print("doneeeeee${DateTime.now()}");
  //     notify.sendPushNotification("${widget.token}", "${widget.name}", "${message}");
  //   });
  // }

  Future<bool> doesDocumentExist(String documentPath) async {
    try {
      var document = await FirebaseFirestore.instance.doc(documentPath).get();
      return document.exists;
    } catch (e) {
      return false;
    }
  }
}