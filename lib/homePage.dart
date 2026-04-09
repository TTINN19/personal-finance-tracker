import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/profilePage.dart';
import 'historyPage.dart';

class homePage extends StatefulWidget {
  homePage({super.key});

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference transactionCollection = FirebaseFirestore.instance
      .collection('Transactions');

  int _selectedIndex = 0;
  double _balance = 0.0;
  double _income = 0.0;
  double _expense = 0.0;

  static List<Widget> _widgetOptions = <Widget>[
    TransactionList(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _calculateBalance();
    void checkFirebaseConnection() async {
      try {
        await FirebaseFirestore.instance
            .collection('Test')
            .doc('testDoc')
            .get();
        print("Firestore connected successfully!");
      } catch (e) {
        print("Firestore connection failed: $e");
      }

      try {
        final user = FirebaseAuth.instance.currentUser;
        print("Current user: ${user?.email}");
      } catch (e) {
        print("FirebaseAuth connection failed: $e");
      }
    }
  }

  void _onItemTapped(int index) {
    if (index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFFFBF8EF),
      builder: (context) {
        String transactionType = 'Income';
        DateTime? selectedDate;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: transactionType,
                    items:
                        ['Income', 'Expense']
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: TextStyle(color: Color(0xFF78B3CE)),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        transactionType = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Transaction Type',
                      labelStyle: TextStyle(color: Color(0xFF78B3CE)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF78B3CE)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF78B3CE)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? "No date selected"
                            : "${selectedDate!.toLocal()}".split(' ')[0],
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF78B3CE),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  primaryColor: Color(0xFF78B3CE),
                                  hintColor: Color(0xFFF96E2A),
                                  colorScheme: ColorScheme.light(
                                    primary: Color(0xFF78B3CE),
                                    onPrimary: Colors.white,
                                    surface: Color(0xFFFBF8EF),
                                    onSurface: Color(0xFFF96E2A),
                                  ),
                                  dialogBackgroundColor: Color(0xFFFBF8EF),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color(0xFF78B3CE),
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color(0xFFFBF8EF),
                          backgroundColor: Color(
                            0xFFF96E2A,
                          ), // ตั้งค่าสีพื้นหลังของปุ่ม
                        ),
                        child: Text('Select date'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedDate != null) {
                        Navigator.pop(context);
                        _showAmountInputSheet(
                          context,
                          transactionType,
                          selectedDate!,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a date')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xFFFBF8EF),
                      backgroundColor: Color(0xFFF96E2A),
                    ),
                    child: Text('Next'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAmountInputSheet(
    BuildContext context,
    String transactionType,
    DateTime selectedDate,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFFFBF8EF),
      builder: (context) {
        final amountController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Color(0xFF78B3CE)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF78B3CE)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF78B3CE)),
                  ),
                ),
                style: TextStyle(color: Color(0xFF78B3CE)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);

                  if (amount != null) {
                    await FirebaseFirestore.instance
                        .collection('Transactions')
                        .add({
                          'email': FirebaseAuth.instance.currentUser!.email,
                          'type': transactionType,
                          'amount': amount,
                          'date': selectedDate,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                    Navigator.pop(context);
                    setState(() {
                      _calculateBalance();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid amount')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFFFBF8EF),
                  backgroundColor: Color(0xFFF96E2A),
                ),
                child: Text('Save Transaction'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    Color cardColor =
        data['type'] == 'Income' ? Colors.green[100]! : Colors.red[100]!;

    return Card(
      color: cardColor,
      child: ListTile(
        title: Text(
          '${data['type']} - ${data['amount']}',
          style: TextStyle(
            color: const Color.fromARGB(255, 68, 68, 68),
            fontSize: 14,
          ),
        ),
        subtitle:
            data['date'] != null
                ? Text(
                  '${data['date'].toDate().toLocal()}'.split(' ')[0],
                  style: TextStyle(
                    color: const Color.fromARGB(255, 120, 120, 120),
                    fontSize: 12,
                  ),
                )
                : Text(
                  'No date available',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 68, 68, 68),
                    fontSize: 12,
                  ),
                ),
      ),
    );
  }

  Future<void> _calculateBalance() async {
    double balance = 0.0;
    double income = 0.0;
    double expense = 0.0;
    if (user != null) {
      QuerySnapshot snapshot =
          await transactionCollection
              .where('email', isEqualTo: user!.email)
              .orderBy('date', descending: true)
              .get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['type'] == 'Income') {
          income += data['amount'];
          balance += data['amount'];
        } else if (data['type'] == 'Expense') {
          expense += data['amount'];
          balance -= data['amount'];
        }
      }
    }
    setState(() {
      _balance = balance;
      _income = income;
      _expense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _selectedIndex == 0
              ? AppBar(
                title: Center(
                  child: Text(
                    "Transaction",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                backgroundColor: Color(0xFF78B3CE),
                foregroundColor: Color(0xFFFBF8EF),
                elevation: 4,
              )
              : null,
      body: Column(
        children: [
          if (_selectedIndex == 0)
            Column(
              children: [
                Card(
                  margin: EdgeInsets.all(16.0),
                  color: Color(0xFFC9E6F0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Balance:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF78B3CE),
                          ),
                        ),
                        Text(
                          '$_balance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF78B3CE),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 1.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        color: Colors.green[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Income:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 52, 94, 54),
                                ),
                              ),
                              Text(
                                '$_income',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 52, 94, 54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        color: Colors.red[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Expense:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 94, 52, 52),
                                ),
                              ),
                              Text(
                                '$_expense',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 94, 52, 52),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'latest transaction',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 95, 102, 106),
                      ),
                    ),
                  ),
                ), //
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
          ),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () => _showAddTransactionSheet(context),
                child: Icon(Icons.add),
                backgroundColor: Color(0xFFF96E2A),
                foregroundColor: Color(0xFFFBF8EF),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Transaction'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF78B3CE),
        unselectedItemColor: Color(0xFF78B3CE),
        backgroundColor: Color(0xFFC9E6F0),
        onTap: _onItemTapped,
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Transactions')
              .where('email', isEqualTo: user!.email)
              .orderBy('date', descending: true)
              .limit(5)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Firestore Error: ${snapshot.error}");
          return Center(child: Text("Error loading transactions"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No transactions available"));
        }

        return ListView(
          children:
              snapshot.data!.docs.map((document) {
                return _buildTransactionCard(document);
              }).toList(),
        );
      },
    );
  }
}

Widget _buildTransactionCard(DocumentSnapshot document) {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>? ?? {};
  if (data.isEmpty) {
    return SizedBox();
  }

  Color cardColor =
      data['type'] == 'Income' ? Colors.green[100]! : Colors.red[100]!;

  return Card(
    color: cardColor,
    child: Padding(
      padding: const EdgeInsets.all(0.0),
      child: ListTile(
        title: Text(
          '${data['type']} - ${data['amount'] ?? 0}',
          style: TextStyle(
            color: Color.fromARGB(255, 85, 85, 85),
            fontSize: 14,
          ),
        ),
        subtitle:
            data['date'] != null
                ? Text(
                  '${data['date'].toDate().toLocal()}'.split(' ')[0],
                  style: TextStyle(
                    color: Color.fromARGB(255, 120, 120, 120),
                    fontSize: 12,
                  ),
                )
                : Text(
                  'No date available',
                  style: TextStyle(
                    color: Color.fromARGB(255, 68, 68, 68),
                    fontSize: 12,
                  ),
                ),
      ),
    ),
  );
}
