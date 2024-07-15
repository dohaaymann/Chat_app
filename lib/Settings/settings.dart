import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/Settings/Blocked.dart';
import 'package:example/Settings/DeleteAccount.dart';
import 'package:example/auth/auth.dart';
import 'package:example/auth/create_pass.dart';
import 'package:example/chatscreen.dart';
import 'package:example/models/sql.dart';
import 'package:example/ne.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Constant/colors.dart';
import '../auth/change_password.dart';
import '../face.dart';
import '../messages.dart';
import '../models/SettingsProvider.dart';
import '../models/theme.dart';
import 'edit_profile.dart';

class settings extends StatefulWidget {
  final String name;
  final String photo;

  settings(this.name, this.photo);

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  List<String> options = ['Blocked Users', 'Delete Account'];
  FirebaseAuth auth = FirebaseAuth.instance;
  late String photo;
  late String name;
  bool notifyEnable = true;
  bool wait = false;
var sql=SQLDB();
  @override
  void initState() {
    super.initState();
    photo = auth.currentUser?.photoURL ?? 'https://example.com/default_photo.png';
    name = auth.currentUser?.displayName ?? 'No Name';
    print("settings////////////////page");
    getData();
  }

  Future<void> getData() async {
    setState(() {
      photo = auth.currentUser?.photoURL ?? 'https://example.com/default_photo.png';
      name = auth.currentUser?.displayName ?? 'No Name';
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var provider = Provider.of<SettingsProvider>(context);
    var theme = provider.isDarkTheme ? DarkTheme() : LightTheme();

    return Scaffold(
      resizeToAvoidBottomInset:false,
      backgroundColor: theme.backgroundhome,
      body: Stack(
        children: [
          ClipPath(
            clipper: OvalBottomBorderClipper(),
            child: Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: !provider.isDarkTheme
                    ? LinearGradient(colors: [
                  Color(0xff543863),
                  Color(0xff84aa9b)
                      // Color(0xff84aa9b),
                      // Color(0xff84aa9b),
                  // Color(0xffdadc79)
                ])
                    : LinearGradient(colors: [Color(0xff7B7794), Color(0xff231E73)]),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 85),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Icon(Icons.settings_rounded, size: 45, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Settings", style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(12),
              height: height - 150,
              decoration: BoxDecoration(color: theme.backgroundhome, borderRadius: BorderRadius.circular(25)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(photo),
                              ),
                              FullScreenWidget(
                                disposeLevel: DisposeLevel.High,
                                child: Hero(
                                  tag: "null",
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.network(
                                      photo,
                                      fit: BoxFit.cover,
                                      height: 60,
                                      width: 60,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10),
                          Text(name, style: TextStyle(color: theme.textFieldTextColor, fontWeight: FontWeight.bold, fontSize: 20)),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.black54),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Text("Account Settings", style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          InkWell(
                            onTap: () {
                              Get.to(() => edit_profile());
                            },
                            child: Container(
                              height: 50,
                              child: Row(
                                children: [
                                  Text("Profile", style: TextStyle(color: theme.textFieldTextColor, fontWeight: FontWeight.w500, fontSize: 22)),
                                  Spacer(),
                                  Icon(Icons.arrow_forward_ios, size: 20, color: theme.textFieldTextColor),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // Get.to(() => newpass());
                              Get.to(() => change_pass());
                            },
                            child: Container(
                              height: 50,
                              child: Row(
                                children: [
                                  Text("Change Password", style: TextStyle(color: theme.textFieldTextColor, fontWeight: FontWeight.w500, fontSize: 22)),
                                  Spacer(),
                                  Icon(Icons.arrow_forward_ios, size: 20, color: theme.textFieldTextColor),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text("Notifications", style: TextStyle(color: theme.textFieldTextColor, fontWeight: FontWeight.w500, fontSize: 22)),
                              Spacer(),
                              Switch(
                                value: provider.NotificationsEnabled,
                                onChanged: (value) async {
                                  provider.setNotificationsEnabled(value);
                                  setState(() {
                                    print("${provider.NotificationsEnabled}");
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Dark mode", style: TextStyle(color: theme.textFieldTextColor, fontWeight: FontWeight.w500, fontSize: 22)),
                              Spacer(),
                              Switch(
                                value: provider.isDarkTheme,
                                onChanged: (value) async {
                                   // sql.update_isdark(value);
                                  provider.setMode(value);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 5),
                            child: Text("Security", style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          for (int i = 0; i < options.length; i++)
                            InkWell(
                              onTap: () {
                                if (options[i] == 'Blocked Users') {
                                  Get.to(() => Blocked());
                                  // Get.to(() => auth_p());
                                } else {
                                  Get.to(() => DeleteAccount(name, auth.currentUser!.email!, photo));
                                }
                              },
                              child: Container(
                                height: 50,
                                child: Row(
                                  children: [
                                    Text(options[i], style: TextStyle(color: theme.textFieldTextColor, fontWeight: FontWeight.w500, fontSize: 22)),
                                    Spacer(),
                                    Icon(Icons.arrow_forward_ios, size: 20, color: theme.textFieldTextColor),
                                  ],
                                ),
                              ),
                            ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: InkWell(
                                    onTap: () async {
                                      await auth.signOut();

                                      setState(() {
                                        wait = !wait;
                                      });
                                  Future.delayed(const Duration(seconds:3), () {
                                  FirebaseFirestore.instance
                                          .collection('accounts')
                                          .doc(auth.currentUser!.email)
                                          .update({
                                        'token': ''
                                      }).then((value) async {
                                        await auth.signOut();
                                        Get.to(() => auth_p());

                                      });});
                                    },
                                    child: Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey[350]),
                                      child: Text("Sign Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 22)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Get.to(() => messages({"${FirebaseAuth.instance.currentUser!.uid}"}));
                  },
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                SizedBox(width: 100),
              ],
            ),
          ),
           Visibility(visible: wait,
             child:
          Container(color: Colors.white54,
              child: Center(child: Container(
                            width:50,height: 50,
                              child: CircularProgressIndicator())), ),
           ),
        ],
      ),
    );
  }
}
