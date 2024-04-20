// import 'package:chatview/chatview.dart';
// import 'package:example/data.dart';
// import 'package:example/models/theme.dart';
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const Example());
// }
//
// class Example extends StatelessWidget {
//   const Example({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Chat UI Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xffEE5366),
//         colorScheme:
//         ColorScheme.fromSwatch(accentColor: const Color(0xffEE5366)),
//       ),
//       home: const ChatScreen(),
//     );
//   }
// }
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   AppTheme theme = LightTheme();
//   bool isDarkTheme = false;
//   final currentUser = ChatUser(
//     id: '1',
//     name: 'Flutter',
//     profilePhoto: Data.profileImage,
//   );
//   final _chatController = ChatController(
//     initialMessageList: Data.messageList,
//     scrollController: ScrollController(),
//     chatUsers: [
//       ChatUser(
//         id: '2',
//         name: 'Simform',
//         profilePhoto: Data.profileImage,
//       ),
//     ],
//   );
//
//   void _showHideTypingIndicator() {
//     _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ChatView(
//         currentUser: currentUser,
//         chatController: _chatController,
//         onSendTap: _onSendTap,
//         // featureActiveConfig: const FeatureActiveConfig(
//         //   lastSeenAgoBuilderVisibility: true,
//         //   receiptsBuilderVisibility: true,
//         // ),
//         chatViewState: ChatViewState.hasMessages,
//         chatViewStateConfig: ChatViewStateConfiguration(
//           loadingWidgetConfig: ChatViewStateWidgetConfiguration(
//             loadingIndicatorColor: theme.outgoingChatBubbleColor,
//           ),
//           onReloadButtonTap: () {},
//         ),
//         typeIndicatorConfig: TypeIndicatorConfiguration(
//           flashingCircleBrightColor: theme.flashingCircleBrightColor,
//           flashingCircleDarkColor: theme.flashingCircleDarkColor,
//         ),
//         appBar: ChatViewAppBar(
//           elevation: theme.elevation,
//           backGroundColor: theme.appBarColor,
//           profilePicture: Data.profileImage,
//           backArrowColor: theme.backArrowColor,
//           chatTitle: "Chat view",
//           chatTitleTextStyle: TextStyle(
//             color: theme.appBarTitleTextStyle,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//             letterSpacing: 0.25,
//           ),
//           userStatus: "online",
//           userStatusTextStyle: const TextStyle(color: Colors.grey),
//           actions: [
//             IconButton(
//               onPressed: _onThemeIconTap,
//               icon: Icon(
//                 isDarkTheme
//                     ? Icons.brightness_4_outlined
//                     : Icons.dark_mode_outlined,
//                 color: theme.themeIconColor,
//               ),
//             ),
//             IconButton(
//               tooltip: 'Toggle TypingIndicator',
//               onPressed: _showHideTypingIndicator,
//               icon: Icon(
//                 Icons.keyboard,
//                 color: theme.themeIconColor,
//               ),
//             ),
//           ],
//         ),
//         chatBackgroundConfig: ChatBackgroundConfiguration(
//           messageTimeIconColor: theme.messageTimeIconColor,
//           messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
//           defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
//             textStyle: TextStyle(
//               color: theme.chatHeaderColor,
//               fontSize: 17,
//             ),
//           ),
//           backgroundColor: theme.backgroundColor,
//         ),
//         sendMessageConfig: SendMessageConfiguration(
//           imagePickerIconsConfig: ImagePickerIconsConfiguration(
//             cameraIconColor: theme.cameraIconColor,
//             galleryIconColor: theme.galleryIconColor,
//           ),
//           replyMessageColor: theme.replyMessageColor,
//           defaultSendButtonColor: theme.sendButtonColor,
//           replyDialogColor: theme.replyDialogColor,
//           replyTitleColor: theme.replyTitleColor,
//           textFieldBackgroundColor: theme.textFieldBackgroundColor,
//           closeIconColor: theme.closeIconColor,
//           textFieldConfig: TextFieldConfiguration(
//             onMessageTyping: (status) {
//               /// Do with status
//               debugPrint(status.toString());
//             },
//             compositionThresholdTime: const Duration(seconds: 1),
//             textStyle: TextStyle(color: theme.textFieldTextColor),
//           ),
//           micIconColor: theme.replyMicIconColor,
//           voiceRecordingConfiguration: VoiceRecordingConfiguration(
//             backgroundColor: theme.waveformBackgroundColor,
//             recorderIconColor: theme.recordIconColor,
//             waveStyle: WaveStyle(
//               showMiddleLine: false,
//               waveColor: theme.waveColor ?? Colors.white,
//               extendWaveform: true,
//             ),
//           ),
//         ),
//         chatBubbleConfig: ChatBubbleConfiguration(
//           outgoingChatBubbleConfig: ChatBubble(
//             linkPreviewConfig: LinkPreviewConfiguration(
//               backgroundColor: theme.linkPreviewOutgoingChatColor,
//               bodyStyle: theme.outgoingChatLinkBodyStyle,
//               titleStyle: theme.outgoingChatLinkTitleStyle,
//             ),
//             receiptsWidgetConfig:
//             const ReceiptsWidgetConfig(showReceiptsIn: ShowReceiptsIn.all),
//             color: theme.outgoingChatBubbleColor,
//           ),
//           inComingChatBubbleConfig: ChatBubble(
//             linkPreviewConfig: LinkPreviewConfiguration(
//               linkStyle: TextStyle(
//                 color: theme.inComingChatBubbleTextColor,
//                 decoration: TextDecoration.underline,
//               ),
//               backgroundColor: theme.linkPreviewIncomingChatColor,
//               bodyStyle: theme.incomingChatLinkBodyStyle,
//               titleStyle: theme.incomingChatLinkTitleStyle,
//             ),
//             textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
//             onMessageRead: (message) {
//               /// send your message reciepts to the other client
//               debugPrint('Message Read');
//             },
//             senderNameTextStyle:
//             TextStyle(color: theme.inComingChatBubbleTextColor),
//             color: theme.inComingChatBubbleColor,
//           ),
//         ),
//         replyPopupConfig: ReplyPopupConfiguration(
//           backgroundColor: theme.replyPopupColor,
//           buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
//           topBorderColor: theme.replyPopupTopBorderColor,
//         ),
//         reactionPopupConfig: ReactionPopupConfiguration(
//           shadow: BoxShadow(
//             color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
//             blurRadius: 20,
//           ),
//           backgroundColor: theme.reactionPopupColor,
//         ),
//         messageConfig: MessageConfiguration(
//           messageReactionConfig: MessageReactionConfiguration(
//             backgroundColor: theme.messageReactionBackGroundColor,
//             borderColor: theme.messageReactionBackGroundColor,
//             reactedUserCountTextStyle:
//             TextStyle(color: theme.inComingChatBubbleTextColor),
//             reactionCountTextStyle:
//             TextStyle(color: theme.inComingChatBubbleTextColor),
//             reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
//               backgroundColor: theme.backgroundColor,
//               reactedUserTextStyle: TextStyle(
//                 color: theme.inComingChatBubbleTextColor,
//               ),
//               reactionWidgetDecoration: BoxDecoration(
//                 color: theme.inComingChatBubbleColor,
//                 boxShadow: [
//                   BoxShadow(
//                     color: isDarkTheme ? Colors.black12 : Colors.grey.shade200,
//                     offset: const Offset(0, 20),
//                     blurRadius: 40,
//                   )
//                 ],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//           imageMessageConfig: ImageMessageConfiguration(
//             margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//             shareIconConfig: ShareIconConfiguration(
//               defaultIconBackgroundColor: theme.shareIconBackgroundColor,
//               defaultIconColor: theme.shareIconColor,
//             ),
//           ),
//         ),
//         profileCircleConfig: const ProfileCircleConfiguration(
//           profileImageUrl: Data.profileImage,
//         ),
//         repliedMessageConfig: RepliedMessageConfiguration(
//           backgroundColor: theme.repliedMessageColor,
//           verticalBarColor: theme.verticalBarColor,
//           repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
//             enableHighlightRepliedMsg: true,
//             highlightColor: Colors.pinkAccent.shade100,
//             highlightScale: 1.1,
//           ),
//           textStyle: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 0.25,
//           ),
//           replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
//         ),
//         swipeToReplyConfig: SwipeToReplyConfiguration(
//           replyIconColor: theme.swipeToReplyIconColor,
//         ),
//       ),
//     );
//   }
//
//   void _onSendTap(String message,ReplyMessage replyMessage,MessageType messageType,) {
//     final id = int.parse(Data.messageList.last.id) + 1;
//     _chatController.addMessage(
//       Message(
//         id: id.toString(),
//         createdAt: DateTime.now(),
//         message: message,
//         sendBy: currentUser.id,
//         replyMessage: replyMessage,
//         messageType: messageType,
//       ),
//     );
//     // Future.delayed(const Duration(milliseconds: 300), () {
//     //   _chatController.initialMessageList.last.setStatus =
//     //       MessageStatus.undelivered;
//     // });
//     // Future.delayed(const Duration(seconds: 1), () {
//     //   _chatController.initialMessageList.last.setStatus = MessageStatus.read;
//     // });
//   }
//
//   void _onThemeIconTap() {
//     setState(() {
//       if (isDarkTheme) {
//         theme = LightTheme();
//         isDarkTheme = false;
//       } else {
//         theme = DarkTheme();
//         isDarkTheme = true;
//       }
//     });
//   }
// }
//
//
//
//


