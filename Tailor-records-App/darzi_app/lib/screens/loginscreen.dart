import 'package:darzi_app/Firebase/auth_service.dart';
import 'package:darzi_app/screens/Homescreen.dart';
import 'package:darzi_app/screens/Signupscreen.dart';
import 'package:darzi_app/widgets/custom%20widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginscreen extends StatefulWidget {
  const loginscreen({super.key});

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  TextEditingController loginEmail = TextEditingController();
  TextEditingController loginpassword = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: loginEmail.text, password: loginpassword.text);
      User? user = userCredential.user;
      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', user.uid);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } catch (e) {
      print(e);
    }
  }

  ValueNotifier<bool> toogle = ValueNotifier(true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(color: Appcolors.black),
            child: const Padding(
              padding: EdgeInsets.only(left: 25, top: 60),
              child: Text(
                "Hello\nSign In !",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 350),
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: loginEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Appcolors.black,
                            ),
                            hintText: "Email",
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ValueListenableBuilder(
                            valueListenable: toogle,
                            builder: (context, value, child) {
                              return TextField(
                                controller: loginpassword,
                                obscureText: toogle.value,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Appcolors.black,
                                    ),
                                    suffixIcon: GestureDetector(
                                        onTap: () {
                                          toogle.value = !toogle.value;
                                        },
                                        child: Icon(
                                          toogle.value
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Appcolors.black,
                                        )),
                                    hintText: "Password"),
                              );
                            }),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Forgot Password",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Appcolors.black),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        CupertinoButton(
                          onPressed: () async {
                            final message = await AuthService().login(
                              email: loginEmail.text,
                              password: loginpassword.text,
                            );
                            if (message!.contains('Success')) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()),
                              );
                            } else {
                              showFlashMessage(context, message);
                            }
                          },
                          padding: EdgeInsets.zero,
                          child: Container(
                            height: 60,
                            width: 300,
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Appcolors.black,
                                  Appcolors.purpleColor
                                ]),
                                borderRadius: BorderRadius.circular(15)),
                            child: const Center(
                                child: Text(
                              "Log in",
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                          ),
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 15),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const signupscrenn()));
                                },
                                child: const Text(
                                  "SIGN UP",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
