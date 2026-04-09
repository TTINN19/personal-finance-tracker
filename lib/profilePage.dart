import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/loginPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showEditDialog(
    BuildContext context,
    String currentName,
    String currentEmail,
  ) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFBF8EF),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Color(0xFFF96E2A)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Color(0xFF78B3CE)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF78B3CE)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF96E2A)),
                  ),
                ),
                cursorColor: Color(0xFFF96E2A),
              ),
              TextField(
                controller: emailController,
                style: TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF78B3CE)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF78B3CE)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF96E2A)),
                  ),
                ),
                cursorColor: Color(0xFFF96E2A),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFF96E2A)),
              ),
            ),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  try {
                    await user.verifyBeforeUpdateEmail(emailController.text);

                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user.uid)
                        .update({
                          'name': nameController.text,
                          'email': emailController.text,
                        });

                    final transactions =
                        await FirebaseFirestore.instance
                            .collection('Transactions')
                            .where('email', isEqualTo: currentEmail)
                            .get();

                    for (var doc in transactions.docs) {
                      await doc.reference.update({
                        'email': emailController.text,
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Verification email sent. Please verify your new email before logging in.',
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFFF96E2A)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF78B3CE),
        ),
        body: const Center(child: Text('No user is currently signed in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF78B3CE),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final docSnapshot =
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(user.uid)
                      .get();
              if (docSnapshot.exists) {
                var userData = docSnapshot.data();
                _showEditDialog(
                  context,
                  userData?['name'] ?? 'No name',
                  userData?['email'] ?? 'No email',
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('User data not found')));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/001.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user.uid)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print('Error fetching data: ${snapshot.error}');
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      print('No data found for user: ${user.uid}');
                      return const Text('No data found');
                    }

                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    print('Fetched user data: $userData');

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Name: ${userData['name'] ?? 'No name'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF78B3CE),
                          ),
                        ),
                        Text(
                          'Email: ${userData['email'] ?? 'No email'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF78B3CE),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => loginPage()),
              );
            },
            child: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFFF96E2A),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFF96E2A)),
            ),
          ),
        ),
      ),
    );
  }
}
