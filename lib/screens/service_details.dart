// ignore_for_file: avoid_print, unnecessary_overrides

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:parties/constants/colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../components/loading.dart';

enum Field2 {
  date,
  money,
  note,
  name,
}

class ServiceDetails extends StatefulWidget {
  const ServiceDetails({
    super.key,
    required this.servise,
  });
  final dynamic servise;

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails>
    with TickerProviderStateMixin {
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  final _dateController = TextEditingController();
  final _moneyController = TextEditingController();
  final _noteController = TextEditingController();
  final _nameController = TextEditingController();
  DocumentSnapshot? credential;
  String? username;
  DateTime? _selectedDate;
  String? bookDate;
  List<DateTime> bookedDates = [];
  bool _isLoading = false;

  Future<void> getBookedDates() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('serviceId', isEqualTo: widget.servise.id)
          .where('status', isNotEqualTo: 'canceled')
          .get();

      bookedDates.clear(); // Clear the list before adding new dates

      // ignore: avoid_function_literals_in_foreach_calls
      querySnapshot.docs.forEach((doc) {
        DateTime bookingDate =
            (doc.data() as Map<String, dynamic>)['bookingDate'].toDate();
        bookedDates.add(bookingDate);
      });

      _isLoading = false;
      setState(() {});
    } catch (e) {
      print('Error fetching booked dates: $e');
    }
  }

  _fuckNull() {
    // throw UnimplementedError();
    print('objecoooooooooooooooooooooooooooooooooooooooooooooot');
  }

  Future<void> bookService(
      String serviceId, String userId, DateTime bookingDate) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'serviceId': serviceId,
        'userId': userId,
        'bookingDate': _selectedDate,
        'Note': _noteController.text.trim(),
        'nameofuser': _nameController.text.trim(),
        'PayNumber': _moneyController.text.trim(),
        'title': widget.servise['title'],
        'storename': widget.servise['storename'],
        'name': username,
        'description': widget.servise['description'],
        'status': 'waiting',
      });
    } catch (e) {
      print('Error booking service: $e');
      // Handle error
    }
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

  Future<void> _selectDate(BuildContext context) async {
    if (widget.servise['description'] == 'قاعات تخرج' ||
        widget.servise['description'] == 'شاليهات' ||
        widget.servise['description'] == 'فرق راقصة' ||
        widget.servise['description'] == 'مذيعين' ||
        widget.servise['description'] == 'فنانين') {
      getBookedDates();
    }
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                ' اودع إلى الحساب بإسم التطبيق برقم 8767678 اختر تاريخ الحجز, اسم المودع, ثم المبلغ واكتب ملاحظاتك',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                child: kTextField2(
                  _dateController,
                  '',
                  'التاريخ',
                  Field2.date,
                  onTap: () async {
                    // Show date picker when text field is tapped
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      selectableDayPredicate: (DateTime date) {
                        return !bookedDates
                            .contains(date); // Disable booked dates
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        print(_selectedDate);
                        _dateController.text =
                            '${picked.day}/${picked.month}/${picked.year}';
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              kTextField2(_nameController, 'الإسم الرباعي, اسمك بالحساب',
                  'اسم المودع', Field2.name,
                  onTap: () => _fuckNull()),
              const SizedBox(height: 10),
              kTextField2(_moneyController, '100000', 'المبلغ', Field2.money,
                  onTap: () => _fuckNull()),
              const SizedBox(height: 10),
              kTextField2(_noteController, 'ملاحظة', 'ملاحظة', Field2.note,
                  onTap: () => _fuckNull()),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(15),
                      ),
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      label: const Text(
                        'إلغاء',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(15),
                      ),
                      icon: const Icon(
                        Icons.golf_course,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        _isLoading = true;
                        if (_selectedDate != null &&
                            _moneyController.text.isNotEmpty) {
                          try {
                            // Call bookService function with parameters
                            await bookService(widget.servise.id,
                                currentUserId.toString(), _selectedDate!);
                            if (mounted) {
                              showSnackBar(
                                  'تم تقديم طلبك سيتم مراجعة الإيداع ومن ثم تأكيد الحجز');
                              _isLoading = false;
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            print('Error booking service: $e');
                            if (mounted) {
                              showSnackBar(
                                  'حدث خطأ أثناء تقديم الطلب. يرجى المحاولة مرة أخرى.');
                            }
                          }
                        } else {
                          showSnackBar('يجب تحديد التاريخ وكتابة رقم الإيصال');
                        }
                      },
                      label: const Text(
                        'تأكيد',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget kTextField2(TextEditingController controller, String hint,
      String label, Field2 field2,
      {Function()? onTap}) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      keyboardType: field2 == Field2.date
          ? TextInputType.none
          : field2 == Field2.note || field2 == Field2.name
              ? TextInputType.text
              : TextInputType.number,
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
        switch (field2) {
          case Field2.date:
            if (value!.isEmpty) {
              return 'لايمكن أن يكون التارخ فارغا';
            }
            break;
          case Field2.money:
            if (value!.isEmpty || value.length < 8) {
              return 'تأكد من رقم الإيصال على الأقل ثمانية أحرف.';
            }

            break;
          case Field2.name:
            if (value!.isEmpty) {
              return 'لايمكن أن يكون الإسم فارغا';
            }
            break;
          case Field2.note:
            if (value!.isEmpty) {
              return null;
            }

            break;
        }

        return null;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showImageBottom() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) => SizedBox(
        height: 500,
        child: CarouselSlider.builder(
          itemCount: widget.servise['images'].length,
          itemBuilder: (context, index, i) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  '${index + 1}/${widget.servise['images'].length}',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                  child: Image.network(
                    widget.servise['images'][index],
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          options: CarouselOptions(
            viewportFraction: 1,
            aspectRatio: 1.5,
            height: 500,
            autoPlay: true,
          ),
        ),
      ),
    );
  }

  _fechUser() async {
    credential = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    username = credential!['fullname'];
  }

  Animation<double>? _animation;
  AnimationController? _animationController;
  var isInit = true;
  @override
  void initState() {
    super.initState();
    _fechUser();
    getBookedDates();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      );

      final curvedAnimation = CurvedAnimation(
        curve: Curves.easeInOut,
        parent: _animationController!,
      );
      _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    }
    setState(() {
      isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: litePrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,
        statusBarBrightness: Brightness.dark,
      ),
    );

    var service = widget.servise;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: "حجز",
            iconColor: Colors.white,
            bubbleColor: primaryColor,
            icon: Icons.shopping_cart_outlined,
            titleStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            onPress: () => _selectDate(context),
          ),
          Bubble(
            title: "اتصال",
            iconColor: Colors.white,
            bubbleColor: primaryColor,
            icon: Icons.call,
            titleStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            onPress: () {
              // _animationController!.reverse();
            },
          ),
        ],
        animation: _animation!,
        onPress: () => _animationController!.isCompleted
            ? _animationController!.reverse()
            : _animationController!.forward(),
        iconColor: Colors.white,
        iconData: Icons.add,
        backGroundColor: primaryColor,
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.chevron_left,
                color: primaryColor,
                size: 35,
              ),
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Loading(
                color: primaryColor,
                kSize: 70,
              ),
            )
          : Consumer(
              builder: (context, data, child) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => showImageBottom(),
                      child: Container(
                        height: size.height / 2,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                        child: Swiper(
                          autoplay: true,
                          pagination: const SwiperPagination(
                            builder: SwiperPagination.dots,
                          ),
                          itemCount: service['images'].length,
                          itemBuilder: (context, index) => PhotoView(
                            backgroundDecoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            maxScale: 100.0,
                            imageProvider: NetworkImage(
                              service['images'][index],
                              // fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            service['title'],
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ريال ${service['price']}',
                                style: const TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                              Text(
                                'الصنف: ${service['category']}',
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            service['description'],
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
