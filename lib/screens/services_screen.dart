import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parties/screens/service_details.dart';
import 'package:provider/provider.dart';

import '../components/loading.dart';
import '../constants/colors.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({
    super.key,
    required this.service,
  });
  final Stream<QuerySnapshot<Object?>> service;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
  }

  void toggleIsFav(String productId) async {
    final productRef =
        FirebaseFirestore.instance.collection('services').doc(productId);
    final userRef = productRef.collection('favorites').doc(currentUserId);

    final userDoc = await userRef.get();

    if (userDoc.exists) {
      await userRef.delete();
    } else {
      await userRef.set({'currentUserId': currentUserId, 'favStatus': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, data, child) => StreamBuilder<QuerySnapshot>(
        stream: widget.service,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('حدث خطأ ما ): '),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Loading(
                color: primaryColor,
                kSize: 30,
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/holder.png',
                    width: 120,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'لا بيانات!',
                    style: TextStyle(
                      color: primaryColor,
                    ),
                  )
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data!.docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ServiceDetails(
                        servise: data,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(data['images'][0]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 5,
                          child: Text(
                            '${data['title']}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 5,
                          child: Text(
                            'الموقع: ${data['location'] ?? "موقع المتجر"}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              toggleIsFav(data.id);
                              setState(() {});
                            },
                            child: CircleAvatar(
                              backgroundColor: litePrimary,
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('services')
                                    .doc(data.id)
                                    .collection('favorites')
                                    .doc(currentUserId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data?.exists == false) {
                                    return const Icon(Icons.favorite_border,
                                        color: Colors.redAccent);
                                  } else {
                                    return const Icon(Icons.favorite,
                                        color: Colors.redAccent);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
