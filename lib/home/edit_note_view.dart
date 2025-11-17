import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:multiuser_notes/auth/login_view.dart';
import 'package:multiuser_notes/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditNoteView extends StatefulWidget {
  final String noteId;
  const EditNoteView({super.key, required this.noteId});

  @override
  State<EditNoteView> createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  Timer? _debounce;
  final title = TextEditingController();
  final content = TextEditingController();
  final contentStream = StreamController.broadcast();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    startContentStream();
    log(widget.noteId);
    content.addListener(() {
      // Cancel previous timer if user is still typing
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      // Start a new timer
      _debounce = Timer(const Duration(seconds: 3), () {
        log('User stopped typing: ${content.text}');
        updateContent();
      });
    });
  }

  updateContent() async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase
          .from("notes")
          .update({"title": title.text.trim(), "content": content.text.trim()})
          .eq('id', widget.noteId)
          .then((val) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Updated!")));
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
  }

  startContentStream() {
    supabase
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('id', widget.noteId)
        .listen((event) {
          log('Stream event: $event');
          title.text = event.first['title'] ?? '';
          content.text = event.first['content'] ?? '';
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
        actions: [isLoading ? loader : SizedBox.shrink()],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        children: [
          SizedBox(height: 2.h),
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
        ],
      ),
    );
  }
}
