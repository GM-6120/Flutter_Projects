import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';

class Auth {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool> userExists(email) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) => value.size > 0 ? true : false);
  }

  Future signUp(UserModel userModel, password) async {
    await auth
        .createUserWithEmailAndPassword(
            email: userModel.email!, password: password)
        .then((userCredential) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.email)
          .set({
        'name': userModel.name,
        'email': userModel.email,
      }).then((_) async {});
    });
  }

  Future<UserCredential> login(email, password) async {
    UserCredential userCredential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential;
  }

  Future<void> firebaseSignOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteCurrentUserAccount(String email) async {
    try {
      User? user = auth.currentUser;
      if (user != null && user.email == email) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .delete();

        // Delete user transactions from Firestore
        QuerySnapshot transactionsQuery = await FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: email)
            .get();

        for (QueryDocumentSnapshot transactionSnapshot
            in transactionsQuery.docs) {
          await transactionSnapshot.reference.delete();
        }

        // Delete the user account
        await user.delete();
      } else {
        throw "Invalid user or user not found";
      }
    } catch (e) {
      throw "Error deleting user account: $e";
    }
  }
}
