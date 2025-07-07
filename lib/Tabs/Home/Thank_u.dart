import 'package:flutter/material.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/Tabs/Home/HomeTab.dart';
import 'package:shop_n_goo/Tabs/Home/Home_Screen.dart';
import 'package:shop_n_goo/Tabs/Home/View_order_Summary.dart';
import 'package:shop_n_goo/data/models/order_item.dart';

class ThankU extends StatelessWidget {
  static const String routeName = "ThankU";
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // Get arguments passed from checkout
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final orderId = args?['orderId'] as String? ?? 'ORDER${DateTime.now().millisecondsSinceEpoch}';
    final orderDate = args?['orderDate'] as DateTime? ?? DateTime.now();
    final items = args?['items'] as List<dynamic>? ?? [];
    final totalAmount = args?['totalAmount'] as double? ?? 0.0;
    final discount = args?['discount'] as double? ?? 0.0;
    final paymentMethod = args?['paymentMethod'] as String? ?? 'Visa';
    final paymentDetails = args?['paymentDetails'] as String? ?? '**** 8600';

    return Scaffold(
      backgroundColor: AppTheme.Bg,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Thank You!",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGreen)),
            SizedBox(height: 60),
            Image.asset('assets/images/Thanku.png', width: width * 0.5),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {Navigator.pushReplacementNamed(context, HomeScreen.routeName);},
                child: Text("Back to Home"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.darkGreen,
                  side: BorderSide(color: AppTheme.darkGreen,),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}