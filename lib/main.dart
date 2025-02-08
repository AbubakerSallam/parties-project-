// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parties/firebase_options.dart';
import 'constants/colors.dart';
import 'routes/routes.dart';
import 'screens/drawer_screen.dart';
import 'screens/entry_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فرحتي',
      theme: ThemeData(
        fontFamily: 'Mada',
        primaryColor: primaryColor,
      ),
      debugShowCheckedModeBanner: false,
      home: const EntryScreen(),
      routes: routes,
    );
  }
}

class HomeWidget extends StatelessWidget {
  static const routeName = '/home-screen';
  const HomeWidget({
    super.key,
  });

//  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:  Stack(
              children: [
                DrawerScreen(),
                HomeScreen(),
              ],
            ),
    );
  }
}
