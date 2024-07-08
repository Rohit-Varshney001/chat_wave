import 'dart:io';

import 'package:chat_wave/Models/messages.dart';
import 'package:chat_wave/Models/user_profile.dart';
import 'package:chat_wave/Pages/sign_up_page.dart';
import 'package:chat_wave/Services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../Models/chats.dart';
import '../Services/check_user.dart';
import '../Services/storage_service.dart';
import 'full screen profile.dart';
import 'login_page.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  final UserProfile currentUserProfile;

  const ChatPage(
      {super.key, required this.chatUser, required this.currentUserProfile});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var ID = currUID ?? currentId ?? currentID2;
  ChatUser? currentUser, otherUSer;
  final ImagePicker picker = ImagePicker();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    currentUser = ChatUser(
        id: widget.currentUserProfile.uid!,
        firstName: widget.currentUserProfile.name!);

    otherUSer = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100, // Set a fixed width for the leading section
        leading: Row(
          children: [
            BackButton(color: Colors.white,),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(
                      user_name: widget.chatUser.name!,
                      pfpURL: widget.chatUser.pfpURL!,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20.0, // Set the desired radius here
                backgroundImage: widget.chatUser.pfpURL != null
                    ? NetworkImage(widget.chatUser.pfpURL!)
                    : AssetImage('assets/images/blank.png') as ImageProvider,
                onBackgroundImageError: (exception, stackTrace) {
                  print(
                      'Error loading image: $exception\nStack trace: $stackTrace');
                },
              ),
            ),
          ],
        ),
        title: Text(
          widget.chatUser.name!,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(currentUser!.id, otherUSer!.id),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshots.hasError) {
          return Center(child: Text('Error: ${snapshots.error}'));
        } else if (!snapshots.hasData || snapshots.data == null) {
          return Center(child: Text('No data available'));
        } else {
          Chat? chat = snapshots.data!.data();
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = _generateChatMessagesList(chat.messages!);
          }
          return DashChat(
            messageOptions: const MessageOptions(
              showOtherUsersAvatar: true,
              showTime: true,
            ),
            inputOptions: InputOptions(
              alwaysShowSend: true,
              trailing: [_mediaMessageButton()],
            ),
            currentUser: currentUser!,
            onSend: _sendMessage,
            messages: messages,
          );
        }
      },
    );
  }


  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));

        await _databaseService.sendChatMessage(
            currentUser!.id, otherUSer!.id, message);
      }
    } else {
      Message message = Message(
          senderID: currentUser!.id,
          content: chatMessage.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt));

      await _databaseService.sendChatMessage(
          currentUser!.id, otherUSer!.id, message);
    }
  }

  List<ChatMessage> _generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUSer!,
            medias: [
              ChatMedia(url: m.content!, fileName: "", type: MediaType.image)
            ],
            createdAt: m.sentAt!.toDate());
      } else {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUSer!,
            text: m.content!,
            createdAt: m.sentAt!.toDate());
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
        onPressed: () async {
          File? file = await getImageFromGallery();

          if (file != null) {
            final img.Image? image =
                img.decodeImage(File(file.path).readAsBytesSync());
            // Resize the image to a maximum width of 600 pixels (or any size you prefer)
            final img.Image resizedImage = img.copyResize(image!, width: 600);
            // Convert the resized image to bytes
            final List<int> resizedImageBytes =
                img.encodeJpg(resizedImage, quality: 85);
            // Save the resized image to a temporary file
            final String tempPath =
                '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
            final File tempFile = File(tempPath)
              ..writeAsBytesSync(resizedImageBytes);

            String? downloadUrl = await _storageService.uploadImageToChat(
                file: tempFile,
                chatId: _databaseService.GenerateChatId(
                    uid1: currentUser!.id, uid2: otherUSer!.id));

            if (downloadUrl != null) {
              ChatMessage chatMessage = ChatMessage(
                  user: currentUser!,
                  createdAt: DateTime.now(),
                  medias: [
                    ChatMedia(
                        url: downloadUrl, fileName: "", type: MediaType.image)
                  ]);
              _sendMessage(chatMessage);
            }
          }

          // String? downloadUrl = await StorageService.uploadUserPfp(file: tempFile, uid: id);
          // print("==================="+downloadUrl!);
        },
        icon: Icon(
          Icons.image,
          color: Theme.of(context).colorScheme.primary,
        ));
  }

  Future<File?> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      return file;
    }
    return null;
  }
}
