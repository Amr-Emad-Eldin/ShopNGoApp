import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_n_goo/Tabs/Settings/ProfileTab.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/data/data_sources/auth_local_data_source.dart';
import 'package:shop_n_goo/data/data_sources/auth_data_source.dart';
import 'package:shop_n_goo/data/data_sources/shopping_data_source.dart';
import 'package:shop_n_goo/data/models/auth/request/login_request.dart';

class EditProfile extends StatefulWidget {
  static const String routeName = 'EditProfile';

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? currentFirstName;
  String? currentLastName;
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final AuthDataSource _authDataSource = AuthDataSource();
  final ShoppingDataSource _shoppingDataSource = ShoppingDataSource();
  
  bool _isLoading = false;
  String _selectedOption = 'name'; // 'name' or 'password'
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      final fName = await _authLocalDataSource.getFirstName();
      final lName = await _authLocalDataSource.getLastName();
      setState(() {
        currentFirstName = fName;
        currentLastName = lName;
        _firstNameController.text = fName ?? '';
        _lastNameController.text = lName ?? '';
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the user's token
      final token = await _authLocalDataSource.getToken();
      
      if (_selectedOption == 'name') {
        // Update first name via API
        await _shoppingDataSource.updateFirstName(
          _firstNameController.text.trim(),
          _oldPasswordController.text,
          token,
        );
        
        // Update last name via API (only if it's not empty)
        if (_lastNameController.text.trim().isNotEmpty) {
          await _shoppingDataSource.updateLastName(
            _lastNameController.text.trim(),
            _oldPasswordController.text,
            token,
          );
        }
        
        // Fetch updated user profile from backend
        try {
          final response = await _shoppingDataSource.getUserProfile(token);
          
          // Handle nested user object structure
          final userData = response['user'] ?? response;
          
          await _authLocalDataSource.saveUserData(
            userData['firstName'] ?? _firstNameController.text.trim(),
            userData['lastName'] ?? _lastNameController.text.trim(),
          );
        } catch (e) {
          print('Failed to fetch updated profile: $e');
          // Fallback to form data
          await _authLocalDataSource.saveUserData(
            _firstNameController.text.trim(),
            _lastNameController.text.trim(),
          );
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Name updated successfully!'),
            backgroundColor: AppTheme.darkGreen,
          ),
        );
      } else {
        // Update password via API
        await _shoppingDataSource.updatePassword(
          _oldPasswordController.text,
          _newPasswordController.text,
          token,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: AppTheme.darkGreen,
          ),
        );
      }
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FormFieldValidator<String> validator,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.schibstedGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.darkGreen, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.darkGreen, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            suffixIcon: isPassword && onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: AppTheme.darkGreen,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
          ),
          validator: validator,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.schibstedGrotesk(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Option Selection
              Text(
                'What would you like to edit?',
                style: GoogleFonts.schibstedGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGreen,
                ),
              ),
              SizedBox(height: 16),
              
              // Name Option
              RadioListTile<String>(
                title: Text(
                  'Edit Name',
                  style: GoogleFonts.schibstedGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: 'name',
                groupValue: _selectedOption,
                activeColor: AppTheme.darkGreen,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value!;
                  });
                },
              ),
              
              // Password Option
              RadioListTile<String>(
                title: Text(
                  'Change Password',
                  style: GoogleFonts.schibstedGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: 'password',
                groupValue: _selectedOption,
                activeColor: AppTheme.darkGreen,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value!;
                  });
                },
              ),
              
              SizedBox(height: 24),
              
              // Old Password (required for both options)
              _buildTextField(
                label: 'Old Password',
                controller: _oldPasswordController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your old password' : null,
                isPassword: true,
                obscureText: _obscureOldPassword,
                onToggleObscure: () {
                  setState(() {
                    _obscureOldPassword = !_obscureOldPassword;
                  });
                },
              ),
              
              // Conditional fields based on selection
              if (_selectedOption == 'name') ...[
                _buildTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your first name' : null,
                ),
                _buildTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  validator: (value) => null,
                ),
              ] else ...[
                _buildTextField(
                  label: 'New Password',
                  controller: _newPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  isPassword: true,
                  obscureText: _obscureNewPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                _buildTextField(
                  label: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onToggleObscure: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ],
              
              SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? CircularProgressIndicator(color: AppTheme.white)
                      : Text(
                          "Update Profile",
                          style: GoogleFonts.schibstedGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: AppTheme.white,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
