import 'dart:ui';
import 'package:example/auth/signup.dart';
import 'package:flutter/material.dart';

import '../Constant/colors.dart';
import 'login.dart';

class auth_p extends StatefulWidget {
  const auth_p({Key? key}) : super(key: key);

  @override
  State<auth_p> createState() => _authState();
}

class _authState extends State<auth_p> {
  @override
  bool login_or_signup=true;
  Widget build(BuildContext context) {
    return PopScope(canPop: false,
      child: Scaffold(resizeToAvoidBottomInset: false,backgroundColor:Color(0xff291135),
          body:
          Container(
            decoration:const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("image/back/backg.jpg"),colorFilter: ColorFilter.mode(Colors.black87,BlendMode.darken),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(left:10, right:10),
              child:
              BackdropFilter(filter: ImageFilter.blur(sigmaX:2.0,sigmaY:2.0 ),child:
              Column(
                children: [
                  login_or_signup?login():signup(),
                  Expanded(
                    child: Column(mainAxisAlignment: MainAxisAlignment.end,
                      children: [ Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          login_or_signup?const Text(
                            "Don't have an account?..Switch",
                            style: TextStyle(fontSize:18,color: Colors.white),
                          ):const Text(
                            "Already have an account?..Switch",
                            style: TextStyle(fontSize:18,color: Colors.white),
                          ),
                        ],
                      ),
                        Container(
                          decoration:ShapeDecoration(color:accentPurpleColor,shape: StadiumBorder()),width: double.infinity,height:50,
                          margin: EdgeInsets.only(right:12,left: 12,bottom: 12,top:10),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(onTap: (){
                                  setState(() {
                                    login_or_signup=true;  //call login page
                                  });
                                },
                                  child: Container(alignment:Alignment.center  ,
                                      decoration:ShapeDecoration(shape: StadiumBorder(),color:login_or_signup? pinkyy:accentPurpleColor),
                                      child: Text("Login",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),)),
                                ),
                              ), Expanded(
                                child: InkWell(onTap: (){
                                  setState(() {
                                    login_or_signup=false;  //call signup page
                                  });
                                },
                                  child: Container(alignment:Alignment.center,
                                      decoration:ShapeDecoration(shape: StadiumBorder(),color:!login_or_signup? pinkyy:accentPurpleColor),
                                      child: Text("Signup",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),)),
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
          )),
    );
  }
}
