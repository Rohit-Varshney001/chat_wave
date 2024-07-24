import 'dart:io';

import 'package:chat_wave/Models/user_profile.dart';
import 'package:chat_wave/Pages/added_users_page.dart';
import 'package:chat_wave/Services/database_service.dart';
import 'package:chat_wave/Services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_spinkit/flutter_spinkit.dart';



import '../uiHelper/ui_helper.dart';
import 'home_page.dart';
import 'login_page.dart';


var currentId;

class SignUp_page extends StatefulWidget {
  const SignUp_page({super.key});

  @override
  State<SignUp_page> createState() => _SignUp_pageState();
}

class _SignUp_pageState extends State<SignUp_page> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  bool isPasswordFieldFocused = false;
  bool passwordsMatch = true; // Flag to track if passwords match
  late StorageService storageService;
  File? _image;
  final ImagePicker picker = ImagePicker();
  bool _isLoading = false;
  DatabaseService _databaseService = DatabaseService();










  signUp(String username, String email, String password, String rePassword) async{
    if(email == "" || password == ""|| rePassword == ""){

      MotionToast.warning(
          title:  Text("Email/Password is Empty"),
          description:  Text("Type valid Email/Password")
      ).show(context);
    }else if(email.isNotEmpty) {
      bool isValid = EmailValidator.validate(email);
      if (isValid) {
        if (password != rePassword) {
          // If passwords don't match, set passwordsMatch flag to false
          MotionToast.warning(
              title:  const Text("Password mismatched"),
              description:  const Text("check password")
          ).show(context);
          passwordsMatch = false;
        } else if(_image == null){
          MotionToast.warning(
              title:  const Text("Image missing"),
              description:  const Text("check image")
          ).show(context);
        }
        else {
          // Passwords match, proceed with sign up
          passwordsMatch = true;
          // Perform signup logic here

          UserCredential? userCredential;
          try {
            setState(() {
              _isLoading = true;
            });
            userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((value) async {
              String id = value.user!.uid;

              // ====================== Resize image=============

              // Load the image
              final img.Image? image = img.decodeImage(File(_image!.path).readAsBytesSync());
              // Resize the image to a maximum width of 600 pixels (or any size you prefer)
              final img.Image resizedImage = img.copyResize(image!, width: 600);
              // Convert the resized image to bytes
              final List<int> resizedImageBytes = img.encodeJpg(resizedImage, quality: 85);
              // Save the resized image to a temporary file
              final String tempPath = '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
              final File tempFile = File(tempPath)..writeAsBytesSync(resizedImageBytes);




              String? downloadUrl = await StorageService.uploadUserPfp(file: tempFile, uid: id);
              print("==================="+downloadUrl!);

              if(downloadUrl != null){
                try{
                  await _databaseService.createUserProfile(userProfile: UserProfile(uid: id, name: username, pfpURL: downloadUrl, status: null));
                  currentId = id;
                }catch (e) {
                  MotionToast.info(
                    title:  const Text(
                      "Error SignUp",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    position: MotionToastPosition.center,
                    description:  Text(e.toString()),
                  ).show(context);
              }
              }

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddedUsersPage(myId: currentId)));
              tempFile.delete();
              print("account created successfully");
              print('download url:$downloadUrl');
            });
          }
          on FirebaseAuthException catch(ex){
            MotionToast.info(
              title:  const Text(
                "Error SignUp",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              position: MotionToastPosition.center,
              description:  Text(ex.code.toString()),
            ).show(context);
          }finally{
            setState(() {
              _isLoading = false;
            });
          }

          print("Successful");


        }

      }else{
        MotionToast.warning(
            title:  Text("Ivalid Email"),
            description:  Text("Enter Valid Email")
        ).show(context);
      }

    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children:[
        Scaffold(
        appBar: AppBar(
          title: Text("SignUp Page"),
          centerTitle:true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Stack(
                  children: [
                    ClipOval(
                     child: _image == null ? Image.asset(
                        "assets/images/blank.png",
                          width: 100.0,  // Set the width as per your requirement
                          height: 100.0, // Set the height as per your requirement
                          fit: BoxFit.cover, // Ensures the image covers the area
                        ) : Image.file(File(_image!.path),
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.cover,
                      ),


                  ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey, // Background color for the icon
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(6.0), // Adjust the padding as needed
                          child: Icon(
                            Icons.upload, // The upload icon
                            color: Colors.white, // Color of the icon
                            size: 15.0, // Size of the icon
                          ),
                        ),
                        onTap: showOptions,
                      ),
                    ),
                  ]

                ),

                SizedBox(height: 10,),
                UiHelper.customTextField(nameController, "Name", Icons.nat, false),

                SizedBox(height: 10,),
                UiHelper.customTextField(emailController, "Email", Icons.mail, false),

                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      isPasswordFieldFocused = hasFocus;
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPasswordFieldFocused = true;
                      });
                    },
                    child: UiHelper.customTextField(passwordController, "Password", Icons.password, false,),
                  ),
                ),
                if (isPasswordFieldFocused)
                  FlutterPwValidator(
                    controller: passwordController,
                    minLength: 8,
                    uppercaseCharCount: 1,
                    numericCharCount: 1,
                    specialCharCount: 1,
                    width: 400,
                    height: 200,
                    onSuccess: () {
                      print("Success");
                    },
                    onFail: () {
                      print("Failed");
                    },
                  ),

                UiHelper.customTextField(rePasswordController, "re-enter password", Icons.password, false),


                SizedBox(height: 30,),
                UiHelper.customButton(() {
                  signUp(nameController.text.toString(),emailController.text.toString(), passwordController.text.toString(),rePasswordController.text.toString());

                }, "SignUp"),

                SizedBox(height: 15,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an Account,",style: TextStyle(fontSize: 18),),
                    TextButton(onPressed: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()),);
                    }, child: Text("Login",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500)))
                  ],
                ),

              ],

            ),
          ),
        ),

      ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: SpinKitFadingCircle(
                color: Colors.white,
                size: 50.0,
              ),            ),
          ),
      ]
    );
  }

  Future getImageFromGallery() async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if(pickedFile != null){
        _image = File(pickedFile.path);
      }
    });

  }
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }
  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }



}