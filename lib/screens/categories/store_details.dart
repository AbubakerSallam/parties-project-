import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../services_screen.dart';

class StoreDetails extends StatefulWidget {
  const StoreDetails({
    super.key,
    required this.store,
  });
  final dynamic store;

  @override
  State<StoreDetails> createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<StoreDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var store = widget.store;

    final Stream<QuerySnapshot> productsStream = FirebaseFirestore.instance
        .collection('services')
        .where('seller_id', isEqualTo: store.id)
        .snapshots();

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.chevron_left,
                size: 35,
                color: primaryColor,
              ),
            );
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18.0),
            child: Icon(
              Icons.storefront,
              color: primaryColor,
              size: 35,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: size.height / 3.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(store['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    store['fullname'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(store['address']),
                      const SizedBox(
                        width: 10,
                      ),
                      const Icon(
                        Icons.location_pin,
                        color: primaryColor,
                        size: 21.1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height / 1.25,
              child: ServicesScreen(
                service: productsStream,
                // servise:productsStream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
