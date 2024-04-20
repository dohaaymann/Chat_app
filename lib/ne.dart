import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ne extends StatelessWidget {

  ne();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Firestore Data Example'),
        ),
        body: FirestoreData(),
      ),
    );
  }
}
var auth=FirebaseAuth.instance;
var user=FirebaseFirestore.instance.collection("${auth.currentUser?.uid}").doc().collection("mess");
class FirestoreData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:user.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          // Data is fetched successfully
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final doc = data.docs[index];
              // Print data from the document
              print('Document ID: ${doc.id}');
              print('Data: ${doc.data()}');

              // Display data in a ListTile (or any other widget)
              return ListTile(
                title: Text('Document ID: ${doc.id}'),
                subtitle: Text('Data: ${doc.data().toString()}'),
              );
            },
          );
        }
      },
    );
  }
}