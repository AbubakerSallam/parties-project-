// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parties/constants/colors.dart';
import 'package:parties/screens/auth.dart';
import 'package:parties/screens/contact_info.dart';
import 'package:parties/screens/favorites.dart';
import 'package:parties/screens/user_orders.dart';

import 'setup/admin_page.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  DrawerScreenState createState() => DrawerScreenState();
}

class DrawerScreenState extends State<DrawerScreen> {
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  bool _isAdmin = false;
  Future<void> checkUserIsAdmin() async {
    DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
        .instance
        .collection('admins')
        .doc(currentUserId)
        .get();

    if (mounted) {
      setState(() {
        _isAdmin = userData.exists;
      });
    }
  }

  _logout() {
    if (currentUserId != null) {
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamed(Auth.routeName);
    }
  }

  showLogoutOptions() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Image.asset(
                'assets/images/profile.png',
                width: 35,
                color: primaryColor,
              ),
              const Text(
                'تسجيل خروج',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'متأكد من تسجيل الخروج?',
            style: TextStyle(
              color: primaryColor,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _logout(),
              child: const Text(
                'نعم',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    checkUserIsAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor,
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 40, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const Image(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/profile.png'),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'فرحتي',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                NewRow(
                  text: 'الإعدادات',
                  icon: Icons.settings,
                  onTapHandler: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                NewRow(
                  text: 'معلوماتي',
                  icon: Icons.person_outline,
                  onTapHandler: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                _isAdmin
                    ? NewRow(
                        text: 'التحكم',
                        icon: Icons.chat_bubble_outline,
                        onTapHandler: () {
                          Navigator.of(context)
                              .pushNamed(DashboardScreen.routeName);
                        },
                      )
                    : const SizedBox.shrink(),
                _isAdmin
                    ? const SizedBox(
                        height: 20,
                      )
                    : const SizedBox.shrink(),
                NewRow(
                  text: 'حجوزاتي',
                  icon: Icons.bookmark_border,
                  onTapHandler: () {
                    Navigator.of(context).pushNamed(UserOrders.routeName);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                NewRow(
                  text: 'المفضلة',
                  icon: Icons.favorite_border,
                  onTapHandler: () {
                    Navigator.of(context).pushNamed(FavoriteScreen.routeName);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                NewRow(
                  text: 'الدعم',
                  icon: Icons.lightbulb_outline,
                  onTapHandler: () {
                    Navigator.of(context).pushNamed(ContactInfo.routeName);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            GestureDetector(
              onTap: () => showLogoutOptions(),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.cancel,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'تسجيل خروج',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NewRow extends StatelessWidget {
  IconData? icon;
  String? text;
  Function? onTapHandler;
  NewRow({
    super.key,
    this.icon,
    this.text,
    this.onTapHandler,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTapHandler!(),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
          ),
          const SizedBox(
            width: 20,
          ),
          Text(
            text!,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}
