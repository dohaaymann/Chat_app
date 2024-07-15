import 'dart:ui';
import 'package:example/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

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
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          // backgroundColor:Color(0xff291135),
          body:
          Container(
            // decoration:const BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage("image/back/backg.jpg"),colorFilter: ColorFilter.mode(Colors.black87,BlendMode.darken),
            //     fit: BoxFit.cover,
            //   ),
            // ),
            child: Stack(
              children: [
                Container(
                  color:
                  Color(0xff84aa9b),height:150,
                ),
                Visibility(
                  visible:login_or_signup,
                  child: RotationTransition(//yellow part
                    turns: new AlwaysStoppedAnimation(70/ 360),
                    child: Container(
                      margin: EdgeInsets.only(left:40,top:150),
                     height:300,width:250,
                      decoration:const BoxDecoration(
                        color: Color(0xff543863),
                        // Color(0xff543863),
                        // Color(0xff4CBF87),
                        borderRadius: BorderRadius.all(Radius.circular(100)
                        ),
                    )),
                  ),
                ),
                RotationTransition(
                  turns: new AlwaysStoppedAnimation(-20/ 360),
                  child: Container(
                    // margin: EdgeInsets.only(top:20),
                    height: login_or_signup?300:260,width: double.infinity,
                    decoration:const BoxDecoration(
                      color: Color(0xff84aa9b),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(200)
                      ),
                      // gradient:
                      //      LinearGradient(
                      //   tileMode: TileMode.mirror,
                      //   colors: [
                      //     Color(0xff7B7794),
                      //     Color(0xff231E73),
                      //   ],
                      // ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left:10, right:10),
                  child:
                  Column(
                    children: [
                      login_or_signup?login():signup(),
                      Expanded(
                        child: Column(mainAxisAlignment: MainAxisAlignment.end,
                          children: [ Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              login_or_signup?const Text(
                                "Don't have an account?..Switch",
                                style: TextStyle(fontSize:18,color: Colors.black),
                              ):const Text(
                                "Already have an account?..Switch",
                                style: TextStyle(fontSize:18,color: Colors.black),
                              ),
                            ],
                          ),
                            Container(
                              decoration:ShapeDecoration(color:Color(0xff543863),shape: StadiumBorder()),width: double.infinity,height:50,
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
                                          decoration:ShapeDecoration(shape: StadiumBorder(),color:login_or_signup?Color(0xff84aa9b):Color(0xff543863)),
                                          child: Text("Login",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),)),
                                    ),
                                  ), Expanded(
                                    child: InkWell(onTap: (){
                                      setState(() {
                                        login_or_signup=false;  //call signup page
                                      });
                                    },
                                      child: Container(alignment:Alignment.center,
                                          decoration:ShapeDecoration(shape: StadiumBorder(),color:!login_or_signup?Color(0xff84aa9b):Color(0xff543863)),
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
              ],
            ),
          )),
    );
  }
}
