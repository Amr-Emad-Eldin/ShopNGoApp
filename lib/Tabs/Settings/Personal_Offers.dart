import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'package:shop_n_goo/api_constants.dart';
import 'package:shop_n_goo/data/data_sources/auth_local_data_source.dart';

class PersonalOffersPage extends StatefulWidget {
  static const String routeName = "PersonalOffers";

  @override
  _PersonalOffersPageState createState() => _PersonalOffersPageState();
}

class _PersonalOffersPageState extends State<PersonalOffersPage> {
  final Dio _dio = Dio();
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  bool isLoading = true;
  List<Map<String, dynamic>> notifications = [];
  Map<String, dynamic>? userStats;
  String userSegment = 'bronze';

  @override
  void initState() {
    super.initState();
    _loadPersonalOffers();
  }

  Future<void> _loadPersonalOffers() async {
    try {
      setState(() => isLoading = true);
      
      String token = await _authLocalDataSource.getToken();
      
      final response = await _dio.get(
        '${ApiConstants.baseUrl}auth/personal-offers',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications = List<Map<String, dynamic>>.from(response.data['notifications']);
          userStats = response.data['user_stats'];
          userSegment = response.data['user_segment'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage('Error loading personal offers: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  Widget _buildSegmentCard() {
    final segmentColors = {
      'platinum': Colors.purple,
      'gold': Colors.amber,
      'silver': Colors.grey,
      'bronze': Colors.brown,
    };

    final segmentDescriptions = {
      'platinum': 'High-value customer',
      'gold': 'Regular customer',
      'silver': 'Occasional customer',
      'bronze': 'New customer',
    };

    final segmentDiscounts = {
      'platinum': '35%',
      'gold': '23%',
      'silver': '15%',
      'bronze': '10%',
    };

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              segmentColors[userSegment]!.withOpacity(0.1),
              segmentColors[userSegment]!.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Segment',
                    style: GoogleFonts.schibstedGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: segmentColors[userSegment],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userSegment.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                segmentDescriptions[userSegment]!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Maximum discount: ${segmentDiscounts[userSegment]}',
                style: TextStyle(
                  color: segmentColors[userSegment],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (userStats != null) ...[
                SizedBox(height: 8),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Orders: ${userStats!['total_orders']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'Total Spent: ${userStats!['total_spent'].toStringAsFixed(2)}LE',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    notification['title'],
                    style: GoogleFonts.schibstedGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${notification['discount_percentage']}% OFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              notification['message'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.green[800], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Promo Code: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  Text(
                    notification['promo_code'],
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Received: ${notification['created_at'].split('T')[0]}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Personal Offers",
          style: GoogleFonts.schibstedGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.darkGreen),
            onPressed: _loadPersonalOffers,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.darkGreen))
          : RefreshIndicator(
              onRefresh: _loadPersonalOffers,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Segment Card
                    _buildSegmentCard(),
                    
                    SizedBox(height: 24),
                    
                    // Notifications Section
                    Text(
                      "Your Offers",
                      style: GoogleFonts.schibstedGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    if (notifications.isEmpty)
                      Container(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No offers yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Check back later for personalized offers!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...notifications.map((notification) => _buildNotificationCard(notification)).toList(),
                    
                    SizedBox(height: 32),
                    
                    // How to use section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "How to Use Your Promo Codes",
                              style: GoogleFonts.schibstedGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkGreen,
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildInstructionStep(
                              "1",
                              "Copy the promo code from your offer above",
                              Icons.copy,
                            ),
                            _buildInstructionStep(
                              "2",
                              "Go to checkout when making a purchase",
                              Icons.shopping_cart,
                            ),
                            _buildInstructionStep(
                              "3",
                              "Enter the promo code in the discount field",
                              Icons.local_offer,
                            ),
                            _buildInstructionStep(
                              "4",
                              "Enjoy your discount!",
                              Icons.check_circle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.darkGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Icon(icon, color: AppTheme.darkGreen, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 