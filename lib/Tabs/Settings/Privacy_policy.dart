import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_n_goo/AppTheme.dart';

class PrivacyPolicy extends StatelessWidget {
  static const String routeName = "PrivacyPolicy";
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05;
    final titleFont = size.width * 0.045;
    final bodyFont = size.width * 0.037;

    return Scaffold(
      backgroundColor: AppTheme.Bg,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          "Privacy Policy",
          style: GoogleFonts.schibstedGrotesk(
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: size.height * 0.02),
        child: ListView(
          children: [
            SizedBox(height: 5),
            Text(
              "This policy explains how we protect products, customer data, and ensure a safe shopping experience using RFID.",
              style: TextStyle(fontSize: bodyFont),
            ),
            SizedBox(height: 20),
            Text(
              "Important Alert 🔔",
              style: GoogleFonts.schibstedGrotesk(
                fontSize: titleFont,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Text("⚠️ DO NOT take any product without scanning!",
                style: TextStyle(fontSize: bodyFont)),
            Text("• Every item is tracked using RFID.",
                style: TextStyle(fontSize: bodyFont)),
            Text("• Unscanned items trigger a security alert.",
                style: TextStyle(fontSize: bodyFont)),
            Text("• Unauthorized removal alerts the store.",
                style: TextStyle(fontSize: bodyFont)),
            Text("• This system prevents theft and ensures accurate billing.",
                style: TextStyle(fontSize: bodyFont)),
            SizedBox(height: 20),
            Text(
              "Security of Products",
              style: GoogleFonts.schibstedGrotesk(
                fontSize: titleFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("✓ RFID-tracked from shelves to checkout.",
                style: TextStyle(fontSize: bodyFont)),
            Text("✓ Alerts if item is removed without scanning.",
                style: TextStyle(fontSize: bodyFont)),
            Text("✓ Security gates detect unpaid items.",
                style: TextStyle(fontSize: bodyFont)),
            Text("✓ Real-time tracking prevents shortages.",
                style: TextStyle(fontSize: bodyFont)),
            SizedBox(height: 20),
            Text(
              "How We Protect Customer Data",
              style: GoogleFonts.schibstedGrotesk(
                fontSize: titleFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("🔒 Encrypted transactions for security.",
                style: TextStyle(fontSize: bodyFont)),
            Text("🔐 Authorized personnel access only.",
                style: TextStyle(fontSize: bodyFont)),
            Text("📋 RFID tags store product data only.",
                style: TextStyle(fontSize: bodyFont)),
          ],
        ),
      ),
    );
  }
}
