import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_wave/Controller/status_controller.dart';
import 'package:chat_wave/Models/user_profile.dart';
import 'package:chat_wave/Pages/added_users_page.dart';
import 'package:chat_wave/Pages/call_navigator.dart';
import 'package:chat_wave/Pages/chat_page.dart';
import 'package:chat_wave/Pages/sign_up_page.dart';
import 'package:chat_wave/Services/auth_service.dart';
import 'package:chat_wave/Services/database_service.dart';
import 'package:chat_wave/Widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../Services/check_user.dart';
import 'audio_call_navigator.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String myId = currUID ?? currentId ?? currentID2;
  late final DatabaseService _databaseService = DatabaseService();
  late UserProfile currUserLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Chat Wave",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this to the desired color
        ),
      ),
      body: _buildUi(),
    );
  }

  Widget _buildUi() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
        child: _chatsList(),
      ),
    );
  }

  Widget _chatsList() {
    return FutureBuilder<List<UserProfile>>(
      future: _databaseService.getUsersWithChats(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return const Center(
            child: Text("Unable to load data"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          List<UserProfile> usersWithChats = snapshot.data!;
          return StreamBuilder(
            stream: _databaseService.getUserProfiles(),
            builder: (context, snapshots) {
              if (snapshots.hasError) {
                print(snapshots.error);
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
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: [
                          ChatTile(
                            isHomePage: false,
                            userProfile: user,
                            onTap: () async {
                              // Show a loading indicator while performing asynchronous operations
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );

                              try {
                                final chatExists = await _databaseService
                                    .checkChatExists(myId, user.uid!);

                                if (!chatExists) {
                                  await _databaseService.createNewChat(
                                      myId, user.uid!);
                                }

                                currUserLogin = (await _databaseService
                                    .getCurrentUserProfile(myId))!;

                                // Close the loading indicator before navigating
                                Navigator.pop(context);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      chatUser: user,
                                      currentUserProfile: currUserLogin,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                // Handle errors if needed
                                Navigator.pop(
                                    context); // Close the loading indicator in case of an error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('An error occurred: $e')),
                                );
                              }
                            },
                            chatList: usersWithChats,
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: users.length,
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
