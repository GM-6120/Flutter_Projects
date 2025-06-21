import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_dost/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/app_utils.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  DateTime? _selectedDate;

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List<DocumentSnapshot> allTransactions = [];
  List<DocumentSnapshot> displayedTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    String currentUserEmail = '${AppUtils.data?.email}';
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: currentUserEmail)
        .get();

    setState(() {
      allTransactions = querySnapshot.docs;
      displayedTransactions = allTransactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
        backgroundColor: appbar,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                _searchTransactions(value);
              },
              decoration: InputDecoration(
                labelText: 'Search transactions',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
              child: _buildTransactionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: displayedTransactions.length,
      itemBuilder: (context, index) {
        DocumentSnapshot document = displayedTransactions[index];
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        return Dismissible(
          key: Key(document.id),
          onDismissed: (direction) {
            _deleteTransaction(document.id);
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              _showEditDialog(document, data);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['day'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        data['date'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\ Pkr ${data['amount'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          data['how'] == 'Income' ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteTransaction(String documentId) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(documentId)
        .delete();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _applyFilters();
      });
    }
  }

  void _showEditDialog(DocumentSnapshot document, Map<String, dynamic> data) {
    nameController.text = data['name'];
    amountController.text = data['amount'].toString();
    typeController.text = data['how'];
    dateController.text = data['date'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: typeController,
                decoration:
                    const InputDecoration(labelText: 'Type (Income/Expense)'),
              ),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () {
                  _selectDateForDialog(context);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateTransaction(document.id);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateTransaction(String documentId) async {
    String name = nameController.text;
    double amount = double.parse(amountController.text);
    String type = typeController.text;
    String date = dateController.text;

    // Update day based on the selected date
    String day =
        DateFormat('EEEE').format(DateFormat('yyyy-MM-dd').parse(date));

    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(documentId)
        .update({
      'name': name,
      'amount': amount,
      'how': type,
      'date': date,
      'day': day,
    });
  }

  Future<void> _selectDateForDialog(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _searchTransactions(String query) {
    if (query.isEmpty) {
      setState(() {
        displayedTransactions = allTransactions;
      });
    } else {
      String currentUserEmail = '${AppUtils.data?.email}';
      List<DocumentSnapshot> filteredTransactions =
          _filterTransactions(query, currentUserEmail);

      setState(() {
        displayedTransactions = filteredTransactions;
      });
    }
  }

  List<DocumentSnapshot> _filterTransactions(
      String searchQuery, String currentUserEmail) {
    return allTransactions.where((transaction) {
      Map<String, dynamic> data = transaction.data() as Map<String, dynamic>;
      String transactionName = data['name'].toString().toLowerCase();

      // Check if the transaction belongs to the current user
      bool isCurrentUserTransaction = data['userId'] == currentUserEmail;

      return isCurrentUserTransaction &&
          transactionName.contains(searchQuery.toLowerCase());
    }).toList();
  }

  void _applyFilters() {
    if (_selectedDate != null) {
      String currentUserEmail = '${AppUtils.data?.email}';
      List<DocumentSnapshot> filteredTransactions =
          allTransactions.where((transaction) {
        Map<String, dynamic> data = transaction.data() as Map<String, dynamic>;
        bool isCurrentUserTransaction = data['userId'] == currentUserEmail;

        if (isCurrentUserTransaction) {
          String transactionDate = data['date'];
          return DateFormat('yyyy-MM-dd').format(_selectedDate!) ==
              transactionDate;
        }
        return false;
      }).toList();

      setState(() {
        displayedTransactions = filteredTransactions;
      });
    } else {
      setState(() {
        displayedTransactions = allTransactions;
      });
    }
  }
}
