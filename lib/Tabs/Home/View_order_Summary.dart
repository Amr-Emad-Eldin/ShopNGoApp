import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/data/models/order_item.dart';

class ViewOrderSummary extends StatefulWidget {
  static const String routeName = "ViewSummary";
  
  @override
  State<ViewOrderSummary> createState() => _ViewOrderSummaryState();
}

class _ViewOrderSummaryState extends State<ViewOrderSummary> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // Get arguments passed from ThankU page
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final orderId = args?['orderId'] as String? ?? "ORDER${DateTime.now().millisecondsSinceEpoch}";
    final orderDate = args?['orderDate'] as DateTime? ?? DateTime.now();
    final items = args?['items'] as List<dynamic>? ?? [];
    final totalAmount = args?['totalAmount'] as double? ?? 0.0;
    final discount = args?['discount'] as double? ?? 0.0;
    final paymentMethod = args?['paymentMethod'] as String? ?? "Visa";
    final paymentDetails = args?['paymentDetails'] as String? ?? "**** 8600";
    
    // Debug logging
    print('ViewOrderSummary: Received args: $args');
    print('ViewOrderSummary: Items count: ${items.length}');
    print('ViewOrderSummary: Total amount: $totalAmount');
    print('ViewOrderSummary: Payment method: $paymentMethod');
    print('ViewOrderSummary: Payment details: $paymentDetails');
    if (items.isNotEmpty) {
      print('ViewOrderSummary: First item: ${items.first}');
    }
    
    final itemCount = items.fold<int>(0, (sum, item) => sum + (item.quantity as int));
    final subtotal = items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.darkGreen),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Order Summary",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGreen)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Order ID Box
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order ID - $orderId",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text("on ${_formatDate(orderDate)}",
                      style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Order Details Box
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text("Item value ($itemCount items)"), Text("${subtotal.toStringAsFixed(2)}LE")],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text("Discount"), Text("${discount.toStringAsFixed(2)}LE")],
                  ),
                  Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Orders",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("${totalAmount.toStringAsFixed(2)}LE",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Payment Box
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Information",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkGreen,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paymentMethod,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            paymentDetails,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${totalAmount.toStringAsFixed(2)}LE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Product Details
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkGreen,
                    ),
                  ),
                  SizedBox(height: 12),
                  if (items.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No items in this order",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ...items.map((item) => 
                  Column(
                    children: [
                      buildProductRow(item),
                          if (items.indexOf(item) < items.length - 1) 
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1, color: Colors.grey[300]),
                            ),
                    ],
                  )
                ).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductRow(OrderItem item) {
    final itemTotal = item.price * item.quantity;
    
    return Row(
      children: [
        // Handle both network images and local assets
        item.image.startsWith('http') || item.image.startsWith('https')
            ? Image.network(
                item.image,
                height: 50,
                width: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/Molto.png',
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  );
                },
              )
            : Image.asset(
                item.image,
                height: 50,
                width: 50,
                fit: BoxFit.contain,
              ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "${item.quantity} x ${item.price.toStringAsFixed(2)}LE",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          "${itemTotal.toStringAsFixed(2)}LE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.darkGreen,
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'pm' : 'am';
    final hour12 = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    
    return "$month ${date.day}, ${date.year} · ${hour12.toString().padLeft(2, '0')}:$minute $ampm";
  }
}