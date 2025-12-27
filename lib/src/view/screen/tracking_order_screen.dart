import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/service/order_service.dart';
import 'package:martfury/src/service/profile_service.dart';
import 'package:martfury/src/service/token_service.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';

class TrackingOrderScreen extends StatefulWidget {
  const TrackingOrderScreen({super.key});

  @override
  State<TrackingOrderScreen> createState() => _TrackingOrderScreenState();
}

class _TrackingOrderScreenState extends State<TrackingOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _orderService = OrderService();
  final _profileService = ProfileService();
  bool _isLoading = false;
  bool _isLoadingProfile = false;
  String? _error;
  Map<String, dynamic>? _trackingInfo;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Check if user is authenticated
      final token = await TokenService.getToken();
      if (token != null) {
        setState(() {
          _isLoadingProfile = true;
        });

        // Get user profile data
        final profileData = await _profileService.getProfile();

        // Prefill email if available
        if (profileData['email'] != null && profileData['email'].isNotEmpty) {
          _emailController.text = profileData['email'];
        }

        setState(() {
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      // Silently handle errors - user might not be logged in or network issues
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _trackOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _trackingInfo = null;
    });

    try {
      final trackingInfo = await _orderService.trackOrder(
        code: _orderCodeController.text,
        email: _emailController.text,
      );

      setState(() {
        _trackingInfo = trackingInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _orderCodeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'orders.track_order'.tr(),
          style: kAppTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.appBarForeground,
          ),
        ),
      ),
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.getCardBackgroundColor(context),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'orders.track_order'.tr(),
                    style: kAppTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getPrimaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'orders.track_order_description'.tr(),
                    style: kAppTextStyle(
                      fontSize: 14,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Code Field
                    Text(
                      'orders.order_code'.tr(),
                      style: kAppTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _orderCodeController,
                      style: kAppTextStyle(
                        color: AppColors.getPrimaryTextColor(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. #SF-10000049',
                        hintStyle: kAppTextStyle(
                          color: AppColors.getHintTextColor(context),
                        ),
                        filled: true,
                        fillColor: AppColors.getSurfaceColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'orders.order_code_required'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    Text(
                      'common.email'.tr(),
                      style: kAppTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      style: kAppTextStyle(
                        color: AppColors.getPrimaryTextColor(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'your-email@company.com',
                        hintStyle: kAppTextStyle(
                          color: AppColors.getHintTextColor(context),
                        ),
                        filled: true,
                        fillColor: AppColors.getSurfaceColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: _isLoadingProfile
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.getSecondaryTextColor(context),
                                    ),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.email_outlined,
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'common.email_required'.tr();
                        }
                        if (!value.contains('@')) {
                          return 'orders.invalid_email'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Track Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _trackOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black,
                                  ),
                                ),
                              )
                            : Text(
                                'orders.track'.tr(),
                                style: kAppTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Help Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.getSecondaryTextColor(context),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'orders.tracking_help_title'.tr(),
                                style: kAppTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getPrimaryTextColor(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'orders.tracking_help_description'.tr(),
                            style: kAppTextStyle(
                              fontSize: 12,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Error State
            if (_error != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: kAppTextStyle(
                          fontSize: 14,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

            // Tracking Information
            if (_trackingInfo != null) ...[
              const SizedBox(height: 16),

              // Success Header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'orders.order_found'.tr(),
                            style: kAppTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'orders.tracking_details_below'.tr(),
                            style: kAppTextStyle(
                              fontSize: 12,
                              color: Colors.green.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Order Status Timeline
              if (_trackingInfo!['order'] != null) _buildOrderTimeline(),

              // Order Information Card
              if (_trackingInfo!['order'] != null) _buildOrderInfoCard(),

              // Shipping Information Card
              if (_trackingInfo!['shipment'] != null) _buildShippingInfoCard(),

              // Payment Information Card
              if (_trackingInfo!['payment'] != null) _buildPaymentInfoCard(),

              // Order Items Card
              if (_trackingInfo!['order'] != null &&
                  _trackingInfo!['order']['products'] != null)
                _buildOrderItemsCard(),

              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline() {
    final order = _trackingInfo!['order'];
    final status =
        order['status']?['value']?.toString().toLowerCase() ?? 'pending';

    final steps = [
      {
        'key': 'pending',
        'title': 'orders.status_pending'.tr(),
        'icon': Icons.receipt_long_outlined,
        'description': 'orders.status_pending_desc'.tr(),
      },
      {
        'key': 'processing',
        'title': 'orders.status_processing'.tr(),
        'icon': Icons.inventory_2_outlined,
        'description': 'orders.status_processing_desc'.tr(),
      },
      {
        'key': 'shipped',
        'title': 'orders.status_shipped'.tr(),
        'icon': Icons.local_shipping_outlined,
        'description': 'orders.status_shipped_desc'.tr(),
      },
      {
        'key': 'delivered',
        'title': 'orders.status_delivered'.tr(),
        'icon': Icons.check_circle_outline,
        'description': 'orders.status_delivered_desc'.tr(),
      },
    ];

    final currentStepIndex = steps.indexWhere((step) => step['key'] == status);
    final activeStepIndex = currentStepIndex >= 0 ? currentStepIndex : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders.order_progress'.tr(),
            style: kAppTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = index <= activeStepIndex;
            final isCurrent = index == activeStepIndex;

            return _buildTimelineStep(
              step: step,
              isActive: isActive,
              isCurrent: isCurrent,
              isLast: index == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required Map<String, dynamic> step,
    required bool isActive,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.getSurfaceColor(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step['icon'] as IconData,
                color: isActive ? Colors.white : AppColors.getSecondaryTextColor(context),
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? AppColors.primary : AppColors.getBorderColor(context),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      step['title'] as String,
                      style: kAppTextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isActive
                            ? AppColors.getPrimaryTextColor(context)
                            : AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'orders.current_status'.tr(),
                          style: kAppTextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  step['description'] as String,
                  style: kAppTextStyle(
                    fontSize: 12,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard() {
    final order = _trackingInfo!['order'];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders.order_information'.tr(),
            style: kAppTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'orders.order_number_label'.tr(),
            order['code'] ?? 'N/A',
            copyable: true,
          ),
          _buildInfoRow(
            'orders.order_date_label'.tr(),
            _formatDate(order['created_at']),
          ),
          _buildInfoRow(
            'orders.total_amount_label'.tr(),
            order['amount_formatted'] ?? order['amount']?.toString() ?? 'N/A',
            highlight: true,
          ),
          if (order['tax_amount'] != null)
            _buildInfoRow(
              'orders.tax_amount_label'.tr(),
              order['tax_amount_formatted'] ??
                  order['tax_amount']?.toString() ??
                  'N/A',
            ),
          if (order['shipping_amount'] != null)
            _buildInfoRow(
              'orders.shipping_amount_label'.tr(),
              order['shipping_amount_formatted'] ??
                  order['shipping_amount']?.toString() ??
                  'N/A',
            ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoCard() {
    final shipment = _trackingInfo!['shipment'];
    final order = _trackingInfo!['order'];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders.shipping_information'.tr(),
            style: kAppTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          if (shipment['tracking_id'] != null)
            _buildInfoRow(
              'orders.tracking_id'.tr(),
              shipment['tracking_id'],
              copyable: true,
            ),
          if (shipment['shipping_company_name'] != null)
            _buildInfoRow(
              'orders.shipping_company'.tr(),
              shipment['shipping_company_name'],
            ),
          if (order['shipping_method'] != null)
            _buildInfoRow(
              'orders.shipping_method'.tr(),
              order['shipping_method']['label'] ?? 'N/A',
            ),
          if (shipment['estimate_date_shipped'] != null)
            _buildInfoRow(
              'orders.estimated_delivery'.tr(),
              _formatDate(shipment['estimate_date_shipped']),
              highlight: true,
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    final payment = _trackingInfo!['payment'];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders.payment_information'.tr(),
            style: kAppTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          if (payment['payment_channel'] != null)
            _buildInfoRow(
              'orders.payment_method'.tr(),
              payment['payment_channel']['label'] ?? 'N/A',
            ),
          if (payment['status'] != null)
            _buildStatusRow(
              'orders.payment_status'.tr(),
              payment['status']['label'] ?? 'N/A',
              payment['status']['value'] ?? 'pending',
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    final products = _trackingInfo!['order']['products'] as List;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'orders.order_items'.tr(),
                style: kAppTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getPrimaryTextColor(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${products.length} ${'common.items'.tr()}',
                  style: kAppTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...products.map((product) => _buildProductItem(product)),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: product['product_image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product['product_image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                  )
                : Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['product_name'] ?? 'N/A',
                  style: kAppTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getPrimaryTextColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${'common.qty'.tr()}: ${product['qty'] ?? 0}',
                      style: kAppTextStyle(
                        fontSize: 12,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                    Text(
                      product['price_formatted'] ??
                          product['price']?.toString() ??
                          'N/A',
                      style: kAppTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool copyable = false,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: kAppTextStyle(
                fontSize: 13,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: kAppTextStyle(
                      fontSize: 13,
                      fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                      color: highlight
                          ? AppColors.primary
                          : AppColors.getPrimaryTextColor(context),
                    ),
                  ),
                ),
                if (copyable)
                  GestureDetector(
                    onTap: () => _copyToClipboard(value),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.copy_outlined,
                        size: 16,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, String status) {
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'processing':
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
      case 'failed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = AppColors.getSecondaryTextColor(context);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: kAppTextStyle(
                fontSize: 13,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: kAppTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('common.copied_to_clipboard'.tr()),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
