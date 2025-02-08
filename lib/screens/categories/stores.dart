import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/global.dart';
import '../../components/loading.dart';
import '../../constants/colors.dart';
import '../setup/add_product_to_store.dart';
import 'store_details.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
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

  @override
  void initState() {
    super.initState();
    checkUserIsAdmin();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final Stream<QuerySnapshot> storeStream =
        FirebaseFirestore.instance.collection('sellers').snapshots();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 38.0),
        child: Column(
          children: [
            SizedBox(
              height: size.height / 1.25,
              child: StreamBuilder<QuerySnapshot>(
                stream: storeStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    return Column(
                      children: [
                        Image.asset(
                          'assets/images/holder.png',
                          width: 150,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'لايوجد متاجر بعد!',
                          style: TextStyle(
                            color: primaryColor,
                          ),
                        )
                      ],
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data!.docs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 2,
                    ),
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StoreDetails(
                                store: data,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Stack(
                              children: [
                                Card(
                                  elevation: 7.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          data['image'],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        data['fullname'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            data['address'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                _isAdmin
                                    ? Positioned(
                                        top: 10,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (_isAdmin) {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    UploadProduct(
                                                  storid: data.id,
                                                  storename: data['fullname'],
                                                ),
                                              ));
                                            }
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: _isAdmin
                                                ? Colors.red
                                                : litePrimary,
                                            child: const Icon(
                                              Icons.store_outlined,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
