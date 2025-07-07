import 'package:flutter/material.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/Tabs/Home/Cart_Page.dart';

import 'package:shop_n_goo/Tabs/Scanner/ScannerTab.dart';
import 'package:shop_n_goo/data/data_sources/auth_local_data_source.dart';
import 'package:shop_n_goo/cubit/scanner/scanner_cubit.dart';
import 'package:shop_n_goo/ui_utils.dart';

class HomeTab extends StatefulWidget {
  static const String routeName = "homeTab";
  
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? userName;
  int cartItemCount = 0;
  bool hasActiveSession = false;
  final ScannerCubit _scannerCubit = ScannerCubit();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCartData();
  }

  @override
  void dispose() {
    _scannerCubit.close();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final name = await AuthLocalDataSource().getUserName();
    setState(() {
      userName = name;
    });
  }

  Future<void> _loadCartData() async {
    try {
      print("Loading cart data...");
      
      // First check if user has an active session
      bool hasSession = await _scannerCubit.hasActiveSession();
      print("Has active session: $hasSession");
      
      if (hasSession) {
        // If user has active session, get cart data
        final cartData = await _scannerCubit.getCart();
        print("Cart data received: $cartData");
        
        if (cartData['session'] != null) {
          final session = cartData['session'];
          final items = session['items'] as List<dynamic>? ?? [];
          
          print("Session found: ${session['is_active']}, Items: ${items.length}");
          
          setState(() {
            cartItemCount = items.length;
            hasActiveSession = true;
          });
        } else {
          print("No session found in cart data");
          setState(() {
            cartItemCount = 0;
            hasActiveSession = false;
          });
        }
      } else {
        print("No active session found for user");
        setState(() {
          cartItemCount = 0;
          hasActiveSession = false;
        });
      }
    } catch (e) {
      print("Error loading cart data: $e");
      setState(() {
        cartItemCount = 0;
        hasActiveSession = false;
      });
    }
  }

  void _onCartPressed() async {
    // First refresh cart data to get latest session status
    await _loadCartData();
    
    if (!hasActiveSession) {
      // Show warning dialog with red styling
      showDialog(
        context: context,
        barrierDismissible: false, // User must choose an option
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  'No Active Session',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You cannot access the cart yet!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please scan a cart first to start your shopping session.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, Scannertab.routeName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Scan Cart',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Navigate to cart
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartPage()),
      ).then((_) {
        // Refresh cart data when returning from cart page
        _loadCartData();
      });
    }
  }

  // Method to refresh cart data (can be called from other places)
  void refreshCartData() {
    _loadCartData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.Bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                      Icons.location_on_outlined, color: AppTheme.darkGreen),
                  const SizedBox(width: 8),
                  Container(
                    color: AppTheme.Bg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('cairo'),
                        Text('korniesh El Niel, Maadi, 13'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _onCartPressed,
                    child: Stack(
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 28),
                        if (cartItemCount > 0)
                          Positioned(
                            right: 0,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.green,
                              child: Text(
                                cartItemCount.toString(),
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              const Text('Hello,', style: TextStyle(fontSize: 24)),
              Text(userName ?? '', style: const TextStyle(fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D4A1E))),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Start Shopping'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  // Navigate to scanner tab
                  Navigator.pushNamed(context, Scannertab.routeName);
                },
              ),
              const SizedBox(height: 16),
              buildButton(Icons.qr_code_scanner, "Scanner", () {
                Navigator.pushNamed(context, Scannertab.routeName);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(IconData icon, String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0DC), // Light green background
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.lightGreen),
        title: Text(
          text,
          style: const TextStyle(color: Color(0xFF3D4A1E)),
        ),
        onTap: onPressed, // Use the passed function
      ),
    );
  }
}
