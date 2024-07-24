import 'package:cached_network_image/cached_network_image.dart';
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
  ChatTile({
    super.key,
    required this.userProfile,
    required this.onTap,
    required this.isHomePage,
    required this.chatList,
  });

  final bool isHomePage;
  final UserProfile userProfile;
  final Function onTap;
  final List<dynamic> chatList;

  bool _isChatUser() {
    return chatList.any((user) => user.uid == userProfile.uid);
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService _databaseService = DatabaseService();
    final String myId = currUID ?? currentId ?? currentID2;
    UserProfile? currUserLogin;

    return ListTile(
      dense: false,
      onTap: () {
        onTap();
      },
      leading: GestureDetector(
        onTap: () {
          _showProfileDialog(context);
        },
        child: CircleAvatar(
          radius: 30,
          backgroundImage: userProfile.pfpURL != null
              ? CachedNetworkImageProvider(userProfile.pfpURL!)
              : AssetImage('assets/images/blank.png') as ImageProvider,
          onBackgroundImageError: (exception, stackTrace) {
            print('Error loading image: $exception\nStack trace: $stackTrace');
          },
        ),
      ),
      title: Text(
        userProfile.name!,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        "1 Message",
        style: TextStyle(
          color: Colors.black45,
        ),
      ),
      trailing: isHomePage
          ? _buildMessageCount()
          : _buildAddButton(context, _databaseService, myId, currUserLogin),
    );
  }

  Widget _buildMessageCount() {
    return Container(
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
    );
  }

  Widget _buildAddButton(BuildContext context, DatabaseService databaseService, String myId, UserProfile? currUserLogin) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ).copyWith(
        elevation: ButtonStyleButton.allOrNull(0),
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (_isChatUser()) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            }
            return Theme.of(context).colorScheme.primary;
          },
        ),
      ),
      onPressed: _isChatUser()
          ? () async {
        // Show a loading indicator while performing asynchronous operations
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        try {
          final chatExists = await databaseService.checkChatExists(myId, userProfile.uid!);

          if (!chatExists) {
            await databaseService.createNewChat(myId, userProfile.uid!);
          }

          // Fetch current user profile
          currUserLogin = await databaseService.getCurrentUserProfile(myId);

          // Close the loading indicator before navigating
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                chatUser: userProfile,
                currentUserProfile: currUserLogin!,
              ),
            ),
          );
        } catch (e) {
          // Handle errors if needed
          Navigator.pop(context); // Close the loading indicator in case of an error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      }
          : null, // Disables the button if _isChatUser() returns false
      child: const Text(
        "Add",
        style: TextStyle(fontWeight: FontWeight.w400,color: Colors.white),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Stack(
            children: [
              GestureDetector(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: CachedNetworkImage(
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    imageUrl: userProfile.pfpURL!,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                        user_name: userProfile.name!,
                        pfpURL: userProfile.pfpURL!,
                      ),
                    ),
                  );
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
                      _buildChatButton(context),
                      _buildVideoCallButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return GestureDetector(
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
        final DatabaseService _databaseService = DatabaseService();
        final String myId = currUID ?? currentId ?? currentID2;
        final currUserLogin = await _databaseService.getCurrentUserProfile(myId);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatUser: userProfile,
              currentUserProfile: currUserLogin!,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoCallButton(BuildContext context) {
    return GestureDetector(
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
          description: Text("This feature will be available soon"),
        ).show(context);
      },
    );
  }
}
