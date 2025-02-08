import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../constants/colors.dart';

class UserOrders extends StatefulWidget {
  static const routeName = '/user_orders';

  const UserOrders({Key? key}) : super(key: key);

  @override
  State<UserOrders> createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('bookings');

  Stream<QuerySnapshot> getOrdersStream() {
    return ordersCollection
        .orderBy('bookingDate', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> ordersStream = getOrdersStream();

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
        backgroundColor: Colors.purple, // Change to your desired color
        title: const Text(
          'الطلبات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersStream,
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
            List<QueryDocumentSnapshot> ordersDocs = snapshot.data!.docs;
            if (ordersDocs.isEmpty) {
              return const Center(
                child: Text('لا طلبات لعرضها'),
              );
            } else {
              return ListView.builder(
                itemCount: ordersDocs.length,
                itemBuilder: (context, index) {
                  QueryDocumentSnapshot order = ordersDocs[index];
                  if (order['userId'] == currentUserId) {
                    var note = order['Note'];
                    var payNumber = order['PayNumber'];
                    var title = order['title'];
                    var name = order['name'];
                    var description = order['description'];
                    var status = order['status'];
                    Timestamp timestamp;
                    timestamp = order['bookingDate'];
                    DateTime bookingDate = timestamp.toDate();
                    var formattedDate =
                        DateFormat('dd/MM/yyyy').format(bookingDate);
                    return Card(
                      color: '$status' == 'waiting'
                          ? Colors.yellow
                          : '$status' == 'canceled'
                              ? Colors.red[400]
                              : Colors.lightBlue,
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  child: CircleAvatar(
                                    backgroundColor: '$status' == 'waiting'
                                        ? Colors.yellow
                                        : '$status' == 'canceled'
                                            ? Colors.red[400]
                                            : Colors
                                                .lightBlue, // Change to your desired color
                                    child: Icon(
                                      '$status' == 'waiting'
                                          ? Icons.watch_later_outlined
                                          : '$status' == 'canceled'
                                              ? Icons.cancel_outlined
                                              : Icons.cloud_done_sharp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$status' == 'waiting'
                                      ? 'قيد التأكيد'
                                      : '$status' == 'canceled'
                                          ? 'الطلب مرفوض'
                                          : 'الحجز مؤكد',
                                  // date.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22.0,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  // date.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'ملاحظة  : $note',
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'رقم الإيصال  : $payNumber',
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'اسم الخدمة   : $title',
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'اسم العميل   : $name',
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'وصف الخدمة   : $description',
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return null;
                },
              );
            }
          }
        },
      ),
    );
  }
}
