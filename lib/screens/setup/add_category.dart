import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../components/global.dart';
import '../../components/loading.dart';
import '../../constants/colors.dart';

class AddCategory extends StatefulWidget {
  static const routeName = '/add-cat';

  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

// for fields
enum Field {
  title,
  price,
  location,
  description,
}

enum DropDownType { category }

class _AddCategoryState extends State<AddCategory> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<XFile>? productImages;
  final ImagePicker _picker = ImagePicker();
  final userId = currentUserId!;

  final List<String> category = [
    'قاعات تخرج',
    'مصورين',
    'خدمات إضافيه',
    'طباعة',
    'خياطين',
    'فنانين',
    'فرق راقصة',
    'شاليهات',
    'مذيعين',
    'تمثيل مسرحي',
    'منسقيين',
    'معجنات',

  ];

  var isInit = true;
  var currentImage = 0;
  var currentCategory = '';
  var isLoading = false;
  List<String> subCategory = [];
  List<String> myCategory = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      currentCategory = category[0];
    }
    setState(() {
      isInit = false;
    });

    super.didChangeDependencies();
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
    });
  }

  // custom dropdown
  Widget kDropDownField(
    DropDownType dropDownType,
    List<String> list,
    String currentValue,
    String label,
  ) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryColor),
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
      value: currentValue,
      borderRadius: BorderRadius.circular(20),
      items: list
          .map(
            (data) => DropdownMenuItem(
              value: data,
              child: Text(data),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          currentValue = value.toString();
          if (dropDownType == DropDownType.category) {
            currentCategory = value.toString();
          }
        });
      },
    );
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
      keyboardType:
          field == Field.price ? TextInputType.number : TextInputType.text,
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

          case Field.location:
            if (value!.isEmpty) {
              return 'الموقع فارغ';
            }
            break;

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

  _uploadCategory() async {
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
      for (var image in productImages!) {
        var storageRef =
            FirebaseStorage.instance.ref('images/${path.basename(image.path)}');

        await storageRef.putFile(File(image.path)).whenComplete(() async {
          await storageRef.getDownloadURL().then(
                (value) => imageDownloadLinks.add(value),
              );
        });
      }

      FirebaseFirestore.instance.collection('services').doc().set({
        'cat_id': DateTime.now().toString(),
        'seller_id': '',
        'storename': 'خدمة',
        'title': _titleController.text.trim(),
        'price': _priceController.text.trim(),
        'location': _quantityController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': currentCategory,
        'images': imageDownloadLinks,
        'upload-date': DateTime.now(),
        'quantity': "",
      }).then((value) => {
            showSnackBar('تم'),
          });
    } on FirebaseException catch (e) {
      showSnackBar('حدث خطأ ما ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('حدث خطأ ما  :)');
      }
    } finally {
      setState(() {
        Navigator.of(context).pop();
        isLoading = false;

        // _formKey.currentState!.reset();

        productImages = [];
        imageDownloadLinks = [];
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
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
        title: const Text(
          'إضافة خدمة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _uploadCategory(),
            icon: const Icon(
              Icons.save,
              color: Colors.white,
            ),
          )
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
                                // this will load imgUrl from firebase
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.file(
                                      File(productImages![currentImage].path),
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
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(productImages![index].path),
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
                              'قاعة الشمس',
                              'اسم الخدمة',
                              Field.title,
                              1,
                            ),
                            const SizedBox(height: 20),
                            kDropDownField(
                              DropDownType.category,
                              category,
                              currentCategory,
                              'الصنف',
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
                              'عدن / المعلا',
                              'الموقع',
                              Field.location,
                              1,
                            ),
                            const SizedBox(height: 20),
                            kTextField(
                              _descriptionController,
                              'هذا ..',
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
