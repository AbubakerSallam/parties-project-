import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../constants/colors.dart';

class OrdersAmin extends StatefulWidget {
  static const routeName = '/admin_orders';

  const OrdersAmin({Key? key}) : super(key: key);

  @override
  State<OrdersAmin> createState() => _OrdersAminState();
}

class _OrdersAminState extends State<OrdersAmin> {
  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('bookings');

  Stream<QuerySnapshot> getOrdersStream() {
    return ordersCollection
        .orderBy('bookingDate', descending: true)
        .snapshots();
  }

  Future<bool> showEditOrdeOptions() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'تنبيه !!',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'تأكيد الطلب؟',
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
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'تأكيد',
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
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'رجوع',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<bool> showRefuseOrdeOptions() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'تنبيه !!',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'رفض الطلب؟',
            style: TextStyle(
              color: primaryColor,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'رفض',
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
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'رجوع',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
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
                  var note = order['Note'];
                  var payNumber = order['PayNumber'];
                  var title = order['title'];
                  var name = order['name'];
                  var description = order['description'];
                  var storename = order['storename'] ?? 'خدمة';
                  var status = order['status'];
                  Timestamp timestamp = order['bookingDate'];
                  var nameOfDeposit = order['nameofuser'];
                  DateTime bookingDate = timestamp.toDate();
                  var formattedDate =
                      DateFormat('dd/MM/yyyy').format(bookingDate);

                  return GestureDetector(
                    onTap: () async {
                      bool ready = false;
                      if (order['status'] == 'waiting') {
                        ready = await showEditOrdeOptions();
                        if (ready == true) {
                          FirebaseFirestore.instance
                              .collection('bookings')
                              .doc(order.id)
                              .update({"status": 'confirmd'});
                        }
                      }
                    },
                    child: Card(
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
                                  onTap: () async {
                                    bool ready = false;
                                    if (order['status'] == 'waiting') {
                                      ready = await showRefuseOrdeOptions();
                                      if (ready == true) {
                                        FirebaseFirestore.instance
                                            .collection('bookings')
                                            .doc(order.id)
                                            .update({"status": 'canceled'});
                                      }
                                    }
                                  },
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
                                  "متجر   : $storename",
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "اسم المودع   : $nameOfDeposit",
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
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
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
