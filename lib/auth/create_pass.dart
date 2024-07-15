import 'package:example/widgets/custombutton.dart';
import 'package:example/widgets/customtext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/SettingsProvider.dart';
import '../models/theme.dart';

class newpass extends StatefulWidget {
  const newpass({Key? key}) : super(key: key);

  @override
  State<newpass> createState() => _newpassState();
}

class _newpassState extends State<newpass> {
  @override
  var _pass=TextEditingController();
  var _cpass=TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    var provider = Provider.of<SettingsProvider>(context);
  var theme = provider.isDarkTheme ? DarkTheme() : LightTheme();
    return Builder(
      builder: (context) {
        return Scaffold(
          backgroundColor:theme.backgroundhome,
          appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(onPressed: (){
                Navigator.of(context).pop();
              }, icon:Icon(Icons.arrow_back_ios,color:theme.TextColor,)),
              backgroundColor: theme.backgroundhome,),
          body: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Column(
                  children: [
                    Image.asset("image/lock.png",height: 150,),
                    SizedBox(height:10,),
                    Text("Create new password",style: TextStyle(color:theme.TextColor,fontWeight:FontWeight.bold,fontSize:30),),
                    Text("Please enter a new password. Ensure that your new password is different from the previous one for better security.",
                      textAlign: TextAlign.center,style: TextStyle(color:provider.isDarkTheme?Colors.white60:Colors.black54,fontSize:16),),
                  ],
                )),

                SizedBox(height:25,),
                Text("New Password",style:TextStyle(color:theme.TextColor,fontWeight: FontWeight.bold,fontSize: 20,),),
                customtext("Password", _pass),
                SizedBox(height:30,),
                Text("Confirm Password",style:TextStyle(color:theme.TextColor,fontWeight: FontWeight.bold,fontSize: 20,),),
                customtext("Confirm password", _cpass,passwordController:_pass),
                // CustomButton(onTap: (){}, text:,height:50.0,width:160.0)
                 Spacer(),
                Center(
              child: CustomButton(onTap: ()async{
                if (_formKey.currentState!.validate()){
                  try{
                    final auth = await FirebaseAuth.instance;
                    auth.currentUser!.updatePassword(_pass.text);
                  }catch(e){
                    print(e);
                  }
                }
              }, text:"Create",height: 40.0,),
            )
              ],
            ),
          ),
        );
      }
    );
  }
}
