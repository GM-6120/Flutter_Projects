import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:latlong2/latlong.dart';
import 'package:soil_care_tech/pages/full_report_page.dart';
import 'package:soil_care_tech/pages/history_page.dart';
import 'package:soil_care_tech/pages/settings_page.dart';
import 'package:soil_care_tech/pages/soil_data.dart';
import 'package:soil_care_tech/pages/splash_screen.dart';
import 'package:soil_care_tech/pages/login_page.dart';
import 'package:soil_care_tech/pages/home_page.dart';
import 'pages/user_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCH7g3NGGlQkSlfFkDfvYDROIjC-tQEc3E",
          authDomain: "soil-care-tech-a0428.firebaseapp.com",
          projectId: "soil-care-tech-a0428",
          storageBucket: "soil-care-tech-a0428.firebasestorage.app",
          messagingSenderId: "147487267787",
          appId: "1:147487267787:web:647f27cfc88ea2373ab44e"),
    );
  } else {
    Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soil Care Tech',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginPage(),
        '/home': (context) => const MyHomePage(),
        '/UserProfile': (context) => const UserProfilePage(),
        '/history': (context) => const HistoryPage(),
        '/settings': (context) => const SettingsPage(),
        '/full-report': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is Map<String, dynamic> &&
              args['soilData'] is SoilData &&
              args['coordinates'] is LatLng) {
            return FullReportPage(
              soilData: args['soilData'],
              coordinates: args['coordinates'],
            );
          }
          return const Scaffold(
            body: Center(
              child: Text('Invalid data', style: TextStyle(color: Colors.red)),
            ),
          );
        },
      },
    );
  }
}
