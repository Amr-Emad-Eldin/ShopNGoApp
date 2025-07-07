import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/Tabs/Home/Thank_u.dart';
import 'package:shop_n_goo/Tabs/Home/View_order_Summary.dart';
import 'package:shop_n_goo/cubit/scanner/scanner_cubit.dart';
import 'package:shop_n_goo/data/data_sources/auth_local_data_source.dart';
import 'package:shop_n_goo/data/models/order_item.dart';
import 'package:dio/dio.dart';
import 'package:shop_n_goo/ui_utils.dart';
import 'package:shop_n_goo/api_constants.dart';

class SummaryOrderPage extends StatefulWidget {
  static const String routeName = "Summary" ;
  @override
  State<SummaryOrderPage> createState() => _SummaryOrderPageState();
}

class _SummaryOrderPageState extends State<SummaryOrderPage> {
  List<CartItem> cartItems = [];
  double subtotal = 0.0;
  bool isLoading = true;
  String? errorMessage;
  String selectedPaymentMethod = 'card'; // 'card' or 'wallet'
  final ScannerCubit _scannerCubit = ScannerCubit();

  // Visa and phone management
  List<dynamic> visas = [];
  String? defaultVisaNumber;
  String? selectedVisaNumber;
  String? phoneNumber;
  final Dio _dio = Dio();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool rememberCard = false;
  bool askToSaveCard = false;
  bool isProcessing = false;
  bool makeDefault = false;
  String? promoCode;
  double discountAmount = 0.0;
  bool isPromoCodeValid = false;
  final TextEditingController promoCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCartData();
    _fetchVisasAndPhone();
  }

  @override
  void dispose() {
    _scannerCubit.close();
    cardNumberController.dispose();
    cvcController.dispose();
    expiryController.dispose();
    phoneController.dispose();
    promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchVisasAndPhone() async {
    try {
      String token = await _authLocalDataSource.getToken();
      // Fetch visas
      final visaResp = await _dio.get(
        ApiConstants.baseUrl + 'auth/visas',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      visas = visaResp.data['visas'] ?? [];
      print('DEBUG: Fetched ${visas.length} visas');
      
      if (visas.isNotEmpty) {
        // Find the default visa
        final defaultVisa = visas.firstWhere((v) => v['is_default'] == true, orElse: () => visas[0]);
        defaultVisaNumber = defaultVisa['visa_id']; // Always use visa_id, not masked number
        selectedVisaNumber = defaultVisaNumber; // Set the selected visa to default
        print('DEBUG: Default visa set to: $defaultVisaNumber');
        print('DEBUG: Selected visa set to: $selectedVisaNumber');
        
        // Print all visas for debugging
        for (int i = 0; i < visas.length; i++) {
          final visa = visas[i];
          print('DEBUG: Visa $i - ID: ${visa['visa_id']}, Type: ${visa['visa_id'].runtimeType}, Default: ${visa['is_default']}, Masked: ${visa['masked']}');
          print('DEBUG: Visa $i - Full visa data: $visa');
        }
      } else {
        defaultVisaNumber = null;
        selectedVisaNumber = null;
        print('DEBUG: No visas found');
      }
      // Fetch phone
      final phoneResp = await _dio.get(
        ApiConstants.baseUrl + 'auth/me',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      phoneNumber = phoneResp.data['user']?['phoneNo'] ?? phoneResp.data['phoneNo'];
      phoneController.text = phoneNumber ?? '';
      setState(() {});
    } catch (e) {
      print('DEBUG: Error fetching visas and phone: $e');
    }
  }

  Future<void> _loadCartData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final cartData = await _scannerCubit.getCart();
      
      if (cartData['session'] != null) {
        final session = cartData['session'];
        final items = session['items'] as List<dynamic>? ?? [];
        
        // Group items by name and calculate total quantity
        Map<String, CartItem> groupedItems = {};
        
        for (var item in items) {
          String name = item['name'] ?? 'Unknown Product';
          double price = (item['price'] ?? 0.0).toDouble();
          String imageUrl = item['image_url'] ?? 'assets/images/Molto.png';
          int quantity = item['quantity'] ?? 1;
          
          if (groupedItems.containsKey(name)) {
            CartItem existingItem = groupedItems[name]!;
            groupedItems[name] = CartItem(
              name: existingItem.name,
              price: existingItem.price,
              image: existingItem.image,
              quantity: existingItem.quantity + quantity,
            );
          } else {
            groupedItems[name] = CartItem(
              name: name,
              price: price,
              image: imageUrl,
              quantity: quantity,
            );
          }
        }
        
        setState(() {
          cartItems = groupedItems.values.toList();
          subtotal = (session['total_amount'] ?? 0.0).toDouble();
          isLoading = false;
        });
      } else {
        setState(() {
          cartItems = [];
          subtotal = 0.0;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _initiateCheckout() async {
    setState(() { isProcessing = true; });
    try {
      String token = await _authLocalDataSource.getToken();
      Map<String, dynamic> data = {};
      
      if (selectedPaymentMethod == 'card') {
        data['payment_method'] = 'pm_card_visa';
        
        // Scenario 1: User entered new card details
        if (cardNumberController.text.isNotEmpty && cvcController.text.isNotEmpty && expiryController.text.isNotEmpty) {
          print('DEBUG: Using new card details');
          data['card_number'] = cardNumberController.text;
          data['cvc'] = cvcController.text;
          data['expiry'] = expiryController.text;
          data['save_visa'] = rememberCard; // Send boolean value
          data['set_default'] = makeDefault; // Send boolean value
        }
        // Scenario 2: User selected a saved visa (either explicitly or default)
        else if (selectedVisaNumber != null && selectedVisaNumber!.isNotEmpty) {
          print('DEBUG: Using selected saved visa: $selectedVisaNumber');
          data['visa_id'] = selectedVisaNumber;
        }
        // Scenario 3: No card details and no visa selected, use default visa if available
        else if (defaultVisaNumber != null && defaultVisaNumber!.isNotEmpty) {
            print('DEBUG: Using default visa: $defaultVisaNumber');
            data['visa_id'] = defaultVisaNumber;
          }
        // Scenario 4: No card details at all - just send payment_method
        else {
          print('DEBUG: No card details provided, sending only payment_method');
          // Don't add any additional fields, just payment_method
        }
      } else {
        data['payment_method'] = 'mobile_wallet';
        data['phone_number'] = phoneController.text.isNotEmpty ? phoneController.text : phoneNumber;
        if (data['phone_number'] == null || data['phone_number'].toString().isEmpty) {
          UIUtils.showMessage('Please enter a valid phone number.');
          setState(() { isProcessing = false; });
          return;
        }
      }
      
      // Add promo code if valid
      if (isPromoCodeValid && promoCode != null) {
        data['promo_code'] = promoCode;
        print('DEBUG: Adding promo code: $promoCode');
      }
      
      print('DEBUG: Sending checkout data: $data');
      print('DEBUG: Data type: ${data.runtimeType}');
      print('DEBUG: Data keys: ${data.keys.toList()}');
      print('DEBUG: Card number: ${data['card_number'] ?? 'NOT_SET'}');
      print('DEBUG: CVC: ${data['cvc'] ?? 'NOT_SET'}');
      print('DEBUG: Expiry: ${data['expiry'] ?? 'NOT_SET'}');
      print('DEBUG: Save visa: ${data['save_visa'] ?? 'NOT_SET'} (type: ${data['save_visa']?.runtimeType})');
      print('DEBUG: Set default: ${data['set_default'] ?? 'NOT_SET'} (type: ${data['set_default']?.runtimeType})');
      print('DEBUG: Visa ID: ${data['visa_id'] ?? 'NOT_SET'}');
      print('DEBUG: rememberCard variable: $rememberCard (type: ${rememberCard.runtimeType})');
      print('DEBUG: makeDefault variable: $makeDefault (type: ${makeDefault.runtimeType})');
      
      final resp = await _dio.post(
        ApiConstants.baseUrl + 'cart/initiate-checkout',
        data: data,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (resp.statusCode == 200) {
        final paymentSessionId = resp.data['payment_session_id'];
        final paymentMethod = resp.data['payment_method'];
        await _showOtpDialog(paymentSessionId, paymentMethod);
      } else {
        print('DEBUG: Checkout failed with status: ${resp.statusCode}');
        print('DEBUG: Response data: ${resp.data}');
        UIUtils.showMessage(resp.data['error'] ?? 'Checkout failed');
      }
    } catch (e) {
      print('DEBUG: Checkout error: $e');
      if (e is DioException) {
        print('DEBUG: DioException response: ${e.response?.data}');
        print('DEBUG: DioException status: ${e.response?.statusCode}');
      }
      UIUtils.showMessage('Checkout failed: ${e.toString()}');
    } finally {
      setState(() { isProcessing = false; });
    }
  }

  Future<void> _showOtpDialog(String paymentSessionId, String paymentMethod) async {
    final otpController = TextEditingController();
    bool verifying = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter the OTP sent to your ${paymentMethod == 'pm_card_visa' ? 'email' : 'phone'}'),
              SizedBox(height: 8),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'OTP'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: verifying ? null : () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: verifying ? null : () async {
                setState(() { verifying = true; });
                try {
                  String token = await _authLocalDataSource.getToken();
                  final resp = await _dio.post(
                    ApiConstants.baseUrl + 'cart/verify-checkout',
                    data: {
                      'payment_session_id': paymentSessionId,
                      'otp': otpController.text,
                    },
                    options: Options(headers: {"Authorization": "Bearer $token"}),
                  );
                  if (resp.statusCode == 200) {
                    UIUtils.showMessage('Checkout complete!');
                    Navigator.pop(context); // Close dialog
                    
                    // Convert cart items to OrderItem format
                    List<OrderItem> orderItems = cartItems.map((item) => OrderItem(
                      name: item.name,
                      price: item.price,
                      quantity: item.quantity,
                      image: item.image,
                    )).toList();
                    
                    // Determine payment details based on what was used
                    String paymentMethodText = selectedPaymentMethod == 'card' ? 'Visa' : 'Mobile Wallet';
                    String paymentDetailsText = '';
                    
                    if (selectedPaymentMethod == 'card') {
                      if (cardNumberController.text.isNotEmpty) {
                        // New card was entered
                        paymentDetailsText = '**** ${cardNumberController.text.substring(cardNumberController.text.length - 4)}';
                      } else if (selectedVisaNumber != null) {
                        // Saved visa was selected
                        paymentDetailsText = '**** ${selectedVisaNumber!.substring(selectedVisaNumber!.length - 4)}';
                      } else if (defaultVisaNumber != null) {
                        // Default visa was used
                        // Find the visa in the list to get the masked number
                        final defaultVisa = visas.firstWhere((v) => v['visa_id'] == defaultVisaNumber, orElse: () => {});
                        paymentDetailsText = defaultVisa['masked'] ?? '**** 8600';
                      } else {
                        // Fallback
                        paymentDetailsText = '**** 8600';
                      }
                    } else {
                      // Mobile wallet
                      paymentDetailsText = phoneController.text.isNotEmpty ? phoneController.text : phoneNumber ?? '';
                    }
                    
                    Navigator.pushNamedAndRemoveUntil(
                      context, 
                      ThankU.routeName, 
                      (route) => false,
                      arguments: {
                        'orderId': 'ORDER${DateTime.now().millisecondsSinceEpoch}',
                        'orderDate': DateTime.now(),
                        'items': orderItems,
                        'totalAmount': subtotal - discountAmount,
                        'discount': discountAmount,
                        'paymentMethod': paymentMethodText,
                        'paymentDetails': paymentDetailsText,
                        'promoCode': promoCode,
                      },
                    );
                  } else {
                    UIUtils.showMessage(resp.data['error'] ?? 'Verification failed');
                  }
                } catch (e) {
                  UIUtils.showMessage('Verification failed');
                } finally {
                  setState(() { verifying = false; });
                }
              },
              child: verifying ? CircularProgressIndicator() : Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double discount = 0;
    double total = subtotal - discount;

    Widget buildSection(String title, Widget content) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: size.height * 0.012),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.schibstedGrotesk(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGreen,
                )),
            SizedBox(height: 10),
            content,
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.Bg,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.darkGreen),
            onPressed: () => Navigator.pop(context)),
        title: Text("Summary Order",
            style: GoogleFonts.schibstedGrotesk(
                fontSize: size.width * 0.055,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGreen)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: Column(
          children: [
            // Product Details
            buildSection(
              "Product Details",
              Column(
                children: [
                  ...cartItems.map((item) {
                    return Row(
                      children: [
                        // Handle both network images and local assets
                        item.image.startsWith('http') || item.image.startsWith('https')
                            ? Image.network(
                                item.image,
                                width: size.width * 0.15,
                                height: size.width * 0.15,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/Molto.png',
                                    width: size.width * 0.15,
                                    height: size.width * 0.15,
                                    fit: BoxFit.contain,
                                  );
                                },
                              )
                            : Image.asset(
                                item.image,
                                width: size.width * 0.15,
                                height: size.width * 0.15,
                                fit: BoxFit.contain,
                              ),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('${item.quantity} x ${item.price.toStringAsFixed(2)}LE'),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                  Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Total Orders: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("${subtotal.toStringAsFixed(2)}LE"),
                    ],
                  )
                ],
              ),
            ),

            // Payment Method with Card Input
            buildSection(
              "Payment Method",
              Column(
                children: [
                  // Payment Method Selection
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Bank Card'),
                          value: 'card',
                          groupValue: selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Wallet'),
                          value: 'wallet',
                          groupValue: selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Card Details (only show if card is selected)
                  if (selectedPaymentMethod == 'card') ...[
                    // Show saved visas if any exist
                    if (visas.isNotEmpty) ...[
                      Text(
                        'Select a saved card:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.darkGreen,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Add "None" option to unselect all
                      Card(
                        color: selectedVisaNumber == null ? Colors.blue[50] : Colors.white,
                        child: ListTile(
                          leading: Icon(Icons.add_card, color: AppTheme.darkGreen),
                          title: Text('Enter new card'),
                          subtitle: Text('Add a new card instead'),
                          trailing: Radio<String?>(
                            key: ValueKey('radio_null'),
                            value: null,
                            groupValue: selectedVisaNumber,
                            onChanged: (val) {
                              print('DEBUG: Radio changed to None - Old: $selectedVisaNumber, New: $val');
                              setState(() {
                                selectedVisaNumber = val;
                                // Clear new card fields when selecting "None"
                                cardNumberController.clear();
                                cvcController.clear();
                                expiryController.clear();
                                rememberCard = false;
                                makeDefault = false;
                              });
                              print('DEBUG: After setState - selectedVisaNumber: $selectedVisaNumber');
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: visas.length,
                        itemBuilder: (context, index) {
                          final visa = visas[index];
                          final isDefault = visa['is_default'] == true;
                          final visaId = visa['visa_id'] ?? 'unknown_$index';
                          final isSelected = selectedVisaNumber == visaId;
                          print('DEBUG: Visa $index - ID: $visaId, Selected: $isSelected, Default: $isDefault');
                          print('DEBUG: Current selectedVisaNumber: $selectedVisaNumber');
                          return Card(
                            key: ValueKey('visa_$visaId'),
                            color: isSelected ? Colors.green[50] : (isDefault ? Colors.blue[50] : Colors.white),
                            child: ListTile(
                              leading: Icon(Icons.credit_card, color: AppTheme.darkGreen),
                              title: Text(visa['masked'] ?? visa['card_number'] ?? '****'),
                              subtitle: isDefault ? Text('Default', style: TextStyle(color: Colors.green)) : null,
                              trailing: Radio<String>(
                                key: ValueKey('radio_$visaId'),
                                value: visaId,
                                groupValue: selectedVisaNumber,
                                onChanged: (val) {
                                  print('DEBUG: Radio changed for visa $visaId');
                                  print('DEBUG: Radio changed - Old: $selectedVisaNumber, New: $val');
                                  print('DEBUG: Radio changed - Old type: ${selectedVisaNumber.runtimeType}, New type: ${val.runtimeType}');
                                  setState(() {
                                    selectedVisaNumber = val;
                                    // Clear new card fields when selecting a saved visa
                                    cardNumberController.clear();
                                    cvcController.clear();
                                    expiryController.clear();
                                    rememberCard = false;
                                    makeDefault = false;
                                  });
                                  print('DEBUG: After setState - selectedVisaNumber: $selectedVisaNumber');
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 8),
                    ],
                    
                    // Show message if no saved cards
                    if (visas.isEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No saved cards found. Please enter your card details below.',
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    
                    // Enter new card section
                    Text(
                      visas.isEmpty ? 'Enter Card Details:' : 'Or enter a new card:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Card Number",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        print('DEBUG: Card number changed to: $val');
                        setState(() {
                          selectedVisaNumber = null; // Unselect saved visa when typing new card
                          // Reset checkbox values when entering new card
                          rememberCard = false;
                          makeDefault = false;
                        });
                        print('DEBUG: After card number change - selectedVisaNumber: $selectedVisaNumber');
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: expiryController,
                            decoration: InputDecoration(
                              labelText: "Expiry Date (MM/YY)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: cvcController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "CVV",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Only show these options if user is entering a new card
                    if (cardNumberController.text.isNotEmpty) ...[
                    Row(
                      children: [
                        Checkbox(
                          value: rememberCard,
                          onChanged: (value) {
                            setState(() {
                                rememberCard = value ?? false;
                                // If unchecking "Remember Card", also uncheck "Make Default"
                                if (!(value ?? false)) {
                                  makeDefault = false;
                                }
                            });
                          },
                        ),
                        Text("Remember this card"),
                      ],
                    ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Checkbox(
                            value: makeDefault,
                            onChanged: rememberCard ? (value) {
                              setState(() {
                                makeDefault = value ?? false;
                              });
                            } : null, // Disable if "Remember Card" is not checked
                          ),
                          Text(
                            "Make this my default card",
                            style: TextStyle(
                              color: rememberCard ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ],
                  
                  // Mobile Wallet Details (only show if wallet is selected)
                  if (selectedPaymentMethod == 'wallet') ...[
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Promo Code Section
            buildSection(
              "Promo Code",
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: promoCodeController,
                          decoration: InputDecoration(
                            labelText: "Enter Promo Code",
                            border: OutlineInputBorder(),
                            suffixIcon: isPromoCodeValid
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : null,
                          ),
                          enabled: !isPromoCodeValid,
                        ),
                      ),
                      SizedBox(width: 8),
                      if (!isPromoCodeValid)
                        ElevatedButton(
                          onPressed: _validatePromoCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.darkGreen,
                          ),
                          child: Text("Apply", style: TextStyle(color: Colors.white)),
                        )
                      else
                        ElevatedButton(
                          onPressed: _clearPromoCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text("Remove", style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                  if (isPromoCodeValid) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.green[800]),
                          SizedBox(width: 8),
                          Text(
                            "Promo code applied: $promoCode",
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Order Details
            buildSection(
              "Order Details",
              Column(
                children: [
                  rowSummary("Subtotal", subtotal),
                  if (isPromoCodeValid) ...[
                    rowSummary("Discount", -discountAmount, isBold: false),
                  Divider(thickness: 1),
                  ],
                  rowSummary("Total Payment", subtotal - discountAmount, isBold: true),
                ],
              ),
            ),

            // Pay Now Button
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _initiateCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isProcessing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Pay Now",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget rowSummary(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("${value.toStringAsFixed(2)}LE",
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Future<void> _loadVisas() async {
    try {
      String token = await _authLocalDataSource.getToken();
      final response = await _dio.get(
        ApiConstants.baseUrl + 'auth/visas',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      if (response.statusCode == 200) {
        setState(() {
          visas = List<Map<String, dynamic>>.from(response.data['visas']);
          // Set default visa if exists
          final defaultVisa = visas.firstWhere((v) => v['is_default'] == true, orElse: () => {});
          if (defaultVisa.isNotEmpty) {
            defaultVisaNumber = defaultVisa['visa_id'];
            selectedVisaNumber = defaultVisaNumber;
          }
        });
      }
    } catch (e) {
      print('Error loading visas: $e');
    }
  }

  Future<void> _validatePromoCode() async {
    if (promoCodeController.text.isEmpty) {
      UIUtils.showMessage('Please enter a promo code');
      return;
    }

    try {
      String token = await _authLocalDataSource.getToken();
      final response = await _dio.post(
        ApiConstants.baseUrl + 'auth/validate-promo-code',
        data: {'code': promoCodeController.text.toUpperCase()},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          promoCode = data['promo_code'];
          discountAmount = (subtotal * data['discount_percentage'] / 100);
          isPromoCodeValid = true;
        });
        UIUtils.showMessage('Promo code applied! ${data['discount_percentage']}% discount');
      }
    } catch (e) {
      setState(() {
        promoCode = null;
        discountAmount = 0.0;
        isPromoCodeValid = false;
      });
      UIUtils.showMessage('Invalid promo code');
    }
  }

  void _clearPromoCode() {
    setState(() {
      promoCode = null;
      discountAmount = 0.0;
      isPromoCodeValid = false;
      promoCodeController.clear();
    });
  }
}

class CartItem {
  final String name;
  final double price;
  final String image;
  final int quantity;

  CartItem({required this.name, required this.price, required this.image, required this.quantity});
}
