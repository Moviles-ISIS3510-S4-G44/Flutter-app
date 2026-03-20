import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_flutter_application/ui/home/home_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/login/login_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/signup/signup_viewmodel.dart';
import 'ui/router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginModel()),
        ChangeNotifierProvider(create: (_) => SignUpModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel(listingRepository: ListingRepository()),),
        ],
      child: MaterialApp.router(
        title: 'Uniandes Marketplace',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}