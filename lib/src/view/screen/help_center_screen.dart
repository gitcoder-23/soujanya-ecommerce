import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:martfury/src/model/help_item.dart';
import 'package:martfury/src/service/help_service.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/view/screen/webview_screen.dart';
import 'package:martfury/core/app_config.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  List<HelpCategory> _categories = [];
  List<HelpItem> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _useWebView = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _expandedCategories = {};
  bool _didLoadContent = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadContent) {
      _didLoadContent = true;
      _loadHelpContent();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHelpContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // If local help is disabled in config, use WebView
    if (!AppConfig.useLocalHelpCenter) {
      if (mounted) {
        setState(() {
          _useWebView = true;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // Get current locale from context
      final locale = context.locale.languageCode;
      final categories = await HelpService.getHelpContent(languageCode: locale);
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If local help content fails to load, fallback to WebView
      if (mounted) {
        setState(() {
          _useWebView = true;
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _searchResults = [];
      } else {
        _isSearching = true;
        _searchResults = HelpService.searchHelp(_categories, query);
      }
    });
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person_outline;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'credit_card':
        return Icons.credit_card_outlined;
      case 'local_shipping':
        return Icons.local_shipping_outlined;
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'phone_android':
        return Icons.phone_android_outlined;
      case 'support_agent':
        return Icons.support_agent_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we need to use WebView, show the WebViewScreen directly
    if (_useWebView) {
      return WebViewScreen(
        url: AppConfig.helpCenterUrl,
        title: 'profile.help_center'.tr(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'profile.help_center'.tr(),
          style: kAppTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _error != null
              ? _buildErrorState()
              : Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child:
                        _isSearching
                            ? _buildSearchResults()
                            : _buildCategoriesList(),
                  ),
                ],
              ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: kAppTextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          hintText: 'profile.search_help'.tr(),
          hintStyle: kAppTextStyle(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.6),
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black54),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(HelpCategory category) {
    final isExpanded = _expandedCategories[category.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.getBorderColor(context), width: 1),
      ),
      color: AppColors.getCardBackgroundColor(context),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category.id] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIconData(category.icon),
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: kAppTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getPrimaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${category.items.length} ${category.items.length == 1 ? 'article' : 'articles'}',
                          style: kAppTextStyle(
                            fontSize: 13,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            ...category.items.map((item) => _buildHelpItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildHelpItem(HelpItem item) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        item.question,
        style: kAppTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.getPrimaryTextColor(context),
        ),
      ),
      iconColor: AppColors.primary,
      collapsedIconColor: AppColors.getSecondaryTextColor(context),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item.answer,
            style: kAppTextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.getSecondaryTextColor(
                  context,
                ).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'profile.no_results_found'.tr(),
                style: kAppTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getPrimaryTextColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'profile.try_different_keywords'.tr(),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.getBorderColor(context),
              width: 1,
            ),
          ),
          color: AppColors.getCardBackgroundColor(context),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              item.question,
              style: kAppTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.getPrimaryTextColor(context),
              ),
            ),
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.getSecondaryTextColor(context),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.answer,
                  style: kAppTextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'common.loading'.tr(),
            style: kAppTextStyle(
              fontSize: 14,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'common.error_occurred'.tr(),
              style: kAppTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getPrimaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: kAppTextStyle(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadHelpContent,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.refresh),
              label: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
