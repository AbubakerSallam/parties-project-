// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'categories/stores.dart';
import 'categories/shalehaat.dart';
import 'categories/printing.dart';
import 'categories/kaat.dart';
import 'categories/khaiateen.dart';
import 'categories/others.dart';
import 'categories/photographers.dart';
import 'categories/singers.dart';
import 'categories/monaseqeen.dart';
import 'categories/cakes.dart';

class GlobalService extends StatefulWidget {
  static const routeName = '/global';
  const GlobalService({
    super.key,
  });
  // final int serviceNomber;
  @override
  State<GlobalService> createState() => _GlobalServiceState();
}

class _GlobalServiceState extends State<GlobalService> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 38.0),
        child: Column(
          children: <Widget>[
            NewPadding(
              image1: 'assets/images/gra.jpg',
              text1: 'قاعات تخرج',
              onTapHandler: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryWidget(
                    currentTabIndex: 0,
                  ),
                ),
              ),
              onTapHandler2: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryWidget(
                    currentTabIndex: 1,
                  ),
                ),
              ),
              image2: 'assets/images/camera.jpg',
              text2: 'مصورين',
            ),
            const SizedBox(
              height: 40,
            ),
            NewPadding(
              image1: 'assets/images/Group.jpg',
              text1: 'خدمات إضافيه',
              onTapHandler: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryWidget(
                    currentTabIndex: 2,
                  ),
                ),
              ),
              onTapHandler2: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryWidget(
                    currentTabIndex: 3,
                  ),
                ),
              ),
              image2: 'assets/images/shop.jpg',
              text2: 'متاجر',
            ),
            const SizedBox(
              height: 40,
            ),
            NewPadding(
              image1: 'assets/images/drow.jpg',
              text1: 'طباعة',
              onTapHandler: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryWidget(
                    currentTabIndex: 4,
                  ),
                ),
              ),
              onTapHandler2: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryWidget(
                    currentTabIndex: 5,
                  ),
                ),
              ),
              image2: 'assets/images/sp55.png',
              text2: 'خياطين',
            ),
            const SizedBox(
              height: 40,
            ),
            NewPadding(
              image1: 'assets/images/singer2.jpg',
              text1: 'فنون',
              onTapHandler: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryWidget(
                    currentTabIndex: 6,
                  ),
                ),
              ),
              onTapHandler2: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryWidget(
                    currentTabIndex: 7,
                  ),
                ),
              ),
              image2: 'assets/images/water.png',
              text2: 'شاليهات',
            ),
            const SizedBox(
              height: 40,
            ),
            NewPadding(
              image1: 'assets/images/monaseqeen.jpg',
              text1: 'منسقيين',
              onTapHandler: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryWidget(
                    currentTabIndex: 8,
                  ),
                ),
              ),
              onTapHandler2: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryWidget(
                    currentTabIndex: 9,
                  ),
                ),
              ),
              image2: 'assets/images/cakes.jpg',
              text2: 'معجنات',
            ),
          ],
        ),
      ),
    );
  }
}

class NewPadding extends StatelessWidget {
  String? image1;
  String? text1;
  String? image2;
  String? text2;
  Function? onTapHandler;
  Function? onTapHandler2;

  NewPadding({
    super.key,
    this.image1,
    this.text1,
    this.image2,
    this.text2,
    this.onTapHandler,
    this.onTapHandler2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () => onTapHandler!(),
            child: Container(
              width: 140,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Image(
                      height: 100,
                      width: 100,
                      image: AssetImage(image1!),
                    ),
                  ),
                  Text(
                    text1!,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        decoration: TextDecoration.none),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onTapHandler2!(),
            child: Container(
              width: 140,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Image(
                      height: 100,
                      width: 100,
                      image: AssetImage(image2!),
                    ),
                  ),
                  Text(
                    text2!,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        decoration: TextDecoration.none),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
    required this.currentTabIndex,
  });
  final int currentTabIndex;

  final categoriesList = const [
    Kaat(),
    Photographers(),
    Other(),
    Store(),
    Printing(),
    Khaiateen(),
    Singers(),
    Shalehaat(),
    Monaseqqn(),
    Cakes(),
  ];
  @override
  Widget build(BuildContext context) {
    final List<String> category = [
      'قاعات تخرج',
      'مصورين',
      'خدمات إضافيه',
      'متاجر',
      'طباعة',
      'خياطين',
      'فنانين',
      'شاليهات',
      'منسقيين',
      'معجنات',
    ];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 38.0),
        child: Column(
          children: [
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    category[currentTabIndex],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            categoriesList[currentTabIndex],
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
