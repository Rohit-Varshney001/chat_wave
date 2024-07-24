import 'package:chat_wave/Models/chats.dart';
import 'package:chat_wave/Models/messages.dart';
import 'package:chat_wave/Models/user_profile.dart';
import 'package:chat_wave/Pages/login_page.dart';
import 'package:chat_wave/Services/check_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../Models/AudioCallModel.dart';
import '../Pages/sign_up_page.dart';


class DatabaseService {
  var ID = currUID ?? currentId ?? currentID2;

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference? _userCollection;
  CollectionReference? _chatCollection;

  DatabaseService() {
    _setupCollectionReferences();
  }

  void _setupCollectionReferences() {
    _userCollection =
        _firebaseFirestore.collection("users").withConverter<UserProfile>(
              fromFirestore: (snapshot, _) =>
                  UserProfile.fromJson(snapshot.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );

    _chatCollection =
        _firebaseFirestore.collection("chats").withConverter<Chat>(
              fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
              toFirestore: (chat, _) => chat.toJson(),
            );
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _userCollection?.doc(userProfile.uid).set(userProfile);
  }

  Future<UserProfile?> getCurrentUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firebaseFirestore.collection("users").doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserProfile(
            uid: data['uid'],
            name: data['name'],
            pfpURL: data['pfpURL'],
            status: data['status']);
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print("Error getting document: $e");
      return null;
    }
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _userCollection?.where("uid", isNotEqualTo: ID).snapshots()
        as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatID = GenerateChatId(uid1: uid1, uid2: uid2);

    final result = await _chatCollection?.doc(chatID).get();

    if (result != null) {
      return result.exists;
    }
    return false;
  }

    Future<List<UserProfile>> getUsersWithChats() async {
      // Get the list of all user profiles
      Stream<QuerySnapshot<UserProfile>> userProfilesStream = getUserProfiles();

      // Convert the stream to a list
      List<UserProfile> userProfiles = await userProfilesStream.first.then((snapshot) =>
          snapshot.docs.map((doc) => doc.data()).toList());

      // Initialize an empty list to store users with whom chats exist
      List<UserProfile> usersWithChats = [];

      // Loop through each user profile and check if a chat exists
      for (UserProfile userProfile in userProfiles) {
        bool chatExists = await checkChatExists(ID, userProfile.uid!);

        // If chat exists, add the user to the list
        if (chatExists) {
          usersWithChats.add(userProfile);
        }
      }

      // Return the list of users with whom chats exist
      return usersWithChats;
    }


  Future<void> createNewChat(String uid1, String uid2) async {
    String chatId = GenerateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatId);

    final chat = Chat(id: chatId, participants: [uid1, uid2], messages: []);

    await docRef.set(chat);
  }

  String GenerateChatId({required String uid1, required String uid2}) {
    List uids = [uid1, uid2];
    uids.sort();
    String chatId = uids.fold("", (id, uid) => "$id$uid");
    return chatId;
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatId = GenerateChatId(uid1: uid1, uid2: uid2);
    final _docRef = _chatCollection!.doc(chatId);
    await _docRef.update({
      "messages": FieldValue.arrayUnion([message.toJson()]),
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatId = GenerateChatId(uid1: uid1, uid2: uid2);
    return _chatCollection?.doc(chatId).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }

  Stream<UserProfile> getStatus(String uid) {
    return _firebaseFirestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((event) {
      return UserProfile.fromJson(event.data()!);
    });
  }

  Future<void> callAction(String receiverId, String callerId, bool isVideoCall) async {
    String callId = GenerateChatId(uid1: callerId, uid2: receiverId);
    UserProfile? caller = await getCurrentUserProfile(callerId);
    UserProfile? receiver = await getCurrentUserProfile(receiverId);
    var newCall = AudioCallModel(
        id: callId,
        isVideoCall: isVideoCall,
        callerName: caller!.name,
        callerPic: caller!.pfpURL,
        callerUid: caller!.uid,
        receiverName: receiver!.name,
        receiverPic: receiver!.pfpURL,
        receiverUid: receiver!.uid,
        status: "dialing");

    try {
      await _firebaseFirestore
          .collection("notification")
          .doc(receiverId)
          .collection("calls")
          .doc(callId)
          .set(newCall.toJson());

      await _firebaseFirestore
          .collection("users")
          .doc(callerId)
          .collection("calls")
          .add(newCall.toJson());

      await _firebaseFirestore
          .collection("users")
          .doc(receiverId)
          .collection("calls")
          .add(newCall.toJson());

      Future.delayed(Duration(seconds: 20), () {
        endCall(newCall);
      });
    } catch (e) {
      print(e);
    }
  }

  Stream<QuerySnapshot> getCallsNotification() {
    return _firebaseFirestore
        .collection("notification")
        .doc(ID)
        .collection("calls")
        .snapshots();
  }

  Future<void> endCall(AudioCallModel call) async {
    try {
      await _firebaseFirestore
          .collection("notification")
          .doc(call.receiverUid)
          .collection("calls")
          .doc(call.id)
          .delete();
    } catch (e) {
      print(e);
    }
  }
}
