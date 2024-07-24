import 'package:chat_wave/Services/check_user.dart';
import 'package:chat_wave/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async{

  await setup();
  runApp( MyApp());
}

Future<void> setup() async{
  WidgetsFlutterBinding.ensureInitialized();
  await setUpFirebase();
  await registerServices();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Wave',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: CheckUser(),
    );
  }
}

