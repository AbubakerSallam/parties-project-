import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/colors.dart';

class ContactInfo extends StatefulWidget {
  static const routeName = '/contact-info';
  const ContactInfo({super.key});

  @override
  State<ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {
  final CollectionReference contactCollection =
      FirebaseFirestore.instance.collection('contact');

  Stream<QuerySnapshot> getContactStream() {
    return contactCollection.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> contactStream = getContactStream();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: litePrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'معلومات التواصل',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: contactStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error fetching orders: ${snapshot.error ?? "Unknown error"}',
                ),
              );
            } else {
              List<QueryDocumentSnapshot> contactDocs = snapshot.data!.docs;
              if (contactDocs.isEmpty) {
                return const Center(
                  child: Text('لا طلبات لعرضها'),
                );
              } else {
                return ListView.builder(
                    itemCount: contactDocs.length,
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot contact = contactDocs[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 23.0, top: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTextWithDivider('الإسم : ${contact['name']}'),
                            const SizedBox(height: 10),
                            buildTextWithDivider(
                                'إيميل :  ${contact['email']}'),
                            const SizedBox(height: 10),
                            buildTextWithDivider(
                                'الرقم :  ${contact['number']}'),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    });
              }
            }
          }),
    );
  }

  Widget buildTextWithDivider(String text) {
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: primaryColor, // Change text color here
            ),
          ),
          const WidgetSpan(
            child: Divider(
              color: Colors.blueAccent,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
