import 'package:darzi_app/Firebase/auth_service.dart';
import 'package:darzi_app/provider/theme_provider.dart';
import 'package:darzi_app/screens/loginscreen.dart';
import 'package:darzi_app/widgets/custom%20widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Consumer<UiProvider>(builder: (context, UiProvider notifier, child) {
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Dark theme"),
              trailing: Switch(
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.black,
                  value: notifier.isDark,
                  onChanged: (value) => notifier.changeTheme()),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => profile()));
              },
              child: Container(
                  height: 200,
                  width: 100,
                  child: Hero(
                      tag: "profile", child: Image.asset("assets/Icon2.png"))),
            )
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _logout(context);
        },
        child: const Icon(Icons.logout),
      ),
    );
  }

  void _logout(BuildContext context) async {
    String? result = await _authService.logout();
    if (result == 'Success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => loginscreen()),
      ); // Navigate to login screen
    } else {
      showFlashMessage(context, "Error");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Error"),
      //   ),
      // );
    }
  }
}

class profile extends StatelessWidget {
  const profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          height: 400,
          width: 400,
          child: Hero(tag: "profile", child: Image.asset("assets/profile.jpg")),
        ),
      ),
    );
  }
}
