// ignore_for_file: must_be_immutable, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parties/screens/global_service.dart';

import '../constants/colors.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-page';
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  double xOffset = 0;
  double yOffset = 0;
  @override
  void initState() {
    super.initState();
  }

  bool isDrawerOpen = false;

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
    return AnimatedContainer(
      transform: Matrix4.translationValues(xOffset, yOffset, 0)
        ..scale(isDrawerOpen ? 0.85 : 1.00)
        ..rotateZ(isDrawerOpen ? -50 : 0),
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            isDrawerOpen ? BorderRadius.circular(40) : BorderRadius.circular(0),
      ),
      child: GestureDetector(
        onTap: () {
          if (isDrawerOpen == true) {
            try {
              setState(() {
                xOffset = 0;
                yOffset = 0;
                isDrawerOpen = false;
              });
            } catch (e) {
              print(e.toString());
            }
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    isDrawerOpen
                        ? GestureDetector(
                            child: const Icon(Icons.arrow_back_ios),
                            onTap: () {
                              try {
                                setState(() {
                                  xOffset = 0;
                                  yOffset = 0;
                                  isDrawerOpen = false;
                                });
                              } catch (e) {
                                print(e.toString());
                              }
                            },
                          )
                        : GestureDetector(
                            child: const Icon(Icons.menu),
                            onTap: () {
                              try {
                                setState(() {
                                  xOffset = 265;
                                  yOffset = 80;
                                  isDrawerOpen = true;
                                });
                              } catch (e) {
                                print(e.toString());
                              }
                            },
                          ),
                    const Text(
                      'فرحتي',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          decoration: TextDecoration.none),
                    ),
                    Container(),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Column(
                children: <Widget>[
                  GlobalService(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
