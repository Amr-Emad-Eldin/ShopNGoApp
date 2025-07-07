import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../AppTheme.dart';

class PersonalOffers extends StatelessWidget {
  static const String routeName = "Offers";

  const PersonalOffers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.Bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Offers",
          style: GoogleFonts.schibstedGrotesk(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'No Offers',
          style: GoogleFonts.schibstedGrotesk(
            fontSize: 30,
            color: AppTheme.darkGreen,
          ),
        ),
      ),
    );
  }
}
