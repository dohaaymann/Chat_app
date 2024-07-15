import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:example/Constant/colors.dart';
import 'package:example/widgets/customtext.dart';
import 'package:example/widgets/database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custombutton.dart';

class signup extends StatefulWidget {
  const signup({Key? key}) : super(key: key);

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final sname = TextEditingController();
  final semail = TextEditingController();
  final spass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final database _data = database();
  bool waitt = true;
  var auth = FirebaseAuth.instance;
  final fcmToken = FirebaseMessaging.instance.getToken();
  File? selectedImage;
  var photo, filePath;
  final picker = ImagePicker();
  var result;
  var pic, Url;
  _pickFile(var res) async {
    if (res == null) return;
    try {
      var store = FirebaseStorage.instance.ref();
      var rName = Random().nextInt(100000);
      final pathh = "files/$rName${res.name}";
      final file = File(res.path!);
      final upload = await store.child(pathh).putFile(file);
      Url = await store.child(pathh).getDownloadURL();
    } catch (e) {
      print("ERROR: $e");
    }
  }
  Future<void> _pickImageFromGallery() async {
    try {
      result = await picker.pickImage(source: ImageSource.gallery);
      if (result != null) {
        setState(() {
          selectedImage = File(result.path);
          filePath = selectedImage;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
  Future<void> signup() async {
    if (_formKey.currentState!.validate()) {
    try {
      var user = await auth.createUserWithEmailAndPassword(
        email: semail.text,
        password: spass.text,
      );
      print("------Account created-------");
      print("Email: ${semail.text}");
      print("Password: ${spass.text}");

      if (mounted) {
        setState(() {
          waitt = !waitt;
        });
        await _pickFile(result);
        await auth.currentUser!.updateDisplayName(sname.text);
        await auth.currentUser!.updatePhotoURL(
            selectedImage== null?"https://firebasestorage.googleapis.com/v0/b/base-8c0bc.appspot.com/o/files%2F245471000000037.jpg?alt=media&token=bcf1b423-fbab-4673-92df-c8307e59c930"
        :"$Url");
        await FirebaseFirestore.instance
            .collection("accounts")
            .doc("${semail.text}")
            .set({
          "name": sname.text,
          "password": spass.text,
          "bio": 'Busy',
          "token":'$fcmToken',
          "photo":selectedImage== null?
          "https://firebasestorage.googleapis.com/v0/b/base-8c0bc.appspot.com/o/files%2F245471000000037.jpg?alt=media&token=bcf1b423-fbab-4673-92df-c8307e59c930"
          :"$Url"
        });

        Future.delayed(const Duration(seconds:3), () {
          if (mounted) {
            Get.to(() => messages({"${FirebaseAuth.instance.currentUser!.uid}"}));
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Get.snackbar("Error", e.message ?? "An error occurred",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }}

  @override
  Widget build(BuildContext context) {
    return   LayoutBuilder(
        builder: (context, constraints) {
          return Column(
                    children: [
                      SizedBox(height:60),
                      Container(
          margin: EdgeInsets.only(left: 10, bottom: 5),
          alignment: Alignment.topLeft,
          child: Text(
            "Create\nAccount",
            style: TextStyle(
              fontFamily: "ProtestStrike-Regular",
              fontSize:40,
              color: Colors.white,
            ),
          ),),
                      Container(
                        margin: const EdgeInsets.only(top:10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius:60,
                              backgroundImage: selectedImage == null
                                  ?AssetImage("image/unkown.png") : FileImage(selectedImage!) as ImageProvider,
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(110,90, 20, 0),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius:15,
                                child: IconButton(
                                  onPressed: () {
                                    _pickImageFromGallery();
                                  },
                                  icon: const Icon(CupertinoIcons.camera_fill, size:15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              // SizedBox(height:60),
               Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: customtext("Name", sname),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                    child: customtext("Email", semail),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                    child: customtext("Password", spass),
                  ),
                  SizedBox(height: 20),
                  waitt
                      ? CustomButton(
                    text: "Signup",
                    onTap: () async {
                      await signup();
                    },
                    height: 50.0,
                    width: 150.0,
                  )
                      : CircularProgressIndicator(),
                ],
              ),
              ),
                      SizedBox(height:25,),
                      Text("Or signup using",style: TextStyle(color: Colors.black45),),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.facebook,color: Colors.blue,size:40,),
                          SizedBox(width: 10,),
            InkWell(
                onTap: () async {
                  final FirebaseAuth _auth = FirebaseAuth.instance;
                  try {
                    GoogleSignInAccount? googleSignInAccount =await GoogleSignIn().signIn();
                    GoogleSignInAuthentication? googleSignInAuthentication =await googleSignInAccount?.authentication;
                    AuthCredential credential = GoogleAuthProvider.credential(
                      accessToken: googleSignInAuthentication?.accessToken,
                      idToken: googleSignInAuthentication?.idToken,
                    );
                    print("--------");
                    await _auth.signInWithCredential(credential);
                    var authResult = await _auth.signInWithCredential(credential).then((value)async{
                      print('done');
                    });
                    var _user = authResult.user;
                    await FirebaseFirestore.instance
                        .collection("accounts")
                        .doc("${_user.email}")
                        .set({
                      "name": '${_user?.displayName}',
                      "password": spass.text,
                      "bio": 'Busy',
                      "token":'$fcmToken',
                      "photo":selectedImage== null?
                      "https://firebasestorage.googleapis.com/v0/b/base-8c0bc.appspot.com/o/files%2F245471000000037.jpg?alt=media&token=bcf1b423-fbab-4673-92df-c8307e59c930"
                          :"$Url"
                    });
                    assert(!_user!.isAnonymous);
                    assert(await _user?.getIdToken() != null);
                    var currentUser = await _auth.currentUser!;
                    assert(_user?.uid == currentUser.uid);
                    print("User Name: ${_user?.displayName}");
                    print("User Email ${_user?.email}");
                  } catch (r) {
                    print("ERRRRRRRRROR:$r");
                  }
                },
                child: Image.asset("image/google.png",height:40,))
                        ],
                      )

                    ]);
          }
    );
  }
}
