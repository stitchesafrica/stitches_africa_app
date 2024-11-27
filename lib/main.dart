import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stitches_africa/config/app_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_options.dart';
import 'package:stitches_africa/services/storage_services/secure_storage_service.dart';

SecureServiceStorage secureServiceStorage = SecureServiceStorage();

Future<void> setOrientation() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void setSystemUIOverlayStyle() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> initHive() async {
  await Hive.initFlutter();

  await Future.wait([
    Hive.openBox('user_preferences'),
  ]);
}

Future<void> loadEnvFiles() async {
  await dotenv.load(fileName: '.env').then((_) async {
    await Future.wait([
      secureServiceStorage.storeAlphaVantageApiKey(),
      secureServiceStorage.storeMobileTailorApiKey(),
      secureServiceStorage.storePaystackApiKey(),
      secureServiceStorage.storeOneSignalApiKey(),
      secureServiceStorage.storePaystackSecretApiKey(),
      secureServiceStorage.storeTerminalAfricaSecretApiKey(),
    ]);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setOrientation();
  setSystemUIOverlayStyle();
  await initializeFirebase();
  await initHive();
  await loadEnvFiles();

  //initialize firebase

  runApp(
    Phoenix(
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
                backgroundColor: Utilities.backgroundColor,
                elevation: 0,
                surfaceTintColor: Utilities.backgroundColor),
            cupertinoOverrideTheme: const CupertinoThemeData(
                primaryColor: Utilities.primaryColor,
                textTheme: CupertinoTextThemeData(
                    primaryColor: Utilities.primaryColor)),
            fontFamily: 'DMSans',
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            textTheme: TextTheme(
              bodyMedium: TextStyle(
                color: Utilities.primaryColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            )),
        routerConfig: router,
      ),
    );
  }
}
