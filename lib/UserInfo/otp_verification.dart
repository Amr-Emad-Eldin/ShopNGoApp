import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/UserInfo/SignIn.dart';
import 'package:shop_n_goo/ui_utils.dart';
import 'package:dio/dio.dart';
import 'package:shop_n_goo/api_constants.dart';

class OtpVerificationScreen extends StatefulWidget {
  static const String routeName = 'otpVerification';
  final String email;

  const OtpVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  bool isLoading = false;
  bool canResend = true;
  int resendCooldown = 30;

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    // Check if all OTP digits are entered
    if (index == 5 && value.isNotEmpty) {
      // Don't auto-verify, let user press the button
      // _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    String otp = otpControllers.map((controller) => controller.text).join();
    
    print("=== OTP VERIFICATION DEBUG ===");
    print("OTP: $otp");
    print("Email: ${widget.email}");
    print("API URL: ${ApiConstants.baseUrl}auth/verify-registration-otp");
    
    if (otp.length != 6) {
      UIUtils.showMessage("Please enter the complete 6-digit OTP");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print("Making API call...");
      final response = await _dio.post(
        "auth/verify-registration-otp",
        data: {
          "email": widget.email,
          "otp": otp,
        },
      );

      print("=== RESPONSE RECEIVED ===");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");
      print("Response Headers: ${response.headers}");

      // Check for 201 status code (successful verification)
      if (response.statusCode == 201) {
        print("SUCCESS: Verification successful!");
        UIUtils.showMessage("Email verified successfully! You can now sign in.");
        
        // Wait a bit for the message to show
        await Future.delayed(Duration(milliseconds: 1500));
        
        print("Navigating to sign in page...");
        // Use the same navigation pattern as other pages
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => signIn()),
          (route) => false,
        );
        print("Navigation completed!");
      } else {
        print("ERROR: Unexpected status code: ${response.statusCode}");
        UIUtils.showMessage("Verification failed. Please try again.");
      }
    } catch (e) {
      print("=== ERROR OCCURRED ===");
      print("Error type: ${e.runtimeType}");
      print("Error message: $e");
      
      String errorMessage = "Verification failed";
      if (e is DioException) {
        print("DioException details:");
        print("  Status code: ${e.response?.statusCode}");
        print("  Response data: ${e.response?.data}");
        print("  Error type: ${e.type}");
        
        if (e.response?.statusCode == 400) {
          errorMessage = e.response?.data['error'] ?? "Invalid OTP";
        } else if (e.response?.statusCode == 404) {
          errorMessage = e.response?.data['error'] ?? "No pending registration found";
        } else {
          errorMessage = e.response?.data['error'] ?? errorMessage;
        }
      }
      
      print("Showing error message: $errorMessage");
      UIUtils.showMessage(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
      print("=== OTP VERIFICATION COMPLETED ===");
    }
  }

  Future<void> _resendOtp() async {
    if (!canResend) return;
    setState(() {
      isLoading = true;
      canResend = false;
    });
    try {
      final response = await _dio.post(
        "auth/resend-registration-otp",
        data: {
          "email": widget.email,
        },
      );
      if (response.statusCode == 200) {
        UIUtils.showMessage("OTP resent successfully! Check your email.");
        for (var controller in otpControllers) {
          controller.clear();
        }
        focusNodes[0].requestFocus();
        // Start cooldown
        for (int i = resendCooldown; i > 0; i--) {
          await Future.delayed(Duration(seconds: 1));
          if (!mounted) return;
          setState(() {});
        }
      }
    } catch (e) {
      UIUtils.showMessage("Failed to resend OTP");
    } finally {
      setState(() {
        isLoading = false;
        canResend = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.Bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Verify Email",
          style: GoogleFonts.schibstedGrotesk(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.05),
            
            // Email Icon
            Icon(
              Icons.email_outlined,
              size: screenWidth * 0.3,
              color: AppTheme.darkGreen,
            ),
            
            SizedBox(height: screenHeight * 0.03),
            
            // Title
            Text(
              "Verify Your Email",
              style: GoogleFonts.schibstedGrotesk(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGreen,
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // Description
            Text(
              "We've sent a 6-digit verification code to",
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: screenHeight * 0.01),
            
            Text(
              widget.email,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGreen,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: screenHeight * 0.04),
            
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.darkGreen,
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) => _onOtpChanged(value, index),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.04),
            
            // Verify Button
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.06,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Verify Email",
                        style: GoogleFonts.schibstedGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.03),
            
            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
                GestureDetector(
                  onTap: (isLoading || !canResend) ? null : _resendOtp,
                  child: Text(
                    canResend ? "Resend" : "Wait...",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: canResend ? AppTheme.darkGreen : Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }
} 