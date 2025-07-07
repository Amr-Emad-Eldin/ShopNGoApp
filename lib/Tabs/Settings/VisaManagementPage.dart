import 'package:flutter/material.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/ui_utils.dart';
import 'package:shop_n_goo/data/data_sources/auth_local_data_source.dart';
import 'package:shop_n_goo/data/data_sources/shopping_data_source.dart';
import 'package:dio/dio.dart';
import 'package:shop_n_goo/api_constants.dart';

class VisaManagementPage extends StatefulWidget {
  @override
  _VisaManagementPageState createState() => _VisaManagementPageState();
}

class _VisaManagementPageState extends State<VisaManagementPage> {
  List<dynamic> visas = [];
  bool isLoading = true;
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    print('DEBUG: VisaManagementPage initState called');
    _fetchVisas();
  }

  Future<void> _fetchVisas() async {
    print('DEBUG: _fetchVisas called');
    setState(() { isLoading = true; });
    try {
      String token = await _authLocalDataSource.getToken();
      print('DEBUG: Token obtained, making API call to get visas');
      final response = await _dio.get(
        ApiConstants.baseUrl + 'auth/visas',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      print('DEBUG: Visas API response status: ${response.statusCode}');
      print('DEBUG: Visas API response data: ${response.data}');
      setState(() {
        visas = response.data['visas'] ?? [];
        isLoading = false;
      });
      print('DEBUG: Visas loaded: ${visas.length}');
      // Debug each visa structure
      for (int i = 0; i < visas.length; i++) {
        print('DEBUG: Visa $i structure: ${visas[i]}');
      }
    } catch (e) {
      print('DEBUG: Error fetching visas: $e');
      setState(() { isLoading = false; });
      UIUtils.showMessage('Failed to load visas');
    }
  }

  Future<void> _showRemoveConfirmation(String visaId) async {
    print('DEBUG: _showRemoveConfirmation called with visaId: $visaId');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Visa'),
        content: Text('Are you sure you want to remove this visa card? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    print('DEBUG: Confirmation result: $confirmed');
    if (confirmed == true) {
      print('DEBUG: Calling _removeVisa');
      await _removeVisa(visaId);
    }
  }

  Future<void> _removeVisa(String visaId) async {
    setState(() { isLoading = true; });
    try {
      String token = await _authLocalDataSource.getToken();
      final response = await _dio.post(
        ApiConstants.baseUrl + 'auth/remove-visa',
        data: {"visa_id": visaId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      
      if (response.statusCode == 200) {
        UIUtils.showMessage('Visa removed successfully');
        await _fetchVisas();
      } else {
        UIUtils.showMessage('Failed to remove visa: ${response.data['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error removing visa: $e');
      UIUtils.showMessage('Failed to remove visa: ${e.toString()}');
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _setDefaultVisa(String visaId) async {
    print('DEBUG: _setDefaultVisa called with visaId: $visaId');
    setState(() { isLoading = true; });
    try {
      String token = await _authLocalDataSource.getToken();
      print('DEBUG: Token obtained, making API call to set-default-visa');
      final response = await _dio.post(
        ApiConstants.baseUrl + 'auth/set-default-visa',
        data: {"visa_id": visaId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      
      print('DEBUG: API response status: ${response.statusCode}');
      print('DEBUG: API response data: ${response.data}');
      
      if (response.statusCode == 200) {
        UIUtils.showMessage('Default Visa set successfully');
        await _fetchVisas();
      } else {
        UIUtils.showMessage('Failed to set default visa: ${response.data['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error setting default visa: $e');
      UIUtils.showMessage('Failed to set default visa: ${e.toString()}');
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _addVisaDialog() async {
    final cardNumberController = TextEditingController();
    final cvcController = TextEditingController();
    final expiryController = TextEditingController();
    bool setDefault = false;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Visa Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cvcController,
                      decoration: InputDecoration(
                        labelText: 'CVC',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: setDefault ? Colors.amber[50] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: setDefault ? Colors.amber : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        setDefault ? Icons.star : Icons.star_border,
                        color: setDefault ? Colors.amber : Colors.grey[600],
                        size: 28,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          setDefault = !setDefault;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        setDefault ? 'Set as default card' : 'Set as default card',
                        style: TextStyle(
                          color: setDefault ? Colors.amber[800] : Colors.grey[600],
                          fontWeight: setDefault ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  String token = await _authLocalDataSource.getToken();
                  await _dio.post(
                    ApiConstants.baseUrl + 'auth/save-visa',
                    data: {
                      "card_number": cardNumberController.text,
                      "cvc": cvcController.text,
                      "expiry": expiryController.text,
                      "set_default": setDefault,
                    },
                    options: Options(headers: {"Authorization": "Bearer $token"}),
                  );
                  UIUtils.showMessage('Visa added');
                  Navigator.pop(context);
                  _fetchVisas();
                } catch (e) {
                  UIUtils.showMessage('Failed to add visa');
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Visas', style: TextStyle(color: AppTheme.darkGreen)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppTheme.darkGreen),
        elevation: 0,
      ),
      backgroundColor: AppTheme.Bg,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: visas.length,
                    itemBuilder: (context, index) {
                      final visa = visas[index];
                      print('DEBUG: Visa data at index $index: $visa');
                      final isDefault = visa['is_default'] == true;
                      // Use visa_id as identifier, fallback to masked card number if ID not available
                      final visaId = visa['visa_id'] ?? visa['masked'] ?? 'unknown';
                      final cardDisplay = visa['masked'] ?? '****';
                      print('DEBUG: isDefault: $isDefault, visaId: $visaId');
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        elevation: isDefault ? 4 : 2,
                        color: isDefault ? Colors.amber[50] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDefault ? Colors.amber : Colors.grey[300]!,
                            width: isDefault ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDefault ? Colors.amber[100] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.credit_card,
                              color: isDefault ? Colors.amber[800] : AppTheme.darkGreen,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            cardDisplay,
                            style: TextStyle(
                              fontWeight: isDefault ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: isDefault 
                            ? Text(
                                'Default Card',
                                style: TextStyle(
                                  color: Colors.amber[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Star Button
                              Container(
                                decoration: BoxDecoration(
                                  color: isDefault ? Colors.amber[100] : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      print('DEBUG: Star button pressed for visaId: $visaId');
                                      print('DEBUG: isLoading: $isLoading');
                                      if (!isLoading) {
                                        _setDefaultVisa(visaId);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        isDefault ? Icons.star : Icons.star_border,
                                        color: isDefault ? Colors.amber[800] : Colors.grey[600],
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Trash Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      print('DEBUG: Trash button pressed for visaId: $visaId');
                                      print('DEBUG: isLoading: $isLoading');
                                      if (!isLoading) {
                                        _showRemoveConfirmation(visaId);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red[600],
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Add Visa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _addVisaDialog,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 