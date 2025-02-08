// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:parties/screens/setup/add_store.dart';
import 'package:parties/screens/setup/services_page.dart';
import '../../constants/colors.dart';
import '../orders.dart';
import 'add_category.dart';
import 'stores_page.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/seller-home';
  DashboardScreen({super.key});

  final List<dynamic> menuList = [
    {
      'title': 'إضافة خدمات',
      'icon': Icons.add,
      'routeName': AddCategory.routeName,
    },
    {
      'title': 'إضافة متاجر',
      'icon': Icons.add,
      'routeName': StoreAuth.routeName,
    },
    {
      'title': 'الطلبات',
      'icon': Icons.shopping_cart_checkout,
      'routeName': OrdersAmin.routeName,
    },
    {
      'title': 'إدارة الخدمات',
      'icon': Icons.manage_history_outlined,
      'routeName': ServicesPage.routeName,
    },
    {
      'title': 'إدارة المتاجر',
      'icon': Icons.store_sharp,
      'routeName': StoresPage.routeName,
    },
    // {
    //   'title': 'معلومات التواصل',
    //   'icon': Icons.insert_chart,
    //   'routeName': ContactInfo.routeName,
    // },
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 48.0,
          right: 18,
          left: 18,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.dashboard,
                      color: primaryColor,
                    ),
                    Text(
                      'إدارة',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: size.height / 1.25,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 25,
                  ),
                  itemCount: menuList.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(menuList[index]['routeName']);
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            menuList[index]['icon'],
                            size: 65,
                            color: primaryColor,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            menuList[index]['title'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
