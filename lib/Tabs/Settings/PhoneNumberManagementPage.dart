import 'package:flutter/material.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/ui_utils.dart';
import 'package:shop_n_goo/data/data_sources/auth_local_data_source.dart';
import 'package:shop_n_goo/data/data_sources/shopping_data_source.dart';
import 'package:dio/dio.dart';
import 'package:shop_n_goo/api_constants.dart';

class PhoneNumberManagementPage extends StatefulWidget {
  @override
  _PhoneNumberManagementPageState createState() => _PhoneNumberManagementPageState();
}

class _PhoneNumberManagementPageState extends State<PhoneNumberManagementPage> {
  String? phoneNumber;
  bool isLoading = true;
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final Dio _dio = Dio();
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
  }

  Future<void> _fetchPhoneNumber() async {
    setState(() { isLoading = true; });
    try {
      String token = await _authLocalDataSource.getToken();
      final response = await _dio.get(
        ApiConstants.baseUrl + 'auth/me',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      setState(() {
        phoneNumber = response.data['user']?['phoneNo'] ?? response.data['phoneNo'];
        _phoneController.text = phoneNumber ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
      UIUtils.showMessage('Failed to load phone number');
    }
  }

  Future<void> _updatePhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { isLoading = true; });
    try {
      String token = await _authLocalDataSource.getToken();
      final response = await _dio.put(
        ApiConstants.baseUrl + 'auth/update-phone',
        data: {"phone_number": _phoneController.text},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      
      if (response.statusCode == 200) {
        UIUtils.showMessage('Phone number updated successfully');
        await _fetchPhoneNumber();
      } else {
        UIUtils.showMessage('Failed to update phone number: ${response.data['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error updating phone: $e');
      UIUtils.showMessage('Failed to update phone number: ${e.toString()}');
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _removePhoneNumber() async {
    setState(() { isLoading = true; });
    try {
      String token = await _authLocalDataSource.getToken();
      print('DEBUG: Removing phone number by setting it to empty...');
      print('DEBUG: URL: ${ApiConstants.baseUrl}auth/update-phone');
      print('DEBUG: Method: PUT');
      
      final response = await _dio.put(
        ApiConstants.baseUrl + 'auth/update-phone',
        data: {"phone_number": ""},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        UIUtils.showMessage('Phone number removed successfully');
        await _fetchPhoneNumber();
      } else {
        UIUtils.showMessage('Failed to remove phone number: ${response.data['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error removing phone: $e');
      UIUtils.showMessage('Failed to remove phone number: ${e.toString()}');
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Phone Number', style: TextStyle(color: AppTheme.darkGreen)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppTheme.darkGreen),
        elevation: 0,
      ),
      backgroundColor: AppTheme.Bg,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter phone number';
                        // Egyptian phone number validation (supports various formats)
                        if (!RegExp(r'^(\+20|20|0)?1[0-2,5][0-9]{8}$').hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
                          return 'Please enter a valid Egyptian phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _updatePhoneNumber,
                            child: Text('Update'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.darkGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        if (phoneNumber != null && phoneNumber!.isNotEmpty)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _removePhoneNumber,
                              child: Text('Remove'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red),
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