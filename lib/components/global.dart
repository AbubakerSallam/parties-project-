import 'package:firebase_auth/firebase_auth.dart';

String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
bool isAdmin = false;
