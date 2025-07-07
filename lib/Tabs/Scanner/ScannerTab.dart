import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/Tabs/Home/Cart_Page.dart';
import 'package:shop_n_goo/ui_utils.dart';
import 'package:shop_n_goo/cubit/scanner/scanner_cubit.dart';

class Scannertab extends StatefulWidget {
  static const String routeName = "Scanner";

  @override
  _ScannertabState createState() => _ScannertabState();
}

class _ScannertabState extends State<Scannertab> {
  String barcode = "Scan A Cart";
  bool hasScanned = false;
  bool isProcessing = false;
  String? sessionToken;
  final ScannerCubit _scannerCubit = ScannerCubit();

  @override
  void dispose() {
    _scannerCubit.close();
    super.dispose();
  }

  Future<void> _scanAndProcessBarcode() async {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Scan Cart',
        centerTitle: true,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 500,
      cameraFace: CameraFace.back,
      scanFormat: ScanFormat.ONLY_BARCODE,
    );

    if (res != null && res != '-1') {
      await _processBarcode(res);
    }
  }

  void _showManualEntryDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: AppTheme.darkGreen),
            SizedBox(width: 8),
            Text('Enter Cart Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the cart barcode manually:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Cart Code (e.g., CART001)',
                border: OutlineInputBorder(),
                hintText: 'CART001',
              ),
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (value) => _processManualEntry(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _processManualEntry(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkGreen,
              foregroundColor: Colors.white,
            ),
            child: Text('Start Session'),
          ),
        ],
      ),
    );
  }

  Future<void> _processManualEntry(String cartCode) async {
    Navigator.pop(context); // Close dialog
    
    if (cartCode.trim().isEmpty) {
      UIUtils.showMessage('Please enter a valid cart code');
      return;
    }
    
    await _processBarcode(cartCode.trim().toUpperCase());
  }

  Future<void> _processBarcode(String barcodeValue) async {
    setState(() {
      barcode = barcodeValue;
      isProcessing = true;
      // Do NOT set hasScanned here
    });
    
    // Show loading
    UIUtils.showLoading(context);
    
    try {
      // Start ESP32 session
      final response = await _scannerCubit.scanCart(barcodeValue);
      
      // Only set hasScanned = true if session_token is present (success)
      if (response['session_token'] != null) {
        setState(() {
          hasScanned = true;
          sessionToken = response['session_token'];
        });
        UIUtils.hideLoading(context);
        UIUtils.showMessage("Cart session started! ESP32 will automatically detect this session.");
        // Navigate to cart page and reset state after returning
        Navigator.pushNamed(context, CartPage.routeName).then((_) {
          setState(() {
            isProcessing = false;
            hasScanned = false;
            sessionToken = null;
            barcode = "Scan A Cart";
          });
        });
      } else {
        // Cart in use or other error
        setState(() {
          hasScanned = false;
          isProcessing = false;
        });
        UIUtils.hideLoading(context);
        // Show error dialog/snackbar
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text("Cart In Use"),
              ],
            ),
            content: Text("This cart is already in use. Please scan a different cart."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (exception) {
      setState(() {
        isProcessing = false;
        hasScanned = false;
      });
      UIUtils.hideLoading(context);
      UIUtils.showMessage(exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.Bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Cart Scanner',
          style: TextStyle(
            color: AppTheme.darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.06,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.05),
                
                Icon(
                  hasScanned ? Icons.check_circle : Icons.barcode_reader,
                  size: screenWidth * 0.3, 
                  color: hasScanned ? Colors.green : AppTheme.darkGreen
                ),
                SizedBox(height: screenHeight * 0.04),
                Text(
                  hasScanned ? 'Cart Scanned Successfully!' : 'Scan Cart Barcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w500,
                    color: hasScanned ? Colors.green : AppTheme.darkGreen,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Barcode: $barcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                
                // Manual Entry Option
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Scanner not working?',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextButton(
                  onPressed: isProcessing ? null : _showManualEntryDialog,
                  child: Text(
                    'Enter Cart Code Manually',
                    style: TextStyle(
                      color: AppTheme.darkGreen,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Show session token if available
                if (hasScanned && sessionToken != null) ...[
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ESP32 Session Token:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        SelectableText(
                          sessionToken!,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ESP32 will automatically detect this session',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: screenHeight * 0.05),
                
                // Scan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkGreen,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isProcessing ? null : _scanAndProcessBarcode,
                    child: Text(
                      isProcessing ? 'Processing...' : 'Scan Cart Barcode',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Reset Button (only visible after scan)
                if (hasScanned && !isProcessing) ...[
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          barcode = "Scan A Cart";
                          hasScanned = false;
                          sessionToken = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.darkGreen,
                        side: BorderSide(color: AppTheme.darkGreen),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Scan Different Cart',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
//
// class Scannertab extends StatefulWidget {
//   @override
//   _ScannertabState createState() => _ScannertabState();
// }
//
// class _ScannertabState extends State<Scannertab> {
//   String barcode = "Scan a product";
//   String result = '';
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Product Barcode Scanner'),
//         backgroundColor: Colors.transparent,
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Barcode: $barcode',
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               // onPressed: scanBarcode,
//               onPressed: () async {
//                 String? res = await SimpleBarcodeScanner.scanBarcode(
//                   context,
//                   barcodeAppBar: const BarcodeAppBar(
//                     appBarTitle: 'Test',
//                     centerTitle: false,
//                     enableBackButton: true,
//                     backButtonIcon: Icon(Icons.arrow_back_ios),
//                   ),
//                   isShowFlashIcon: true,
//                   delayMillis: 500,
//                   cameraFace: CameraFace.back,
//                   scanFormat: ScanFormat.ONLY_BARCODE,
//                 );
//                 result = res as String;
//                 setState(() {
//
//                 });
//               },
//               child: Text('Scan Barcode'),
//             ),
//             // Text('Scan Barcode Result: $result'),
//             // const SizedBox(
//             //   height: 10,
//             // ),
//             // ElevatedButton(
//             //   onPressed: () async {
//             //     SimpleBarcodeScanner.streamBarcode(
//             //       context,
//             //       barcodeAppBar: const BarcodeAppBar(
//             //         appBarTitle: 'Test',
//             //         centerTitle: false,
//             //         enableBackButton: true,
//             //         backButtonIcon: Icon(Icons.arrow_back_ios),
//             //       ),
//             //       isShowFlashIcon: true,
//             //       delayMillis: 2000,
//             //     ).listen((event) {
//             //       print("Stream Barcode Result: $event");
//             //     });
//             //   },
//             //   child: const Text('Stream Barcode'),
//             // ),
//             // const SizedBox(
//             //   height: 10,
//             // ),
//             // ElevatedButton(
//             //     onPressed: () {
//             //       // Navigator.push(context, MaterialPageRoute(builder: (context) {
//             //       //   // return const BarcodeWidgetPage();
//             //       // }));
//             //     },
//             //     child: const Text('Barcode Scanner Widget(Android Only)'))
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Function to scan the barcode
//   Future<void> scanBarcode() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SimpleBarcodeScanner(onBarcodeViewCreated: (BarcodeViewController controller) {  },),
//       ),
//     );
//
//     if (result != null && result.isNotEmpty) {
//       setState(() {
//         barcode = result; // Set the scanned barcode value
//       });
//     }
//   }
// }
