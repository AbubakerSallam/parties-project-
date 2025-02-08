// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/loading.dart';
import '../../constants/colors.dart';
import 'add_store.dart';

class StoresPage extends StatefulWidget {
  static const routeName = '/store-page';
  const StoresPage({super.key});

  @override
  State<StoresPage> createState() => _StoresPageState();
}

late Stream<QuerySnapshot> _stream;

class _StoresPageState extends State<StoresPage> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('sellers');
  @override
  void initState() {
    super.initState();
    _stream = _reference.snapshots();
  }

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
        title: const Text('المتاجر'),
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
                      'fullname': e['fullname'],
                      'address': e['address'],
                      'image': e['image'],
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
                              StoreAuth(isEdit: true, store: item)));
                    },
                    title: Text('${thisService['fullname']}'),
                    subtitle: Text('${thisService['address']}'),
                    leading: SizedBox(
                      height: 30,
                      width: 30,
                      child: thisService.containsKey('image')
                          ? Image.network('${thisService['image']}')
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
