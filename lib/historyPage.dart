import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Color(0xFF78B3CE),
        foregroundColor: Color(0xFFFBF8EF),
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Transactions')
                .where('email', isEqualTo: user!.email)
                .orderBy('date', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No transactions found'));
          }
          Map<String, List<DocumentSnapshot>> groupedData = {};
          Map<String, double> monthlyBalances = {};
          for (var doc in snapshot.data!.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String month = DateFormat(
              'MMMM yyyy',
            ).format(data['date'].toDate());
            if (groupedData[month] == null) {
              groupedData[month] = [];
              monthlyBalances[month] = 0.0;
            }
            groupedData[month]!.add(doc);
            double amount =
                data['amount'] is int
                    ? (data['amount'] as int).toDouble()
                    : data['amount'];
            if (data['type'] == 'Income') {
              monthlyBalances[month] = monthlyBalances[month]! + amount;
            } else {
              monthlyBalances[month] = monthlyBalances[month]! - amount;
            }
          }

          return ListView(
            children:
                groupedData.entries.map((entry) {
                  String month = entry.key;
                  List<DocumentSnapshot> docs = entry.value;
                  double balance = monthlyBalances[month]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              month,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF96E2A),
                              ),
                            ),
                            Text(
                              'Balance: ${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF78B3CE),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Card(
                        color: Color.fromARGB(255, 239, 245, 255),
                        child: Column(
                          children:
                              docs.map((document) {
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                return ListTile(
                                  title: Text(
                                    '${data['type']} - ${data['amount']}',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 85, 85, 85),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${DateFormat('yyyy-MM-dd').format(data['date'].toDate())}',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 120, 120, 120),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Color.fromARGB(255, 255, 176, 136),
                                    onPressed: () async {
                                      bool? confirmDelete = await showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              backgroundColor: Color(
                                                0xFFFBF8EF,
                                              ),
                                              title: Text(
                                                'Confirm Delete',
                                                style: TextStyle(
                                                  color: Color(0xFFF96E2A),
                                                ),
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete this transaction?',
                                                style: TextStyle(
                                                  color: Color(0xFF78B3CE),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(false),
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color: Color(0xFFF96E2A),
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(true),
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Color(0xFFF96E2A),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (confirmDelete == true) {
                                        await FirebaseFirestore.instance
                                            .collection('Transactions')
                                            .doc(document.id)
                                            .delete();
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
