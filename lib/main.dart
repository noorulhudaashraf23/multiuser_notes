import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:multiuser_notes/auth/login_view.dart';
import 'package:multiuser_notes/firebase_messaging_service.dart';
import 'package:multiuser_notes/firebase_options.dart';
import 'package:multiuser_notes/home/home_view.dart';
import 'package:multiuser_notes/local_notifications_service.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(
    localNotificationsService: localNotificationsService,
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: StreamBuilder(
            stream: supabase.auth.onAuthStateChange,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(body: Center(child: loader));
              }
              final session = snapshot.data?.session;
              if (session == null) {
                return LoginView();
              } else {
                return HomeView();
              }
            },
          ),
          // home: LoginView(),
        );
      },
    );
  }
}
