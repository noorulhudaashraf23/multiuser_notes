import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multiuser_notes/auth/login_view.dart';
import 'package:multiuser_notes/home/add_note_view.dart';
import 'package:multiuser_notes/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
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
                  title: Row(
                    children: [
                      Text("${note['title']}"),
                      SizedBox(width: 2.w),
                      Text(
                        "by ${note['users']['name']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        note['content'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  // trailing: Text),
                  trailing: IconButton(
                    onPressed: () {
                      // open a dialog box with a button and textfield
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Share Note"),
                            content: TextField(
                              decoration: InputDecoration(
                                hintText: "Enter user email",
                              ),
                              onSubmitted: (value) async {
                                try {
                                  final userRes = await supabse
                                      .from("users")
                                      .select(
                                        "id, name",
                                      ) // only fetch what you need
                                      .eq("email", value);

                                  final user = userRes.first;

                                  if (userRes.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("User not found"),
                                      ),
                                    );
                                    getNotesList();
                                  } else if (user['id'] ==
                                      supabse.auth.currentUser!.id) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "You can't share with yourself",
                                        ),
                                      ),
                                    );
                                    getNotesList();
                                  } else if (note['user_notes'].any((
                                    hrKoiValue,
                                  ) {
                                    return hrKoiValue['user_id'] == user['id'];
                                  })) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${user['name']} is already added to this note",
                                        ),
                                      ),
                                    );
                                    getNotesList();
                                  } else {
                                    supabse
                                        .from("user_notes")
                                        .insert({
                                          "user_id": user['id'],
                                          "note_id": note['id'],
                                        })
                                        .then((e) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Note Shared with ${user['name']}",
                                              ),
                                            ),
                                          );
                                        });
                                    getNotesList();
                                  }
                                } on PostgrestException catch (e) {
                                  log(e.message);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.message)),
                                  );
                                } catch (e) {
                                  log(e.toString());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(CupertinoIcons.person_add),
                  ),
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
          ).then((value) {
            setState(() {});
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> getNotesList() async {
  String currentUserId = supabse.auth.currentUser!.id;
  log(currentUserId);

  // Notes owned by the user
  final ownedNotes = await supabse
      .from("notes")
      .select("*, users(name,id)")
      .eq("user_id", currentUserId);
  log(ownedNotes.toString());

  // Notes shared with the user
  final sharedNotes = await supabse
      .from("notes")
      .select("*, users(name,id), user_notes!inner(user_id)")
      .eq("user_notes.user_id", currentUserId);
  log(sharedNotes.toString());
  // Merge and remove duplicates
  final allNotes = {...ownedNotes, ...sharedNotes}.toList();

  // Optional: sort by created_at descending
  allNotes.sort((a, b) => b['created_at'].compareTo(a['created_at']));

  return allNotes;
}
