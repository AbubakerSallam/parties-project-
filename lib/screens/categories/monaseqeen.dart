import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services_screen.dart';

class Monaseqqn extends StatelessWidget {
  const Monaseqqn({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final firestore = FirebaseFirestore.instance;

    final Stream<QuerySnapshot> serviceStream = firestore
        .collection('services')
        .where('category', isEqualTo: 'منسقيين')
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
