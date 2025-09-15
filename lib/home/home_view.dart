import 'package:flutter/material.dart';
import 'package:multiuser_notes/auth/login_view.dart';
import 'package:multiuser_notes/home/add_note_view.dart';
import 'package:multiuser_notes/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        leading: IconButton(
          onPressed: () async {
            await supabse.auth.signOut();
          },
          icon: Icon(Icons.logout),
        ),
        actions: [
          CircleAvatar(
            child: ClipOval(
              child: SizedBox.expand(
                child: Image.network(
                  "https://images.unsplash.com/photo-1756312148347-611b60723c7a?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHw3fHx8ZW58MHx8fHx8",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getNotesList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loader;
          }
          if (snapshot.data!.isEmpty) {
            return Center(child: Text("No Notes Found!"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, count) {
              final note = snapshot.data![count];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                child: ListTile(
                  tileColor: Colors.grey.shade200,
                  title: Text(note['title']),
                  subtitle: Text(note['content']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddNoteView()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> getNotesList() async {
  final res = supabse
      .from("notes")
      .select("*")
      .order("created_at", ascending: false);
  return res;
}


