// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../components/loading.dart';
import '../../../constants/colors.dart';
import 'service_details.dart';

class FavoriteScreen extends StatefulWidget {
  static const routeName = '/cFav-home';
  const FavoriteScreen({super.key});
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late final Stream<QuerySnapshot>? favoriteStream;
  Stream<QuerySnapshot> getFavoriteProductsForUser(String userId) {
    return FirebaseFirestore.instance
        .collection('services')
        .where('favorites.userId', isEqualTo: userId)
        .snapshots();
  }

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    if (currentUserId != null) {
      favoriteStream = FirebaseFirestore.instance
          .collection('services')
          // .where('favorites', arrayContains: currentUserId)
          .snapshots();
    }
  }

  void toggleIsFav(String productId) async {
    final productRef =
        FirebaseFirestore.instance.collection('services').doc(productId);
    final userRef = productRef.collection('favorites').doc(currentUserId);

    final userDoc = await userRef.get();

    if (userDoc.exists) {
      await userRef.delete();
      setState(() {});
    } else {
      await userRef.set({'currentUserId': currentUserId, 'favStatus': true});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: primaryColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 58.0),
          child: Column(
            children: [
              const Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      color: primaryColor,
                    ),
                    Text(
                      'المفضلة',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: size.height / 1.25,
                child: Consumer(
                  builder: (context, data, child) =>
                      StreamBuilder<QuerySnapshot>(
                    stream: favoriteStream,
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 2,
                        ),
                        itemBuilder: (context, index) {
                          var data = snapshot.data!.docs[index];

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('services')
                                  .doc(data.id)
                                  .collection('favorites')
                                  .doc(
                                      currentUserId) // Assuming currentUserId is the current user's ID
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data?.exists == false) {
                                  return const SizedBox.shrink();
                                } else {
                                  // You can also check the 'favStatus' field here if needed
                                  return GestureDetector(
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
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              height: 150,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      data['images'][0]),
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
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 4,
                                            right: 5,
                                            child: Text(
                                              'ريال ${data['price']}',
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
                                                child: const Icon(
                                                    Icons.favorite,
                                                    color: Colors.redAccent),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),

                            //   );
                            // },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
