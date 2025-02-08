import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/image_picker.dart';
import '../../components/loading.dart';
import '../../constants/colors.dart';

enum Field { fullname, location }

class StoreAuth extends StatefulWidget {
  static const routeName = '/store-auth';

  const StoreAuth({
    super.key,
    this.isEdit = false,
    this.store,
  });
  final bool isEdit;
  final dynamic store;
  @override
  State<StoreAuth> createState() => _StoreAuthState();
}

class _StoreAuthState extends State<StoreAuth> {
  //var userId = '123456789';
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _fullnameController = TextEditingController();
  File? profileImage;
  String? imageFromFire;
  var isLoading = false;
  var isInit = true;
  final firebase = FirebaseFirestore.instance;
  DocumentSnapshot? credential;
  void assignValues() {
    _locationController.text = widget.store['address'];
    _fullnameController.text = widget.store['fullname'];
    imageFromFire = widget.store['image'];
  }

  // custom textfield for all form fields
  Widget kTextField(
    TextEditingController controller,
    String hint,
    String label,
    Field field,
    bool obscureText,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: TextInputType.text,
      autofocus: field == Field.fullname ? true : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryColor),
        hintText: hint,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 2,
            color: primaryColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.grey,
          ),
        ),
      ),
      validator: (value) {
        switch (field) {
          case Field.fullname:
            if (value!.isEmpty || value.length < 5) {
              return 'الإسم غير مكتمل';
            }
            break;

          case Field.location:
            if (value!.isEmpty || value.length < 10) {
              return 'ادخل موقعك بالتفصيل';
            }
            break;
        }
        return null;
      },
    );
  }

  // for selecting photo
  _selectPhoto(File image) {
    setState(() {
      profileImage = image;
    });
  }

  Timer? _timer;
  // loading fnc
  isLoadingFnc() {
    setState(() {
      isLoading = true;
    });
    _timer = Timer(const Duration(seconds: 4), () {
      // Check if the widget is still mounted
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 3), // Set a duration for the SnackBar
        action: SnackBarAction(
          onPressed: () => ScaffoldMessenger.of(context)
              .hideCurrentSnackBar(), // Dismiss the SnackBar
          label: 'إلغاء',
          textColor: Colors.white,
        ),
      ),
    );
  }

  showDeleteOptions() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Image.asset(
                'assets/images/profile.png',
                width: 35,
                color: primaryColor,
              ),
              const Text(
                'حذف المتجر',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'متأكد من حذف المتجر?',
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
                removeProduct(widget.store.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'نعم',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // handle sign in and  sign up
  _handleAuth() async {
    var valid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    if (!valid) {
      return;
    }

    try {
      if (profileImage == null) {
        // profile image is empty
        showSnackBar('لايجب أن تكون الصورة فارغة!');
        return null;
      }

      setState(() {
        isLoading = true;
      });
      var date = DateTime.now().toString();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('store-images')
          .child('$date.jpg');

      File? file;
      file = File(profileImage!.path);

      try {
        await storageRef.putFile(file);
        var downloadUrl = await storageRef.getDownloadURL();
        if (widget.isEdit == true) {
          FirebaseFirestore.instance
              .collection('sellers')
              .doc(widget.store.id)
              .update({
            'fullname': _fullnameController.text.trim(),
            'image': downloadUrl,
            'address': _locationController.text.trim(),
          }).then((value) => {
                    showSnackBar('تم التعديل'),
                    Navigator.of(context).pop(),
                    Navigator.of(context).pop(),
                    setState(() {
                      isLoading = false;
                    }),
                  });
        } else {
          QuerySnapshot existingStores = await FirebaseFirestore.instance
              .collection('sellers')
              .where('fullname', isEqualTo: _fullnameController.text.trim())
              .get();

          if (existingStores.docs.isNotEmpty) {
            showSnackBar('اسم المتجر موجود بالفعل!');
            return;
          }
          await firebase.collection('sellers').add({
            'fullname': _fullnameController.text.trim(),
            'image': downloadUrl,
            'address': _locationController.text.trim(),
          }).then((value) => {
                setState(() {
                  isLoading = false;
                }),
                showSnackBar('تم'),
              });
        }
        if (!mounted) {
          setState(() {
            isLoading = false;
          });
          showSnackBar('حدث خطأ ما!');
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          showSnackBar('حدث خطأ ما');
        }
      }
    } on FirebaseAuthException catch (e) {
      // ignore: unused_local_variable
      var error = 'حدث خطأ ما: !';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        showSnackBar('ايميل او باسسورد خاطئ');
      } else {
        showSnackBar('حدث خطأ ما: $e');
      }
      if (e.message != null) {
        if (e.code == 'user-not-found') {
          error = "المستخدم غير موجود!";
          return;
        } else if (e.code == 'account-exists-with-different-credential') {
          error = "الإيميل مستخدم مسبقا!";
          return;
        } else if (e.code == 'wrong-password') {
          error = 'إيميل أو باسوورد خاطئ!';
          return;
        } else if (e.code == 'network-request-failed') {
          error = 'خطأ في الشبكة!';
          return;
        } else {
          error = e.code;
          return;
        }
      }
    } catch (e) {
      // if (kDebugMode) {
      showSnackBar('حدث خطأ ما: $e');
    } finally {
      Navigator.of(context).pop();
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (isInit) {
      if (widget.isEdit) {
        assignValues();
      }
    }
  }

  void removeProduct(String id) {
    FirebaseFirestore.instance.collection('sellers').doc(id).delete();
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
        backgroundColor: primaryColor,
        title: Text(
          widget.isEdit ? 'تعديل متجر' : 'إضافة متجر',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          widget.isEdit
              ? IconButton(
                  onPressed: () => showDeleteOptions(),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ProfileImagePicker(selectImage: _selectPhoto),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'تسجيل متجر',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(
                        child: Loading(
                          color: primaryColor,
                          kSize: 70,
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            kTextField(
                              _fullnameController,
                              'محلات ...',
                              'اسم المتجر',
                              Field.fullname,
                              false,
                            ),
                            const SizedBox(height: 10),
                            kTextField(
                              _locationController,
                              '',
                              'الموقع',
                              Field.fullname,
                              false,
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(15),
                              ),
                              //onPressed: () => {},
                              onPressed: () {
                                _handleAuth();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'تأكيد المتجر',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<FirebaseFirestore>('firebase', firebase));
    properties
        .add(DiagnosticsProperty<FirebaseFirestore>('firebase', firebase));
  }
}
