import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/constants.dart';
import '../utils/app_utils.dart';
import 'navbar.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  DateTime date = DateTime.now();
  String selectedHow = 'Expence';
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('transactions');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Navbar()),
            );
          },
        ),
        backgroundColor: appbar,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white70,
                borderRadius: BorderRadius.circular(19.0),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 25.0),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'How',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () {
                      _showHowOptions(context);
                    },
                    controller: TextEditingController(text: selectedHow),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: TextEditingController(text: _formatDate(date)),
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () {
                      _selectDate(context);
                    },
                  ),
                  SizedBox(height: 65.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_validateFields()) {
                        _saveTransaction();
                      } else {
                        Fluttertoast.showToast(
                          msg: "Please fill in all input fields",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      minimumSize: Size(200, 60),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateFields() {
    return nameController.text.isNotEmpty && amountController.text.isNotEmpty;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (newDate == null) return;
    setState(() {
      date = newDate;
    });
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _showHowOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select How'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Income'),
                onTap: () {
                  _setSelectedHow('Income');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Expense'),
                onTap: () {
                  _setSelectedHow('Expense');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _setSelectedHow(String value) {
    setState(() {
      selectedHow = value;
    });
  }

  void _saveTransaction() {
    // Get values from text controllers
    String name = nameController.text;
    double amount = double.tryParse(amountController.text) ?? 0.0;
    String how = selectedHow;
    String formattedDate = _formatDate(date);

    // Extract the day from the selected date
    String day = _getDayFromDate(date);

    // Create a new transaction object
    Map<String, dynamic> transactionData = {
      'name': name,
      'amount': amount,
      'how': how,
      'date': formattedDate,
      'day': day,
      'userId': AppUtils.data?.email,
    };

    // Add  transaction data to Firestore
    _collectionReference.add(transactionData).then((_) {
      Fluttertoast.showToast(
        msg: "Transaction is Saved Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Clear text controllers after saving
      nameController.clear();
      amountController.clear();
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: "Error Saving Transaction",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  String _getDayFromDate(DateTime date) {
    return _days[date.weekday - 1];
  }

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
}
