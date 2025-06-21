import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionService {
  Future<double> getTotalIncome(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('how', isEqualTo: 'Income')
        .where('userId', isEqualTo: userId)
        .get();

    double totalIncome = 0;

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      totalIncome += doc['amount'];
    }

    return totalIncome;
  }

  Future<double> getTotalExpense(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('how', isEqualTo: 'Expense')
        .where('userId', isEqualTo: userId)
        .get();

    double totalExpense = 0;

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      totalExpense += doc['amount'];
    }

    return totalExpense;
  }
}
