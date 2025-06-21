import 'package:expence_dost/pages/forgot_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/constants.dart';
import '../services/auth.dart';
import '../utils/app_utils.dart';
import 'login_page.dart';

class ProfileScreen extends StatelessWidget {
  Auth auth = Auth();
  AppUtils appUtils = AppUtils();
  GetStorage getStorage = GetStorage();
  final String loggedInEmail = ' ${AppUtils.data?.email}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        centerTitle: true,
        backgroundColor: appbar,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: TextFormField(
                initialValue: loggedInEmail,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_rounded),
                  prefixIconColor: appbar,
                  labelText: 'User Email',
                ),
              ),
            ),
            SizedBox(height: 30),
            CupertinoButton(
                padding: EdgeInsets.zero,
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: appbar,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(
                      color: kWhiteColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                onPressed: () async {
                  try {
                    await Auth().firebaseSignOut();
                    getStorage.remove(AppUtils.userDataKey);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  } catch (e) {
                    print(e);
                  }
                }),
            SizedBox(height: 30),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: appbar,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  "Delete Account",
                  style: TextStyle(
                    color: kWhiteColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              onPressed: () async {
                String userEmail = "${AppUtils.data?.email}";
                try {
                  // Delete user account
                  await Auth().deleteCurrentUserAccount(userEmail);

                  // Sign out and clear local storage data
                  await Auth().firebaseSignOut();
                  getStorage.remove(AppUtils.userDataKey);

                  // Navigate to the login page or perform other actions after deletion
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                } catch (e) {
                  // Handle error, show error message, etc.
                  print("Error: $e");
                }
              },
            ),
            SizedBox(height: 30),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: appbar,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  "Change Password",
                  style: TextStyle(
                    color: kWhiteColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ForgotScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
