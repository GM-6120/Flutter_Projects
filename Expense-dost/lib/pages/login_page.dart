import 'package:expence_dost/pages/forgot_password.dart';
import 'package:expence_dost/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/constants.dart';
import '../model/user_model.dart';
import '../services/auth.dart';
import '../utils/app_utils.dart';
import 'navbar.dart';
import 'sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  Auth auth = Auth();
  AppUtils appUtils = AppUtils();
  GetStorage getStorage = GetStorage();
  String? email, password;

  String? isValidEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }

    final emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
    if (!emailRegex.hasMatch(value)) {
      return 'Provide valid email';
    }

    return null;
  }

  String? isValidPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [g1, g2],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(size.height * 0.020),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/relax.png",
                    scale: 1.0,
                    width: 200,
                    height: 200,
                  ),
                  Text(
                    "Welcome Back!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: kWhiteColor.withOpacity(0.7),
                    ),
                  ),
                  const Text(
                    "Please , Log In.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 34,
                      color: kWhiteColor,
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),
                  CustomTextField(
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    onChange: (value) {
                      email = value;
                    },
                    validateField: isValidEmail,
                  ),
                  SizedBox(height: size.height * 0.04),
                  CustomTextField(
                    label: "Password",
                    prefixIcon: Icons.lock_outlined,
                    onChange: (value) {
                      password = value;
                    },
                    isPassword: true,
                    validateField: isValidPassword,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotScreen()),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: kWhiteColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: size.height * 0.080,
                      decoration: BoxDecoration(
                        color: kButtonColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          color: kWhiteColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      // Validate the form fields
                      if (formKey.currentState?.validate() ?? false) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Processing Data'),
                          duration: Duration(milliseconds: 1500),
                          width: 350.0,
                          backgroundColor: kButtonColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.0,
                            vertical: 15,
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ));
                        try {
                          UserCredential userCredential =
                              await auth.login(email!, password!);
                          String userId = userCredential.user!.email!;
                          UserModel signInModel = UserModel(email: userId);
                          getStorage.write(
                              AppUtils.userDataKey, signInModel.toJson());
                          AppUtils.data = signInModel;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Navbar()),
                          );
                        } on FirebaseException catch (e) {
                          Fluttertoast.showToast(
                              msg: e.toString(),
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.red,
                              fontSize: 16.0);
                        }
                      }
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: size.height * 0.080,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 45,
                            spreadRadius: 0,
                            color: Color.fromRGBO(120, 37, 139, 0.25),
                            offset: Offset(0, 25),
                          )
                        ],
                        borderRadius: BorderRadius.circular(15),
                        color: const Color.fromRGBO(225, 225, 225, 0.28),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: kWhiteColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
