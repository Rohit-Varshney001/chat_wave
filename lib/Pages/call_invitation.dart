// import 'package:chat_wave/Models/user_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
//
// class AudioCallPage2 extends StatelessWidget {
//   final String callID;
//   final String userId;
//   final String imageURL1;
//   final String imageURL2;
//
//   const AudioCallPage2({super.key, required this.callID, required this.userId, required this.imageURL1, required this.imageURL2});
//
//   @override
//   Widget build(BuildContext context) {
//     bool useFirstImage = true;
//
//     return ZegoUIKitPrebuiltCall(
//       appID: 1038008585, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
//       appSign: "96157939309e1efd667872f76cc1b2cc01068183bf4a35fffd38f977c10ff942", // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
//       userID: userId,
//       userName: 'User: $userId',
//       callID: callID,
//       // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
//       config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
//         ..avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
//           String imageUrl = useFirstImage ? imageURL1 : imageURL2;
//           useFirstImage = !useFirstImage; // Toggle the flag
//           return user != null
//               ? Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               image: DecorationImage(
//                 image: NetworkImage(
//                     imageUrl
//                 ),
//               ),
//             ),
//           )
//               : const SizedBox();
//         }
//         ..turnOnCameraWhenJoining = false
//         ..turnOnMicrophoneWhenJoining = true
//         ..useSpeakerWhenJoining = true,
//
//     );
//
//   }
// }
