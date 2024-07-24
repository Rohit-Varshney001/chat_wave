import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_wave/Pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_manager/flutter_ringtone_manager.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../Controller/status_controller.dart';
import '../Models/user_profile.dart';
import '../Services/database_service.dart';
import '../Widgets/chat_tile.dart';
import 'audio_call_navigator.dart';
import 'call_navigator.dart';
import 'chat_page.dart';
import 'package:vibration/vibration.dart';

class AddedUsersPage extends StatefulWidget {
  late String myId;
  AddedUsersPage({super.key, required this.myId});

  @override
  State<AddedUsersPage> createState() => _AddedUsersPageState();
}

class _AddedUsersPageState extends State<AddedUsersPage> {
  late final DatabaseService _databaseService = DatabaseService();
  late UserProfile currUserLogin;
  late StatusController _statusController;
  late OverlayEntry _overlayEntry;

  List<UserProfile>? _users;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _statusController = StatusController(widget.myId);
    _fetchAddedUsersChatsList();

    _databaseService.getCallsNotification().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        if (doc['isVideoCall']) {
          _showCallNotification(doc['callerName'], doc['callerPic'],
              doc['callerUid'], doc['isVideoCall']); // Replace with the actual image URL
          print("Video Calling...");
        } else {
          print("Audio Calling...");
          _showCallNotification(
              doc['callerName'],
              doc['callerPic'],
              doc['callerUid'],
              doc['isVideoCall']); // Replace with the actual image URL
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAddedUsersChatsList();
  }

  Future<void> _fetchAddedUsersChatsList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final users = await _databaseService.getUsersWithChats();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (error) {
      print("Error fetching users: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCallNotification(
      String callerName, String imageUrl, String callerId, bool isVideoCall) {
    _overlayEntry =
        _createOverlayEntry(callerName, imageUrl, callerId, isVideoCall);
    Overlay.of(context).insert(_overlayEntry);
    Vibration.vibrate(pattern: [
      500,
      1500,
      500,
      1500,
      500,
      1500,
      500,
      1500,
      500,
      1500,
      500,
      1500,
      500,
      1500,
      500,
      1500,
      500,
      1500,
      500,
      1500
    ]);
    FlutterRingtonePlayer.playRingtone();
    Future.delayed(const Duration(seconds: 20), () {
      Vibration.cancel(); // Stop the vibration
      FlutterRingtonePlayer.stop();
      _overlayEntry.remove();
    });
  }

  OverlayEntry _createOverlayEntry(
      String callerName, String imageUrl, String callerId, bool isVideoCall) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(imageUrl),
                    radius: 20.0,
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Incoming Call",
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      ),
                      Text(
                        callerName,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle decline action
                      // _databaseService.endCall(call);
                      Vibration.cancel(); // Stop the vibration
                      FlutterRingtonePlayer.stop();
                      // _databaseService.endCall(newCall);

                      _overlayEntry.remove();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      "Decline",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String callId = _databaseService.GenerateChatId(
                          uid1: currUserLogin.uid!, uid2: callerId);
                      // Handle accept action
                      if (isVideoCall) {
                        print("callid = " + callId);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VideoCallPage(
                                callID: callId,
                                userId: currUserLogin.uid!,
                                imageURL1: currUserLogin.pfpURL!,
                                imageURL2: imageUrl)));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AudioCallPage(
                                callID: callId,
                                userId: currUserLogin.uid!,
                                imageURL1: currUserLogin.pfpURL!,
                                imageURL2: imageUrl)));
                      }

                      _overlayEntry.remove();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "Accept",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

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
        ),
        body: _buildUi(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomePage()));
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ));
  }

  Widget _buildUi() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchAddedUsersChatsList,
          child: _addedUsersChatsList(),
        ),
      ),
    );
  }

  Widget _addedUsersChatsList() {
    if (_users == null || _users!.isEmpty) {
      return const Center(child: Text("No users found"));
    }
    return ListView.builder(
      itemBuilder: (context, index) {
        UserProfile user = _users![index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ChatTile(
            isHomePage: true,
            userProfile: user,
            onTap: () async {
              // Show a loading indicator while performing asynchronous operations
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(child: CircularProgressIndicator());
                },
              );

              try {
                final chatExists = await _databaseService.checkChatExists(
                    widget.myId, user.uid!);

                if (!chatExists) {
                  await _databaseService.createNewChat(
                      widget.myId, user.uid!);
                }

                currUserLogin = (await _databaseService
                    .getCurrentUserProfile(widget.myId))!;

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
                  SnackBar(content: Text('An error occurred: $e')),
                );
              }
            },
            chatList: [],
          ),
        );
      },
      itemCount: _users!.length,
    );
  }
}
