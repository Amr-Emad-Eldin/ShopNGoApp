import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shop_n_goo/Tabs/Home/Cart_Page.dart';
import 'package:shop_n_goo/Tabs/Home/HomeTab.dart';
import 'package:shop_n_goo/Tabs/Home/Home_Screen.dart';
import 'package:shop_n_goo/Tabs/Home/Personal_offers.dart';
import 'package:shop_n_goo/Tabs/Home/Summary_order.dart';
import 'package:shop_n_goo/Tabs/Home/Thank_u.dart';
import 'package:shop_n_goo/Tabs/Home/View_order_Summary.dart';
import 'package:shop_n_goo/Tabs/Scanner/ScannerTab.dart';
import 'package:shop_n_goo/Tabs/Settings/ProfileTab.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/First_Screen.dart';
import 'package:shop_n_goo/UserInfo/SignIn.dart';
import 'package:shop_n_goo/UserInfo/signUp.dart';
import 'package:shop_n_goo/UserInfo/otp_verification.dart';
import 'package:shop_n_goo/cubit/auth/auth_cubit.dart';
import 'Tabs/Settings/About_us.dart';
import 'Tabs/Settings/Edit_Profile.dart';
import 'Tabs/Settings/Privacy_policy.dart';
import 'Tabs/Settings/SettingsProvider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (_) => SettingProvider(), child: ShopNGo()));
}

class ShopNGo extends StatelessWidget {
  const ShopNGo({super.key});

  @override
  Widget build(BuildContext context) {
    SettingProvider settingProvider = Provider.of<SettingProvider>(context);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // Black icons
        statusBarColor: Colors.transparent, // Transparent status bar
      ),
    );

    return BlocProvider(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case FirstScreen.routeName:
              return MaterialPageRoute(builder: (_) => FirstScreen());
            case signUp.routeName:
              return MaterialPageRoute(builder: (_) => signUp());
            case signIn.routeName:
              return MaterialPageRoute(builder: (_) => signIn());
            case OtpVerificationScreen.routeName:
              // Extract email from route arguments
              final args = settings.arguments as Map<String, dynamic>?;
              final email = args?['email'] ?? '';
              return MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email));
            case EditProfile.routeName:
              return MaterialPageRoute(builder: (_) => EditProfile());
            case AboutUs.routeName:
              return MaterialPageRoute(builder: (_) => AboutUs());
            case PrivacyPolicy.routeName:
              return MaterialPageRoute(builder: (_) => PrivacyPolicy());
            case Profiletab.routeName:
              return MaterialPageRoute(builder: (_) => Profiletab());
            case SummaryOrderPage.routeName:
              return MaterialPageRoute(builder: (_) => SummaryOrderPage());
            case ThankU.routeName:
              return MaterialPageRoute(builder: (_) => ThankU());
            case HomeTab.routeName:
              return MaterialPageRoute(builder: (_) => HomeTab());
            case HomeScreen.routeName:
              return MaterialPageRoute(builder: (_) => HomeScreen());
            case ViewOrderSummary.routeName:
              return MaterialPageRoute(builder: (_) => ViewOrderSummary());
            case CartPage.routeName:
              return MaterialPageRoute(builder: (_) => CartPage());
            case PersonalOffers.routeName:
              return MaterialPageRoute(builder: (_) => PersonalOffers());
            case Scannertab.routeName:
              return MaterialPageRoute(builder: (_) => Scannertab());
            default:
              return MaterialPageRoute(builder: (_) => FirstScreen());
          }
        },
        initialRoute: FirstScreen.routeName,
        theme: ThemeData(
          scaffoldBackgroundColor: AppTheme.Bg,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light, // For iOS: (dark icons)
              statusBarIconBrightness:
                  Brightness.dark, // For Android: (dark icons)
            ),
          ),
        ),
      ),
    );
  }
}
