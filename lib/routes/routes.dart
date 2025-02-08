import 'package:parties/screens/auth.dart';

import '../main.dart';
import '../screens/contact_info.dart';
import '../screens/favorites.dart';
import '../screens/global_service.dart';
import '../screens/home_screen.dart';
import '../screens/orders.dart';
import '../screens/setup/add_category.dart';
import '../screens/setup/add_store.dart';
import '../screens/setup/admin_page.dart';
import '../screens/setup/services_page.dart';
import '../screens/setup/stores_page.dart';
import '../screens/splash.dart';
import '../screens/user_orders.dart';

var routes = {
  HomeWidget.routeName: (context) => const HomeWidget(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  Auth.routeName: (context) => const Auth(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  StoreAuth.routeName: (context) => const StoreAuth(),
  AddCategory.routeName: (context) => const AddCategory(),
  GlobalService.routeName: (context) => const GlobalService(),
  DashboardScreen.routeName: (context) => DashboardScreen(),
  OrdersAmin.routeName: (context) => const OrdersAmin(),
  UserOrders.routeName: (context) => const UserOrders(),
  ServicesPage.routeName: (context) => ServicesPage(),
  FavoriteScreen.routeName: (context) => const FavoriteScreen(),
  ContactInfo.routeName: (context) => const ContactInfo(),
  StoresPage.routeName: (context) => const StoresPage(),
};
