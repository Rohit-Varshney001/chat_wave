import 'package:chat_wave/Models/user_profile.dart';
import 'package:chat_wave/Pages/full%20screen%20profile.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

import '../Pages/chat_page.dart';
import '../Pages/login_page.dart';
import '../Pages/sign_up_page.dart';
import '../Services/check_user.dart';
import '../Services/database_service.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.userProfile, required this.onTap});

  final UserProfile userProfile;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    late final DatabaseService _databaseService = DatabaseService();
    final String myId = currUID ?? currentId ?? currentID2;

    return ListTile(
      dense: false,
      onTap: () {
        onTap();
      },
      leading: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Stack(
                  children: [
                    // Profile image
                    GestureDetector(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Image.network(
                          userProfile.pfpURL!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FullScreenImage(
                                    user_name: userProfile.name!,
                                    pfpURL: userProfile.pfpURL!)));
                      },
                    ),
                    Positioned(
                      top: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          userProfile.name!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                  child: Icon(
                                    size: 30,
                                    Icons.chat,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () async {
                                  UserProfile currUserLogin =
                                      (await _databaseService
                                          .getCurrentUserProfile(myId))!;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          chatUser: userProfile,
                                          currentUserProfile: currUserLogin,
                                        ),
                                      ));
                                },
                              ),
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                  child: Icon(
                                    size: 30,
                                    Icons.video_call_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  MotionToast.success(
                                    title: const Text(
                                      "Available Soon",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    position: MotionToastPosition.center,
                                    description: Text(
                                        "This feature will be available soon"),
                                  ).show(context);
                                },
                              ),
                            ]),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: CircleAvatar(
          radius: 30,
          backgroundImage: userProfile.pfpURL != null
              ? NetworkImage(userProfile.pfpURL!)
              : AssetImage('assets/images/blank.png') as ImageProvider,
          onBackgroundImageError: (exception, stackTrace) {
            print('Error loading image: $exception\nStack trace: $stackTrace');
          },
        ),
      ),
      title: Text(
        userProfile.name!,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
      ),
      subtitle: Text(
        "1 Messege",
        style: TextStyle(
          color: Colors.black45,
        ),
      ),
      trailing: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: Positioned(
          right: 10,
          top: 10,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              shape: BoxShape.circle,
            ),
            constraints: BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
            child: Text(
              '3  ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
