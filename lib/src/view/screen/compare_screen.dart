import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/service/compare_service.dart';
import 'package:martfury/src/service/cart_service.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/utils/app_internet_connection_wrapper.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCompareDetails();
  }

  Future<void> _getCompareDetails() async {
    try {
      setState(() => _isLoading = true);
      final response = await CompareService().getCompare();
      setState(() {
        _products =
            response['items'].isNotEmpty
                ? response['items'].values.toList()
                : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromCompare(String productId) async {
    try {
      await CompareService().removeFromCompare(productId);
      _getCompareDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, color: AppColors.primary, size: 16);
          } else if (index < rating.ceil() && rating % 1 != 0) {
            return Icon(Icons.star_half, color: AppColors.primary, size: 16);
          } else {
            return Icon(
              Icons.star_outline,
              color: AppColors.getSecondaryTextColor(context),
              size: 16,
            );
          }
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: kAppTextStyle(
            fontSize: 12,
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceText(dynamic product) {
    if (product == null || product == '-') {
      return Text(
        '-',
        style: kAppTextStyle(
          fontSize: 14,
          color: AppColors.getSecondaryTextColor(context),
        ),
      );
    }

    final String currentPrice = product['price_formatted'] ?? '';
    final String originalPrice = product['original_price_formatted'] ?? '';
    final bool hasDiscount =
        originalPrice.isNotEmpty &&
        originalPrice != currentPrice &&
        (product['original_price'] ?? 0) > (product['price'] ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentPrice,
          style: kAppTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(height: 2),
          Text(
            originalPrice,
            style: kAppTextStyle(
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholderProduct() {
    return Expanded(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.getBackgroundColor(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 24,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'compare.add_more_products'.tr(),
                    style: kAppTextStyle(
                      fontSize: 12,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '',
            style: kAppTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Product images skeleton
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children:
                List.generate(
                  2,
                  (index) => [
                    if (index > 0) const SizedBox(width: 16),
                    _buildProductImageSkeleton(),
                  ],
                ).expand((widgets) => widgets).toList(),
          ),
        ),
        // Add to cart buttons skeleton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children:
                List.generate(
                  2,
                  (index) => [
                    if (index > 0) const SizedBox(width: 16),
                    _buildButtonSkeleton(),
                  ],
                ).expand((widgets) => widgets).toList(),
          ),
        ),
        const SizedBox(height: 20),
        // Comparison attributes skeleton
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(
                5,
                (index) => _buildAttributeRowSkeleton(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImageSkeleton() {
    return Expanded(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getSkeletonColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.getSkeletonColor(context),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.getSkeletonColor(context),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSkeleton() {
    return Expanded(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.getSkeletonColor(context),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildAttributeRowSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 14,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.getSkeletonColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ...List.generate(
            2,
            (index) => [
              if (index > 0) const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ).expand((widgets) => widgets).toList(),
        ],
      ),
    );
  }

  Widget _buildAttributeRow(String attribute, List<dynamic> values) {
    List<dynamic> paddedValues = List.from(values);
    if (paddedValues.length == 1) {
      paddedValues.add('-');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              attribute,
              style: kAppTextStyle(
                fontSize: 13,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ...paddedValues
              .asMap()
              .entries
              .map((entry) {
                int index = entry.key;
                var value = entry.value;
                bool isPlaceholder = values.length == 1 && value == '-';
                return [
                  if (index > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child:
                        isPlaceholder
                            ? Text(
                              '-',
                              style: kAppTextStyle(
                                fontSize: 13,
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                            )
                            : attribute == 'compare.rating'.tr()
                            ? _buildRatingStars(
                              double.tryParse(value?.toString() ?? '0') ?? 0,
                            )
                            : attribute == 'compare.price'.tr()
                            ? _buildPriceText(value)
                            : Text(
                              value?.toString() ?? '-',
                              style: kAppTextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.getPrimaryTextColor(context),
                              ),
                            ),
                  ),
                ];
              })
              .expand((widgets) => widgets)
              .toList(),
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Expanded(
      child: Column(
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    product['image_url'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: AppColors.getSurfaceColor(context),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.getSecondaryTextColor(context),
                            size: 32,
                          ),
                        ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removeFromCompare(product['id'].toString()),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackgroundColor(context),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product['name'] ?? '',
            style: kAppTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.getPrimaryTextColor(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.getSurfaceColor(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.compare_arrows_outlined,
                size: 48,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'compare.no_products_to_compare'.tr(),
              style: kAppTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.getPrimaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'compare.add_products_to_compare'.tr(),
              style: kAppTextStyle(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppInternetConnectionWrapper(
      child: Scaffold(
        backgroundColor: AppColors.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            'compare.compare'.tr(),
            style: kAppTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.appBarForeground,
            ),
          ),
        ),
        body:
            _isLoading
                ? _buildLoadingState()
                : _products.isEmpty
                ? _buildEmptyState()
                : Column(
                  children: [
                    // Show notification message when only one product
                    if (_products.length == 1)
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'compare.single_product_message'.tr(),
                                style: kAppTextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Product cards
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._products
                              .asMap()
                              .entries
                              .map((entry) {
                                int index = entry.key;
                                var product = entry.value;
                                return [
                                  if (index > 0) const SizedBox(width: 16),
                                  _buildProductCard(product),
                                ];
                              })
                              .expand((widgets) => widgets)
                              .toList(),
                          if (_products.length == 1) ...[
                            const SizedBox(width: 16),
                            _buildPlaceholderProduct(),
                          ],
                        ],
                      ),
                    ),

                    // Add to cart buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          ..._products
                              .asMap()
                              .entries
                              .map((entry) {
                                int index = entry.key;
                                var product = entry.value;
                                return [
                                  if (index > 0) const SizedBox(width: 16),
                                  Expanded(
                                    child: SizedBox(
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final scaffoldMessenger =
                                              ScaffoldMessenger.of(context);
                                          try {
                                            await CartService().createCartItem(
                                              productId:
                                                  product['id'].toString(),
                                              quantity: 1,
                                            );
                                            if (mounted) {
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'product.added_to_cart'
                                                        .tr(),
                                                  ),
                                                  backgroundColor:
                                                      AppColors.success,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(e.toString()),
                                                  backgroundColor:
                                                      AppColors.error,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'product.add_to_cart'.tr(),
                                          style: kAppTextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ];
                              })
                              .expand((widgets) => widgets)
                              .toList(),
                          if (_products.length == 1) ...[
                            const SizedBox(width: 16),
                            const Expanded(child: SizedBox()),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Comparison attributes
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAttributeRow(
                              'compare.rating'.tr(),
                              _products
                                  .map((p) => p['reviews_avg'] ?? 0)
                                  .toList(),
                            ),
                            _buildAttributeRow(
                              'compare.price'.tr(),
                              _products.toList(),
                            ),
                            _buildAttributeRow(
                              'compare.stock_status'.tr(),
                              _products
                                  .map((p) => p['stock_status_label'] ?? '-')
                                  .toList(),
                            ),
                            _buildAttributeRow(
                              'compare.sku'.tr(),
                              _products.map((p) => p['sku'] ?? '-').toList(),
                            ),
                            if (_products.isNotEmpty &&
                                _products[0]['specifications'] != null)
                              ...(_products[0]['specifications']
                                      as Map<String, dynamic>)
                                  .keys
                                  .map(
                                    (spec) => _buildAttributeRow(
                                      spec,
                                      _products
                                          .map(
                                            (p) => p['specifications']?[spec],
                                          )
                                          .toList(),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
