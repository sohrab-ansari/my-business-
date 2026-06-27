import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mybusiness/viewmodels/auth_viewmidel.dart';
import 'package:mybusiness/viewmodels/sales_viewmodel.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'viewmodels/product_viewmodel.dart';
import 'viewmodels/customer_viewmodel.dart';
import 'viewmodels/bill_viewmodel.dart';
import 'theme/theme.dart';
import 'auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => CustomerViewModel()),
        ChangeNotifierProvider(create: (_) => SalesViewModel()),
        ChangeNotifierProvider(create: (_) => BillViewModel()),
      ],
      child: MaterialApp(
        title: 'Business Manager',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}