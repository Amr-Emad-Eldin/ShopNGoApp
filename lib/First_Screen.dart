import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/UserInfo/SignIn.dart';
import 'package:shop_n_goo/UserInfo/signUp.dart';
import 'package:shop_n_goo/cubit/auth/auth_cubit.dart';

class FirstScreen extends StatelessWidget {
  static const String routeName = "/FirstScreen";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppTheme.splashBg,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: screenHeight * 0.07), // ~50 on 800px height

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Shop',
                      style: GoogleFonts.shrikhand(
                        color: AppTheme.lightGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.16, // ~64 on 480px width
                      )),
                  Text('N',
                      style: GoogleFonts.shrikhand(
                        color: AppTheme.darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.16,
                      )),
                  Text('Go',
                      style: GoogleFonts.shrikhand(
                        color: AppTheme.lightGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.16,
                      )),
                ],
              ),
              const Spacer(),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => signUp()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: AppTheme.darkGreen,
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  padding: EdgeInsets.all(screenHeight * 0.02),
                  child: Center(
                    child: Text(
                      "Create New Account",
                      style: GoogleFonts.schibstedGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => signIn()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.darkGreen,
                      width: 3,
                    ),
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  padding: EdgeInsets.all(screenHeight * 0.02),
                  child: Center(
                    child: Text(
                      "Already have an account",
                      style: GoogleFonts.schibstedGrotesk(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),

              Text(
                "Your journey to smart shopping starts here!",
                style: GoogleFonts.schibstedGrotesk(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.12),
            ],
          ),
          Positioned(
            top: screenHeight * 0.135,
            right: screenWidth * 0.16,
            child: Image.asset(
              'assets/images/Shopping Cart.png',
              width: screenWidth * 0.18,
            ),
          ),
        ],
      ),
    );
  }
}
