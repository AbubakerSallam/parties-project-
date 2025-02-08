import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../global_service.dart';
import '../services_screen.dart';

class Singers extends StatelessWidget {
  const Singers({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NewPadding(
          image1: 'assets/images/singer2.jpg',
          text1: 'فنانين',
          onTapHandler: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ArtWidget(
                currentTabIndex: 0,
              ),
            ),
          ),
          onTapHandler2: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ArtWidget(
                currentTabIndex: 1,
              ),
            ),
          ),
          image2: 'assets/images/sp2.png',
          text2: 'فرق راقصة',
        ),
        const SizedBox(
          height: 40,
        ),
        NewPadding(
          image1: 'assets/images/profile.png',
          text1: 'مذيعين',
          onTapHandler: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ArtWidget(
                currentTabIndex: 2,
              ),
            ),
          ),
          onTapHandler2: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ArtWidget(
                currentTabIndex: 3,
              ),
            ),
          ),
          image2: 'assets/images/shop.jpg',
          text2: 'تمثيل مسرحي',
        ),
      ],
    );
  }
}

class ArtWidget extends StatelessWidget {
  const ArtWidget({
    super.key,
    required this.currentTabIndex,
  });
  final int currentTabIndex;

  @override
  Widget build(BuildContext context) {
    final List<String> category = [
      'فنانين',
      'فرق راقصة',
      'مذيعين',
      'تمثيل مسرحي',
    ];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 38.0),
        child: Column(
          children: [
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    category[currentTabIndex],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Artlist(service: category[currentTabIndex]),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class Artlist extends StatelessWidget {
  const Artlist({
    super.key,
    required this.service,
  });
  final String service;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final firestore = FirebaseFirestore.instance;

    final Stream<QuerySnapshot> serviceStream = firestore
        .collection('services')
        .where('category', isEqualTo: service.toString())
        .snapshots();

    return Column(
      children: [
        SizedBox(
           height: size.height / 1.25,
            child: ServicesScreen(
              service: serviceStream,
            ))
      ],
    );
  }
}
