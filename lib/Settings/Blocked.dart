import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/widgets/custombutton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../chatscreen.dart';
import '../models/SettingsProvider.dart';
import '../models/theme.dart';

class Blocked extends StatefulWidget {
  const Blocked({Key? key}) : super(key: key);

  @override
  State<Blocked> createState() => _BlockedState();
}

class _BlockedState extends State<Blocked>{

unblock_function(var email)async{
  await FirebaseFirestore.instance
      .collection("accounts")
      .doc("${auth.currentUser?.email}")
      .collection("Blocks").doc("$email").delete().then((value)async{
        await FirebaseFirestore.instance.collection("accounts").doc("${auth.currentUser?.email}").
    collection("mess").doc('${email}').update({"isblocked":false});
    print("donee");
  },);
}

  @override
  Widget build(BuildContext context) {
    var provide = Provider.of<SettingsProvider>(context);
    var theme = provide.isDarkTheme ? DarkTheme() : LightTheme();
    return Scaffold(
      backgroundColor: theme.backgroundhome,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
          }, icon:Icon(Icons.arrow_back_ios,color:theme.TextColor,)),
        backgroundColor: theme.backgroundhome,
        title: Text(
          'Blocked',
          style: TextStyle(
            color: theme.TextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("accounts")
            .doc("${FirebaseAuth.instance.currentUser?.email}")
            .collection("Blocks")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                children: [
                  SizedBox(height: 150),
                  Image.asset("image/block.png", height: 180),
                  SizedBox(height: 10),
                  Text(
                    "You’re currently not blocking anyone",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.TextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Need to block or report someone? Go to the profile of the person you want to block and select “Block user”.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:provide.isDarkTheme?Colors.white60:Colors.black45,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }
          var data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var document = data[index].data() as Map<String, dynamic>;
              return ListTile(
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.outgoingChatBubbleColor
                  ),
                    onPressed: (){
                      unblock_function(data[index].id);
                }, child:Text("Unblock",style: TextStyle(fontSize:16,color:Colors.white,
                ),)),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(document['photo']),
                ),
                title: Text(
                  document['name'],
                  style: TextStyle(color: theme.TextColor, fontSize: 20),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
