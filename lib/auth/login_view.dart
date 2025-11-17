import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multiuser_notes/auth/register_view.dart';
import 'package:multiuser_notes/home/home_view.dart';
import 'package:multiuser_notes/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
          Center(child: Text('Login', style: TextStyle(fontSize: 30))),
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
                      await supabase.auth.signInWithPassword(
                        email: email.text.trim(),
                        password: password.text.trim(),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HomeView()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Login Successfully")),
                      );
                    } on AuthException catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.message)));
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text("Login", style: TextStyle(fontSize: 20)),
                ),

          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterView()),
              );
            },
            child: Text(
              "Don't have an account? Register",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

final loader = Center(child: CupertinoActivityIndicator());
