// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../constants/colors.dart';
import 'package:path/path.dart' as path;

import '../../components/global.dart';
import '../../components/loading.dart';

class UploadProduct extends StatefulWidget {
  static const routeName = '/upload_product';

  const UploadProduct({
    super.key,
    this.storid,
    this.storename,
    this.isEdit = false,
    this.product,
  });
  final String? storid;
  final String? storename;
  final bool isEdit;
  final dynamic product;
  @override
  State<UploadProduct> createState() => _UploadProductState();
}

// for fields
enum Field {
  title,
  price,
  quantity,
  description,
}

enum DropDownType { category, subCategory }

class _UploadProductState extends State<UploadProduct> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<dynamic>? productImages = [];
  final ImagePicker _picker = ImagePicker();
  final userId = currentUserId!;

  var isInit = true;
  var currentImage = 0;
  var isImagePicked = false;
  String checkCat = "";
  var isLoading = false;
  var isCat = false;
  String storeName = "";
  List<dynamic>? productImagesFromFire;
  List<String> subCategory = [];
  List<String> myCategory = [];
  List<dynamic> imageDownloadLinks = [];
  void assignValues() {
    _titleController.text = widget.product['title'];
    _priceController.text = widget.product['price'];
    _descriptionController.text = widget.product['description'];
    productImagesFromFire = widget.product['images'];
    imageDownloadLinks = widget.product['images'];
    productImages = widget.product['images'];
    checkCat = widget.product['storename']!;

    if (checkCat == 'خدمة') {
      isCat = true;
      storeName = widget.product['storename']!;
      _quantityController.text = widget.product['location'];
    } else {
      _quantityController.text = widget.product['quantity'];
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    storeName = widget.storename!;
    if (isInit) {
      if (widget.isEdit) {
        assignValues();
      }
    }
  }

  void removeProduct(String id) {
    FirebaseFirestore.instance.collection('services').doc(id).delete();
  }

  // for selecting photo
  Future _selectPhoto() async {
    List<XFile>? pickedImages;

    pickedImages = await _picker.pickMultiImage(
      maxWidth: 600,
      maxHeight: 600,
    );

    // ignore: unnecessary_null_comparison
    if (pickedImages == null) {
      return null;
    } else if (pickedImages.length < 2) {
      showSnackBar('اختر أكثر من صورة');
      return null;
    }

    // assign the picked image to the profileImage
    setState(() {
      productImages = pickedImages;
      isImagePicked = true;
    });
  }

  // custom textfield for all form fields
  Widget kTextField(
    TextEditingController controller,
    String hint,
    String label,
    Field field,
    int maxLines,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: field == Field.price || field == Field.quantity
          ? TextInputType.number
          : TextInputType.text,
      textInputAction: field == Field.description
          ? TextInputAction.done
          : TextInputAction.next,
      autofocus: field == Field.title ? true : false,
      maxLines: maxLines,
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
          case Field.title:
            if (value!.isEmpty) {
              return 'الاسم يجب الا يكون فارغا';
            }
            break;

          case Field.price:
            if (value!.isEmpty) {
              return 'السعر غير موجود';
            }
            break;

          case Field.quantity:
            {
              return null;
            }

          case Field.description:
            if (value!.isEmpty) {
              return 'الوصف مطلوب';
            }
            break;
        }
        return null;
      },
    );
  }

