import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_wave/config/config.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class AudioCallPage extends StatefulWidget {
  final String callID;
  final String userId;
  final String imageURL1;
  final String imageURL2;

  const AudioCallPage({super.key, required this.callID, required this.userId, required this.imageURL1, required this.imageURL2});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  @override
  Widget build(BuildContext context) {
    bool useFirstImage = true;
    return ZegoUIKitPrebuiltCall(
      appID: Config.appID, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign: Config.appSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: widget.userId,
      userName: 'User: ${widget.userId}',
      callID: widget.callID,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        ..avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
          String imageUrl = useFirstImage ? widget.imageURL1 : widget.imageURL2;
          useFirstImage = !useFirstImage; // Toggle the flag
        return user != null
              ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                 imageUrl
                ),
              ),
            ),
          )
              : const SizedBox();
        }
        ..turnOnCameraWhenJoining = false
        ..turnOnMicrophoneWhenJoining = true
        ..useSpeakerWhenJoining = true,

    );
  }
}
