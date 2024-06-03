import 'package:chat_wave/Models/user_profile.dart';
import 'package:chat_wave/Pages/chat_page.dart';
import 'package:chat_wave/Pages/sign_up_page.dart';
import 'package:chat_wave/Services/auth_service.dart';
import 'package:chat_wave/Services/database_service.dart';
import 'package:chat_wave/Widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../Services/check_user.dart';
import 'login_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String myId = currUID ?? currentId ?? currentID2;
  late final DatabaseService _databaseService = DatabaseService();
  late AuthService _authService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Chat Wave",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25,color: Colors.white),
        ),
      ),
      body: _buildUi(),
    );
  }

  Widget _buildUi() {
    return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
          child: _chatsList(),
    ));
  }

  Widget _chatsList() {
    return StreamBuilder(
        stream: _databaseService.getUserProfiles(),
        builder: (context, snapshots) {
          if (snapshots.hasError) {
            return const Center(
              child: Text("Unable to load data"),
            );
          }
          if (snapshots.hasData && snapshots.data != null) {
            final users = snapshots.data!.docs;
            return ListView.builder(
              itemBuilder: (context, index) {
                UserProfile user = users[index].data();
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: ChatTile(
                      userProfile: user,
                      onTap: () async{
                        final chatExists = await _databaseService.checkChatExists(myId, user.uid!);

                        if(!chatExists){
                            await _databaseService.createNewChat(myId, user.uid!);
                        }

                        UserProfile currUserLogin = (await _databaseService.getCurrentUserProfile(myId))!;


                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatPage(chatUser: user, currentUserProfile: currUserLogin,),));

                      }
                  ),
                );
              },
              itemCount: users.length,
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
