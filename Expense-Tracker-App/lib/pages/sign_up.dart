import 'package:expence_dost/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/constants.dart';
import '../model/user_model.dart';
import '../services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_utils.dart';
import 'login_page.dart';
import 'navbar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  Auth auth = Auth();
  AppUtils appUtils = AppUtils();
  GetStorage getStorage = GetStorage();
  late String email, password, name;

  String? isValidEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }

    // Use a regular expression to validate the email format
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

  String? isValidName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
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
                    "assets/form.png",
                    scale: 1.0,
                    width: 200,
                    height: 200,
                  ),
                  Text(
                    "Welcome ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: kWhiteColor.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  const Text(
                    "Please ,Register Yourself.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: kWhiteColor,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  CustomTextField(
                    label: 'Name',
                    prefixIcon: Icons.person_2_outlined,
                    onChange: (value) {
                      name = value;
                    },
                    validateField: isValidName,
                  ),
                  SizedBox(height: size.height * 0.03),
                  CustomTextField(
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    onChange: (value) {
                      email = value;
                    },
                    validateField: isValidEmail,
                  ),
                  SizedBox(height: size.height * 0.03),
                  CustomTextField(
                    label: 'Password',
                    prefixIcon: Icons.lock_outlined,
                    isPassword: true,
                    onChange: (value) {
                      password = value;
                    },
                    validateField: isValidPassword,
                  ),
                  SizedBox(height: size.height * 0.03),
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
                        "Register",
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
                          UserModel signupModel = UserModel(email: email);
                          await auth.signUp(signupModel, password);
                          getStorage.write(
                              AppUtils.userDataKey, signupModel.toJson());
                          AppUtils.data = signupModel;
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
                        "Log In",
                        style: TextStyle(
                          color: kWhiteColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
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