import 'package:example/face.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:ui';

import 'package:example/signup.dart';
import 'package:example/chat.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'home.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),routes:{
      "signup":(context)=>signup(),
      //"signin":(context)=>signin(),
      "home":(context)=>home(sendto: "sendto",sendto2: "sendto2"),
     // "chat":(context)=>chat(sendto:"sendto",message: "message",Id: "id",),
      "MyHomePage":(context)=>MyHomePage(title: '',),
      "face":(context) => face()
    },
      // home: chat(sendto: "sendto", message:" message", Id: "Id"),
      home: FirebaseAuth.instance.currentUser?.email.toString()=='null'?face():MyHomePage(title: 'Flutter Demo Home Page') ,
      // home: face(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var email,pass;
  var showpass=true;
  final auth=FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      //  FirebaseFirestore.instance.disableNetwork();
      FirebaseAuth.instance;
      print("/////////////////////////////////////");
      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
        // Here we take the value fr
      body:
      Center(
          child:Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(margin:EdgeInsets.all(10),child:
              Text("welcome babe to my app ",style:TextStyle(fontSize: 30,fontWeight: FontWeight.bold),)),


              Container( margin:EdgeInsets.all(30),child:
              Text("Sign in ",style:TextStyle(fontSize: 30,fontWeight: FontWeight.bold),)),

              Container( alignment: Alignment.centerLeft,margin: EdgeInsets.only(left: 10,),
                  child: Text("Email",style:TextStyle(fontSize: 20),)),


              Container( margin: EdgeInsets.all(8),
                  child: TextFormField(onChanged: (value) => email=value,cursorColor: Colors.indigo,
                      decoration:InputDecoration(border: OutlineInputBorder(borderRadius:BorderRadius.circular(20)),
                        hintText: "Enter your email",
                      ))),

              Container( alignment: Alignment.centerLeft,margin: EdgeInsets.only(left: 10,),
                  child: Text("Password",style:TextStyle(fontSize: 20),)),


              Container( margin: EdgeInsets.all(8),
                  child: TextFormField(onChanged: (value) => pass=value,cursorColor: Colors.indigo,obscureText:showpass,
                      decoration:InputDecoration(suffixIcon: IconButton(onPressed: () async{

                        //                   var x= await Firebase.app().options;
                        //                   var c=await FirebaseFirestore.instance.collection("chats");
                        //                   try{
                        //                      await c.snapshots().listen((value) {
                        //               value.docs.forEach((element) {
                        //                   print("-------------");
                        //                            print(element.data());
                        // });
                        //
                        // });
                        // }catch(e){print("ERORRRRR:$e");}
                        //                 //  print(x);
                        //                   setState(() {
                        //                   showpass=false;});

                      }, icon:Icon(Icons.password)),border: OutlineInputBorder(borderRadius:BorderRadius.circular(20)),
                        hintText: "Enter your Password",
                      ))),

              ElevatedButton(onPressed:() async {
               var user=await auth.signInWithEmailAndPassword(email: email, password: pass);
                try {
                  final credential = await auth.signInWithEmailAndPassword(email: email, password: pass);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    print('Wrong password provided for that user.');
                    }}
                  print("-------------");
                print("email: "+"$email");
                print("pass: "+"$pass");
                if(user!=null){
                  Navigator.of(context).pushNamed("face");
                }
                else{
                  Get.snackbar("Erorr","Please fill out this fields",backgroundColor: Colors.red,colorText: Colors.white);
                }
              }
                  ,child:Text("Sign in")
                  ),
              Row( mainAxisAlignment:MainAxisAlignment.center,children: [Text("Don't have an account?"),
                TextButton(onPressed: ()async {
                  print("u dont have acc");
                   Navigator.of(context).pushNamed("signup");
                },
                    child: Text("Sign up",style:TextStyle(fontWeight: FontWeight.bold),))],),

            ],
          )
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
