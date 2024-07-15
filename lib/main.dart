import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/face.dart';
import 'package:example/messages.dart';
import 'package:example/auth/auth.dart';
import 'package:example/models/SettingsProvider.dart';
import 'package:example/models/theme.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'models/sql.dart';
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.', // description
  importance: Importance.high,
);
var fcmToken;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
   androidProvider: AndroidProvider.playIntegrity, // required for web
  );

  fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCMToken \n$fcmToken");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
  print(notificationsEnabled);
   if(notificationsEnabled){
     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
       print('Got a message whilst in the foreground!');
       print('Message data: ${message.data}');

       if (message.notification != null) {
         RemoteNotification notification = message.notification!;
         Get.snackbar("${notification.title ?? 'No Title'}","${notification.body ?? 'No Body'}",);
         print('Message also contained a notification:');
         print('Title: ${notification.title}');
         print('Body: ${notification.body}');
       }
     });
     await FirebaseMessaging.instance.setAutoInitEnabled(true);

     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
     await send_notification();
   }
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  runApp(ChangeNotifierProvider(create: (context) =>SettingsProvider(),child:const MyApp(),));
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

send_notification()async{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission:\n \n \n  ${settings.authorizationStatus}\n \n \n');
}
var auth=FirebaseAuth.instance;
getdata()async{
  var query = FirebaseFirestore.instance
      .collection("accounts")
      .doc("${auth.currentUser!.email}")
      .collection("mess")
      .doc("doha@gmail.com")
      .collection("chat")
      .orderBy('Time', descending: false)
      .limitToLast(1);

  var querySnapshot = await query.get();
  if (querySnapshot.docs.isNotEmpty) {
    var lastMessage = querySnapshot.docs.first;
    print("Last document data: ${lastMessage.data()}");
  } else {
    print("No documents found.");
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',debugShowCheckedModeBanner: false,
      home: MyHomePage() ,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var email,pass;
  var showpass=true;
  final _auth=FirebaseAuth.instance;
  @override

  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async {
    await Firebase.initializeApp();
    getSharedPrefsData();
  }

  void getSharedPrefsData() async {
    var provider = Provider.of<SettingsProvider>(context, listen: false);
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    var isDark = sharedPrefs.getBool("isDark") ?? false;
    provider.change_theme(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
           FirebaseFirestore.instance
              .collection('accounts')
              .doc('${_auth.currentUser!.email}')
              .update({'token': '$fcmToken'});
          return messages("${_auth.currentUser!.uid}");
        } else {
          // User is not logged in
          return const auth_p();
        }
      },
    );
  }
}
// void configureFirebaseListeners(BuildContext context) {
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
//     if (!settingsProvider.notificationsEnabled) {
//       print('Notifications are disabled');
//       return;
//     }
//
//     print('Got a message whilst in the foreground!');
//     print('Message data: ${message.data}');
//
//     if (message.notification != null) {
//       RemoteNotification notification = message.notification!;
//       Get.snackbar("${notification.title ?? 'No Title'}","${notification.body ?? 'No Body'}",);
//       print('Message also contained a notification:');
//       print('Title: ${notification.title}');
//       print('Body: ${notification.body}');
//
//       // You can display a custom alert dialog or update the UI directly here
//       // For example, using a simple dialog:
//     }
//   });
// }