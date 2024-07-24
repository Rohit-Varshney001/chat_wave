import 'package:chat_wave/Services/database_service.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class StatusController extends WidgetsBindingObserver {
  final String id;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  StatusController(this.id) {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    print('App Life Cycle State $state');
    if(state == AppLifecycleState.inactive){
      print("====================Offline====================");
      await _firebaseFirestore.collection("users").doc(id).update({
          "status":"Offline",
      });
    }
    else if(state == AppLifecycleState.resumed){
      print("====================Online====================");
      await _firebaseFirestore.collection("users").doc(id).update({
        "status":"Online",
      });
    }
    // Additional code to handle app lifecycle changes
  }
}
