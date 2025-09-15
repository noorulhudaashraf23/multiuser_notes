import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:multiuser_notes/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SizedBox(height: 100),
          Center(child: Text('Register', style: TextStyle(fontSize: 30))),
          SizedBox(height: 30),
          Text("Name", style: TextStyle(fontSize: 20)),
          TextFormField(controller: name),
          SizedBox(height: 30),
          Text("Email", style: TextStyle(fontSize: 20)),
          TextFormField(controller: email),
          SizedBox(height: 20),
          Text("Password", style: TextStyle(fontSize: 20)),
          TextFormField(controller: password),
          SizedBox(height: 40),
          isLoading
              ? loader
              : ElevatedButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      await supabse.auth.signUp(
                        email: email.text.trim(),
                        password: password.text.trim(),
                        data: {"name": email.text.trim()},
                      );
                      // Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Registered Successfully")),
                      );
                    } on AuthException catch (e) {
                      log(e.message);
                      setState(() {
                        isLoading = false;
                      });
                    } catch (e) {
                      log(e.toString());
                      setState(() {
                        isLoading = false;
                      });
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text("Register", style: TextStyle(fontSize: 20)),
                ),
        ],
      ),
    );
  }
}

final loader = Center(child: CircularProgressIndicator());
