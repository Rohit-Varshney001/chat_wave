
import 'package:chat_wave/Pages/home_page.dart';
import 'package:chat_wave/Pages/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Services/database_service.dart';
import '../uiHelper/ui_helper.dart';
import 'forgot_password_page.dart';


var currUID;
late final DatabaseService _databaseService = DatabaseService();



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  login(String email, String password)async{
    if(email == "" || password == "") {
      MotionToast.warning(
          title: Text("Email/Password is Empty"),
          description: Text("Type valid Email/Password")
      ).show(context);
    }else{
      UserCredential? userCredential;
      try{
        setState(() {
          _isLoading = true;
        });
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((value) async {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
          currUID = value.user!.uid;





        });

      }on FirebaseAuthException catch(e){
        MotionToast.info(
          title:  const Text(
            "Error login",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          position: MotionToastPosition.center,
          description:  Text("Wrong Email/Password"),
        ).show(context);

      }finally{
        setState(() {
          _isLoading = false;
        });
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children:[
      Scaffold(
        appBar: AppBar(
          title: Text("Login Page"),
          centerTitle: true,


        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/loginLogo.png"),
              SizedBox(height: 15,),


              UiHelper.customTextField(emailController, "Email", Icons.mail, false),
              UiHelper.customTextField(passwordController, "Password", Icons.password, true),
              SizedBox(height: 30,),
              UiHelper.customButton(() {
                login(emailController.text.toString(), passwordController.text.toString());
              }, "Login"),
              SizedBox(height: 15,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an Account,",style: TextStyle(fontSize: 18),),
                  TextButton(onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp_page()),);
                  }, child: Text("SignUp",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500))),


                ],
              ),
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()),);
              }, child: Text("Forgot Password ?",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500))),



            ],

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
          ),]
    );
  }
}
