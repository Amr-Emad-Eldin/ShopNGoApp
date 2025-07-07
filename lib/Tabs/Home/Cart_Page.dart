import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/Tabs/Home/Summary_order.dart';
import 'package:shop_n_goo/cubit/scanner/scanner_cubit.dart';
import 'package:shop_n_goo/ui_utils.dart';
import 'dart:async';

class CartPage extends StatefulWidget {
  static const String routeName = "cart";
  
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  double subtotal = 0.0;
  bool isLoading = true;
  String? errorMessage;
  final ScannerCubit _scannerCubit = ScannerCubit();
  Timer? _refreshTimer;
  bool _hasActiveSession = false;
  int _previousItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scannerCubit.close();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Refresh cart every 2 seconds when there's an active session
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (_hasActiveSession && mounted) {
        await _loadCart(silent: true); // Silent refresh without loading indicator
      }
    });
  }

  Future<void> _loadCart({bool silent = false}) async {
    try {
      if (!silent) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      }

      print("Cart page: Loading cart data...");
      final cartData = await _scannerCubit.getCart();
      print("Cart page: Cart data received: $cartData");
      
      if (cartData['session'] != null) {
        final session = cartData['session'];
        final items = session['items'] as List<dynamic>? ?? [];
        
        print("Cart page: Session found: ${session['is_active']}, Items: ${items.length}");
        
        // Update session status
        _hasActiveSession = session['is_active'] ?? false;
        
        // Group items by name and calculate total quantity
        Map<String, CartItem> groupedItems = {};
        
        for (var item in items) {
          String name = item['name'] ?? 'Unknown Product';
          double price = (item['price'] ?? 0.0).toDouble();
          String imageUrl = item['image_url'] ?? 'assets/images/Molto.png'; // Use actual image_url
          int quantity = item['quantity'] ?? 1;
          
          if (groupedItems.containsKey(name)) {
            // If item already exists, increase quantity
            CartItem existingItem = groupedItems[name]!;
            groupedItems[name] = CartItem(
              name: existingItem.name,
              price: existingItem.price,
              image: existingItem.image,
              quantity: existingItem.quantity + quantity,
            );
          } else {
            // Add new item
            groupedItems[name] = CartItem(
              name: name,
              price: price,
              image: imageUrl,
              quantity: quantity,
            );
          }
        }
        
        if (mounted) {
        setState(() {
          cartItems = groupedItems.values.toList();
          subtotal = (session['total_amount'] ?? 0.0).toDouble();
          isLoading = false;
        });
          
          // Check for new items (only for silent refreshes)
          if (silent) {
            _checkForNewItems(groupedItems.values.toList());
          }
        }
      } else {
        print("Cart page: No session found in cart data");
        _hasActiveSession = false;
        if (mounted) {
        setState(() {
          cartItems = [];
          subtotal = 0.0;
          isLoading = false;
        });
        }
      }
    } catch (e) {
      print("Cart page: Error loading cart data: $e");
      if (mounted) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
    }
  }

  void _checkForNewItems(List<CartItem> newItems) {
    if (_previousItemCount > 0 && newItems.length > _previousItemCount) {
      // New items were added
      int newItemCount = newItems.length - _previousItemCount;
      UIUtils.showMessage('$newItemCount new item${newItemCount > 1 ? 's' : ''} added to cart!');
    }
    _previousItemCount = newItems.length;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.Bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
          'Cart',
          style: GoogleFonts.schibstedGrotesk(
            fontSize: size.width * 0.06,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
            if (_hasActiveSession)
              Text(
                'Auto-refresh active',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ],
        ),
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: AppTheme.darkGreen))
        : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading cart',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCart,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Start shopping to add items to your cart',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04, vertical: size.height * 0.01),
                child: Column(
                  children: [
                    ...cartItems.map((item) {
                      return Container(
                        margin: EdgeInsets.only(bottom: size.height * 0.015),
                        padding: EdgeInsets.all(size.width * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            // Handle both network images and local assets
                            item.image.startsWith('http') || item.image.startsWith('https')
                                ? Image.network(
                                    item.image,
                                    height: size.width * 0.15,
                                    width: size.width * 0.15,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/Molto.png',
                                        height: size.width * 0.15,
                                        width: size.width * 0.15,
                                        fit: BoxFit.contain,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    item.image,
                                    height: size.width * 0.15,
                                    width: size.width * 0.15,
                                    fit: BoxFit.contain,
                                  ),
                            SizedBox(width: size.width * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: size.width * 0.045)),
                                  SizedBox(height: size.height * 0.005),
                                  Text('${item.price.toStringAsFixed(2)}LE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: size.width * 0.04)),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.035,
                                  vertical: size.height * 0.01),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                item.quantity.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.width * 0.045),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Subtotal and Checkout
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(size.width * 0.08)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Sub_Total",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * 0.045)),
                              Text("${subtotal.toStringAsFixed(2)}LE",
                                  style: TextStyle(fontSize: size.width * 0.045)),
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
                          SizedBox(
                            width: double.infinity,
                            height: size.height * 0.065,
                            child: ElevatedButton(
                              onPressed: () {Navigator.pushNamed(context, SummaryOrderPage.routeName);},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.darkGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text("Checkout",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * 0.045)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class CartItem {
  final String name;
  final double price;
  final String image;
  final int quantity;

  CartItem(
      {required this.name,
        required this.price,
        required this.image,
        required this.quantity});
}
