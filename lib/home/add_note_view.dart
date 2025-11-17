import 'package:flutter/material.dart';
import 'package:multiuser_notes/auth/login_view.dart';
import 'package:multiuser_notes/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({super.key});

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  final title = TextEditingController();
  final content = TextEditingController();

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Note')),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        children: [
          Text("Title"),
          SizedBox(height: 2.h),
          TextFormField(
            controller: title,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 4.h),
          Text("Content"),
          SizedBox(height: 2.h),
          TextFormField(
            controller: content,
            maxLines: 10,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 4.h),
          isLoading
              ? loader
              : ElevatedButton(
                  onPressed: () {
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      supabase
                          .from("notes")
                          .insert({
                            "title": title.text.trim(),
                            "content": content.text.trim(),
                          })
                          .then((val) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Note Added Successfully"),
                              ),
                            );
                          });
                    } on PostgrestException catch (e) {
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
                  child: Text('Add Note'),
                ),
        ],
      ),
    );
  }
}
