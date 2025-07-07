import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/UserInfo/LocationScreen.dart';
import 'package:shop_n_goo/UserInfo/signUp.dart';
import 'package:shop_n_goo/cubit/auth/auth_cubit.dart';
import 'package:shop_n_goo/cubit/auth/auth_states.dart';
import 'package:shop_n_goo/data/models/auth/request/login_request.dart';
import 'package:shop_n_goo/ui_utils.dart';

class signIn extends StatefulWidget {
  static const String routeName = 'signIn';

  @override
  State<signIn> createState() => _SignInState();
}

class _SignInState extends State<signIn> {
  final _formKey = GlobalKey<FormState>();

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GoogleMapScreen()),
      );
    }
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Sign In",
              style: GoogleFonts.schibstedGrotesk(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGreen,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.person, color: AppTheme.darkGreen, size: 28),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email or Phone Number',
                style: GoogleFonts.schibstedGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGreen,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.darkGreen, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.darkGreen, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  hintText: 'Enter your email or phone number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email or phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Password',
                style: GoogleFonts.schibstedGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGreen,
                ),
              ),

              const SizedBox(height: 4),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.darkGreen, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.darkGreen, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  hintText: 'Enter your password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Sign In Button
              BlocListener<AuthCubit, AuthStates>(
                listener: (context, state) {
                  if (state is AuthLoadingState) {
                    UIUtils.showLoading(context);
                  } else if (state is AuthErrorState) {
                    UIUtils.hideLoading(context);
                    UIUtils.showMessage(state.message);
                  } else if (state is AuthSuccessState) {
                    UIUtils.hideLoading(context);
                    _signIn();
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    context.read<AuthCubit>().login(LoginRequest(
                        emailController.text, passwordController.text));
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.darkGreen,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: Text(
                        "Sign In",
                        style: GoogleFonts.schibstedGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Sign Up Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => signUp()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppTheme.darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
