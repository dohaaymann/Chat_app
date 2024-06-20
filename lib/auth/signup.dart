import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:example/Constant/colors.dart';
import 'package:example/widgets/customtext.dart';
import 'package:example/widgets/database.dart';
import '../widgets/custombutton.dart';

class signup extends StatefulWidget {
  const signup({Key? key}) : super(key: key);

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  final sname = TextEditingController();
  final semail = TextEditingController();
  final spass = TextEditingController();
  final database _data = database();
  bool waitt = true;
  var auth = FirebaseAuth.instance;

  Future<void> signup() async {
    if (semail.text.isEmpty || spass.text.isEmpty || sname.text.isEmpty) {
      print("Empty fields");
      if (mounted) {
        Get.snackbar("Error", "Please fill out the fields",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      return;
    }

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

        await auth.currentUser!.updateDisplayName(sname.text);
        await auth.currentUser!.updatePhotoURL(
            "https://firebasestorage.googleapis.com/v0/b/base-8c0bc.appspot.com/o/files%2F245471000000037.jpg?alt=media&token=bcf1b423-fbab-4673-92df-c8307e59c930"
        );

        await FirebaseFirestore.instance
            .collection("accounts")
            .doc("${semail.text}")
            .set({
          "name": sname.text,
          "password": spass.text,
          "bio": 'Busy',
          "photo":
          "https://firebasestorage.googleapis.com/v0/b/base-8c0bc.appspot.com/o/files%2F245471000000037.jpg?alt=media&token=bcf1b423-fbab-4673-92df-c8307e59c930",
        });

        Future.delayed(const Duration(seconds: 5), () {
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 120),
        Container(
          margin: EdgeInsets.only(left: 10, bottom: 5),
          alignment: Alignment.topLeft,
          child: Text(
            "Let's Get Started",
            style: TextStyle(
              fontFamily: "ProtestStrike-Regular",
              fontSize: 40,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10, bottom: 5),
          alignment: Alignment.topLeft,
          child: Text(
            "Create an account",
            style: TextStyle(
              fontFamily: "ProtestStrike-Regular",
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 80),
        Column(
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
      ],
    );
  }
}
