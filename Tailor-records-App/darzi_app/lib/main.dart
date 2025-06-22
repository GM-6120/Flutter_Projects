import 'package:darzi_app/Controller/internetcontroller.dart';
import 'package:darzi_app/provider/theme_provider.dart';
// Fix the import statement
import 'package:darzi_app/screens/Splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAw9dDMnwBo6DAUl-1YB0YYTWDIBlkJWZk",
          appId: "1:995464969159:android:e9c12f4efa81036c77b7e2",
          messagingSenderId: "995464969159",
          projectId: "digital-darzi-3c619"));
  runApp(const MyApp());
  Get.put(InternetController(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => UiProvider()..init(),
      child:
          Consumer<UiProvider>(builder: (context, UiProvider notifier, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DARZI DIGITAL',
          themeMode: notifier.isDark ? ThemeMode.dark : ThemeMode.light,

          //Our custom theme applied
          darkTheme: notifier.isDark ? notifier.darkTheme : notifier.lightTheme,

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            useMaterial3: true,
          ),

          home: const splashscreen(), // Set SplashScreen as the initial screen
        );
      }),
    );
  }
}