// snackbar for error message
  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        action: SnackBarAction(
          onPressed: () => Navigator.of(context).pop(),
          label: 'تم',
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
                'حذف ',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'متأكد من الحذف ?',
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
                removeProduct(widget.product.id);
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

  _uploadProduct() async {
    // var userId = FirebaseAuth.instance.currentUser!.uid;
    var valid = _formKey.currentState!.validate();
    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();

    if (!valid) {
      showSnackBar('أكمل كل المتطلبات');
      return null;
    }

    if (productImages == null) {
      showSnackBar('يجب اختيار على الأقل صورتين للمنتج');
      return null;
    }

    List<String> imageDownloadLinks = [];
    setState(() {
      isLoading = true;
    });

    try {
      if (isImagePicked) {
        for (var image in productImages!) {
          var storageRef = FirebaseStorage.instance
              .ref('product-images/${path.basename(image.path)}');

          await storageRef.putFile(File(image.path)).whenComplete(() async {
            await storageRef.getDownloadURL().then(
                  (value) => imageDownloadLinks.add(value),
                );
          });
        }
      }
      if (widget.isEdit == true) {
        FirebaseFirestore.instance
            .collection('services')
            .doc(widget.product.id)
            .update({
          'prod_id': DateTime.now().toString(),
          // 'seller_id': widget.storid,
          'title': _titleController.text.trim(),
          'price': _priceController.text.trim(),
          isCat ? 'location' : _quantityController.text.trim(): {
            'quantity': _quantityController.text.trim()
          },
          'description': _descriptionController.text.trim(),
          'images': imageDownloadLinks,
          'storename': storeName,
          'category': _titleController.text.trim(),
          'upload-date': DateTime.now()
        }).then((value) => {
                  showSnackBar('تم التعديل'),
                  Navigator.of(context).pop(),
                  Navigator.of(context).pop(),
                  setState(() {
                    // currentImage = 0;
                    // productImages = [];
                    // imageDownloadLinks = [];
                    isLoading = false;
                  }),
                });
      } else {
        FirebaseFirestore.instance.collection('services').doc().set({
          'prod_id': DateTime.now().toString(),
          'seller_id': widget.storid,
          'title': _titleController.text.trim(),
          'price': _priceController.text.trim(),
          'quantity': _quantityController.text.trim(),
          'description': _descriptionController.text.trim(),
          'images': imageDownloadLinks,
          'location': "",
          'storename': widget.storename,
          'category': _titleController.text.trim(),
          'upload-date': DateTime.now()
        }).then((value) => {
              setState(() {
                productImages = [];
                imageDownloadLinks = [];
                isLoading = false;
              }),
              showSnackBar('تم'),
            });
      }
    } on FirebaseException catch (e) {
      showSnackBar('حدث خطأ ما ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('حدث خطأ ما  :)');
      }
    } finally {
      setState(() {
        // _formKey.currentState!.reset();

        // productImages = [];
        // imageDownloadLinks = [];
        isLoading = false;
      });
    }
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
          widget.isEdit ? 'تعديل ' : 'إضافة ',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _uploadProduct(),
            icon: const Icon(
              Icons.save,
              color: Colors.white,
            ),
          ),
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
        padding: const EdgeInsets.only(
          top: 18.0,
          left: 18,
        ),
        child: isLoading
            ? const Loading(color: primaryColor, kSize: 50)
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          child: Center(
                            child: productImages == null
                                ? Image.asset(
                                    'assets/images/holder.png',
                                    color: primaryColor,
                                  )
                                //this will load imgUrl from firebase
                                : !isImagePicked
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Image.network(
                                            productImages![currentImage]),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Image.file(
                                          File(productImages![currentImage]
                                              .path),
                                        ),
                                      ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => _selectPhoto(),
                            child: CircleAvatar(
                              backgroundColor: litePrimary,
                              child: const Icon(
                                Icons.photo,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        productImages == null
                            ? const SizedBox.shrink()
                            : Positioned(
                                bottom: 10,
                                left: 10,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    productImages = null;
                                  }),
                                  child: CircleAvatar(
                                    backgroundColor: litePrimary,
                                    child: const Icon(
                                      Icons.delete_forever,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                    const SizedBox(height: 10),
                    productImages == null
                        ? const SizedBox.shrink()
                        : SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: productImages!.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    currentImage = index;
                                  }),
                                  child: Container(
                                    height: 60,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: isImagePicked
                                          ? DecorationImage(
                                              image: FileImage(
                                                File(
                                                    productImages![index].path),
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : DecorationImage(
                                              image: NetworkImage(
                                                productImages![index],
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            kTextField(
                              _titleController,
                              'شاي',
                              'الاسم ',
                              Field.title,
                              1,
                            ),
                            const SizedBox(height: 20),
                            kTextField(
                              _priceController,
                              '100',
                              'السعر',
                              Field.price,
                              1,
                            ),
                            const SizedBox(height: 20),
                            kTextField(
                              _quantityController,
                              isCat ? 'عدن / المعلا' : '10',
                              isCat ? 'الموقع' : 'الكمية',
                              Field.quantity,
                              1,
                            ),
                            const SizedBox(height: 20),
                            kTextField(
                              _descriptionController,
                              'هذا الشاي..',
                              'وصف ',
                              Field.description,
                              3,
                            ),
                            const SizedBox(height: 20),
                          ],
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
