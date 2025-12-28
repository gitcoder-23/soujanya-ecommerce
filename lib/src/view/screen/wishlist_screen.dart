import 'package:flutter/material.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/utils/app_internet_connection_wrapper.dart';
import 'package:martfury/src/view/screen/product_detail_screen.dart';
import 'dart:async';
import 'package:martfury/src/service/wishlist_service.dart';
import 'package:martfury/src/view/widget/product_card.dart';
import 'package:martfury/src/service/cart_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen> {
  List<dynamic> _wishlistItems = [];
  bool _isLoading = true;
  bool _isInitialized = false;
  final WishlistService _wishlistService = WishlistService();
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized && mounted) {
      loadWishlist(showLoading: false);
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    try {
      await _wishlistService.removeFromWishlist(productId);
      await loadWishlist();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'wishlist.item_removed_from_wishlist'.tr(),
            style: kAppTextStyle(),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'wishlist.failed_to_remove_item'.tr(),
            style: kAppTextStyle(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _addToCart(String productId) async {
    try {
      await _cartService.createCartItem(productId: productId, quantity: 1);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'wishlist.item_added_to_cart'.tr(),
            style: kAppTextStyle(),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'wishlist.failed_to_add_item_to_cart'.tr(),
            style: kAppTextStyle(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> loadWishlist({bool showLoading = true}) async {
    try {
      if (showLoading && mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final response = await _wishlistService.getWishlist();

      if (mounted) {
        setState(() {
          final items = response['items'];
          if (items is Map && items.isNotEmpty) {
            _wishlistItems = items.values.toList();
          } else if (items is List && items.isNotEmpty) {
            _wishlistItems = items;
          } else {
            _wishlistItems = [];
          }
          _isLoading = false;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
      }
    }
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
                Icons.favorite_outline,
                size: 48,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'wishlist.empty_wishlist'.tr(),
              style: kAppTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.getPrimaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'wishlist.add_products_to_wishlist'.tr(),
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

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.48,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildProductSkeleton();
      },
    );
  }

  Widget _buildProductSkeleton() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getSkeletonColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.getSkeletonColor(context),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          width: 80,
          decoration: BoxDecoration(
            color: AppColors.getSkeletonColor(context),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getSkeletonColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.getSkeletonColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWishlistItem(dynamic item) {
    return Column(
      children: [
        Expanded(
          child: ProductCard(
            imageUrl: item['image_url'] ?? '',
            title: item['name'] ?? '',
            price: (item['price'] as num?)?.toDouble() ?? 0.0,
            originalPrice: (item['original_price'] as num?)?.toDouble() ?? 0.0,
            priceFormatted: item['price_formatted'] ?? '',
            originalPriceFormatted: item['original_price_formatted'] ?? '',
            rating: (item['reviews_avg'] as num?)?.toDouble(),
            reviewsCount: item['reviews_count'] as int?,
            seller: item['store']?['name'] as String?,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ProductDetailScreen(product: {'slug': item['slug']}),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _removeFromWishlist(item['id'].toString()),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.getBorderColor(context)),
                    backgroundColor: AppColors.getSurfaceColor(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'wishlist.remove'.tr(),
                    style: kAppTextStyle(
                      fontSize: 12,
                      color: AppColors.getPrimaryTextColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addToCart(item['id'].toString()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                child: SvgPicture.asset(
                  'assets/images/icons/cart.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ],
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
            'wishlist.wishlist'.tr(),
            style: kAppTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.appBarForeground,
            ),
          ),
          actions: [
            if (_wishlistItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_wishlistItems.length} ${'common.items'.tr()}',
                      style: kAppTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body:
            _isLoading
                ? _buildLoadingState()
                : RefreshIndicator(
                  onRefresh: loadWishlist,
                  child:
                      _wishlistItems.isEmpty
                          ? LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: _buildEmptyState(),
                                ),
                              );
                            },
                          )
                          : GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.48,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: _wishlistItems.length,
                            itemBuilder: (context, index) {
                              return _buildWishlistItem(_wishlistItems[index]);
                            },
                          ),
                ),
      ),
    );
  }
}
