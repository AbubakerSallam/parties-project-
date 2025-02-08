// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parties/screens/setup/add_product_to_store.dart';

import '../../components/loading.dart';
import '../../constants/colors.dart';

class ServicesPage extends StatelessWidget {
  static const routeName = '/service-page';
  ServicesPage({super.key}) {
    _stream = _reference.snapshots();
  }
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('services');
  late Stream<QuerySnapshot> _stream;

  @override
  Widget build(BuildContext context) {
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
        title: const Text('الخدمات'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text(
              'لا بيانات!',
            ));
          }
          if (snapshot.hasData) {
            QuerySnapshot querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot.docs;
            List<Map> services = documents
                .map((e) => {
                      'id': e.id,
                      'location': e['location'],
                      'description': e['description'],
                      'category': e['category'],
                      'images': e['images'],
                      'title': e['title']
                    })
                .toList();
            return ListView.builder(
                itemCount: services.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = snapshot.data!.docs[index];
                  Map thisService = services[index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              UploadProduct(isEdit: true, product: item)));
                    },
                    title: Text('${thisService['title']}'),
                    subtitle: Text('${thisService['category']}'),
                    leading: SizedBox(
                      height: 30,
                      width: 30,
                      child: thisService.containsKey('images')
                          ? Image.network('${thisService['images'][0]}')
                          : Container(),
                    ),
                  );
                });
          }
          return const Loading(
            color: primaryColor,
            kSize: 30,
          );
        },
      ),
    );
  }
}
