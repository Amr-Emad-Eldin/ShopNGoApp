import 'package:flutter/material.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUs extends StatelessWidget {
  static const String routeName = "AboutUs";
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05;
    final titleFont = size.width * 0.045;
    final bodyFont = size.width * 0.037;

    return Scaffold(
      backgroundColor: AppTheme.Bg,
      appBar: AppBar(
        title: Text(
          "About Us",
          style: GoogleFonts.schibstedGrotesk(
            fontSize: size.width * 0.07, // Responsive title font size
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
        child: ListView(
          children: [
            Text("• Who We Are",
                style: GoogleFonts.schibstedGrotesk(
                    fontSize: titleFont, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              "We are a team of passionate innovators dedicated to transforming the shopping experience through smart technology.",
              style: TextStyle(fontSize: bodyFont),
            ),
            const SizedBox(height: 20),
            Text("• Our Vision",
                style: GoogleFonts.schibstedGrotesk(
                    fontSize: titleFont, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              "To revolutionize the retail industry by creating a seamless and automated shopping experience, eliminating long checkout times, and improving inventory management.",
              style: TextStyle(fontSize: bodyFont),
            ),
            const SizedBox(height: 20),
            Text("How It Works",
                style: GoogleFonts.schibstedGrotesk(
                    fontSize: titleFont,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            const SizedBox(height: 5),
            Text("✓ Customers can pick up items and walk out without checkout delays.",
                style: TextStyle(fontSize: bodyFont)),
            Text("✓ Store owners get real-time inventory tracking.",
                style: TextStyle(fontSize: bodyFont)),
            Text("✓ Employees can efficiently manage stock.",
                style: TextStyle(fontSize: bodyFont)),
            const SizedBox(height: 20),
            Text("Contact Us",
                style: GoogleFonts.schibstedGrotesk(
                    fontSize: titleFont, fontWeight: FontWeight.bold)),
            Text("📧 Email: shopngo@gmail.com", style: TextStyle(fontSize: bodyFont)),
            Text("📍 Location: Cairo University", style: TextStyle(fontSize: bodyFont)),
            Text("📞 Phone: 0112324455", style: TextStyle(fontSize: bodyFont)),
          ],
        ),
      ),
    );
  }
}
