import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String user_name;
  final String pfpURL;
  const FullScreenImage({super.key, required this.user_name, required this.pfpURL});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26.withOpacity(0.5),
        title: Center(child: Text(user_name, style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500
        ),)),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Image.network(
                pfpURL, // replace with your image URL
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.5,
                fit: BoxFit.cover);
          },
        ),

      ),
      backgroundColor: Colors.black,
    );
  }
}
