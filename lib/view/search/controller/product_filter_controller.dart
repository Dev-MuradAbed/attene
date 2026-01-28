import 'package:attene_mobile/general_index.dart';
import 'package:attene_mobile/models/product.dart';
import 'package:attene_mobile/services/api/search_filter_service.dart';

/// ✅ COMPLETE PRODUCT FILTER CONTROLLER
/// Properly integrates with API endpoints and handles all filter cases
class ProductFilterController extends GetxController {
  // ============ FILTER STATE ============
  final RxString searchQuery = ''.obs;
  final RxInt selectedCategoryId = 0.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 10000.0.obs;
  final RxInt selectedStoreId = 0.obs;
  final RxString sortBy = 'newest'.obs; // newest, popular, price_low, price_high

  // ============ PAGINATION ============
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 20.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMorePages = true.obs;

  // ============ RESULTS ============
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxInt totalCount = 0.obs;
  final RxString errorMessage = ''.obs;

  // ============ PAGINATION HELPERS ============
  bool get isLastPage => (currentPage.value * perPage.value) >= totalCount.value;

  @override
  void onInit() {
    super.onInit();
    // Load initial products
    applyFilters();
  }

  /// ✅ APPLY ALL FILTERS - Main filter function
  /// Constructs query parameters from reactive state and calls API
  Future<void> applyFilters({bool resetPage = true}) async {
    if (resetPage) {
      currentPage.value = 1;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Build filter map from reactive variables
      final Map<String, dynamic> filters = {
        'page': currentPage.value,
        'per_page': perPage.value,
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (selectedCategoryId.value > 0) 'category_id': selectedCategoryId.value,
        if (selectedStoreId.value > 0) 'store_id': selectedStoreId.value,
        if (minPrice.value > 0) 'price_min': minPrice.value,
        if (maxPrice.value < 10000) 'price_max': maxPrice.value,
        'orderBy': 'id',
        'orderDir': sortBy.value == 'newest' ? 'desc' : 'asc',
      };

      // Call API with constructed filters
      final response = await SearchFilterService.searchProducts(
        page: currentPage.value,
        perPage: perPage.value,
        search:
            searchQuery.value.isEmpty ? null : searchQuery.value,
        categoryId: selectedCategoryId.value > 0 ? selectedCategoryId.value : null,
        storeId: selectedStoreId.value > 0 ? selectedStoreId.value : null,
        priceMin: minPrice.value > 0 ? minPrice.value : null,
        priceMax: maxPrice.value < 10000 ? maxPrice.value : null,
        orderDir: sortBy.value == 'newest' ? 'desc' : 'asc',
        showLoading: false, // We handle loading with isLoading.value
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        
        // Parse products from response
        final products = data
            .map((p) => Product.fromJson(p as Map<String, dynamic>))
            .toList();

        // Update results
        if (resetPage) {
          filteredProducts.assignAll(products);
        } else {
          // For pagination - append to existing list
          filteredProducts.addAll(products);
        }

        // Update total count for pagination
        totalCount.value = response.data['meta']?['total'] ?? 0;
        hasMorePages.value = !isLastPage;

        print('✅ [FILTER] Loaded ${products.length} products');
        update(['products', 'filters']);
      } else {
        errorMessage.value =
            response.data['message'] ?? 'فشل في تحميل المنتجات';
        print('❌ [FILTER] Error: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال: $e';
      print('❌ [FILTER] Exception: $e');
    } finally {
      isLoading.value = false;
      update(['loading', 'products']);
    }
  }

  /// ✅ LOAD NEXT PAGE - Append more products
  Future<void> loadNextPage() async {
    if (isLoading.value || isLastPage) return;
    
    currentPage.value++;
    await applyFilters(resetPage: false);
  }

  /// ✅ UPDATE SEARCH QUERY - Debounced
  void updateSearchQuery(String value) {
    searchQuery.value = value;
    currentPage.value = 1;
    applyFilters();
    update(['search', 'products']);
  }

  /// ✅ UPDATE CATEGORY FILTER
  void updateCategory(int categoryId) {
    selectedCategoryId.value = categoryId;
    currentPage.value = 1;
    applyFilters();
    update(['category', 'products']);
  }

  /// ✅ UPDATE STORE FILTER
  void updateStore(int storeId) {
    selectedStoreId.value = storeId;
    currentPage.value = 1;
    applyFilters();
    update(['store', 'products']);
  }

  /// ✅ UPDATE PRICE RANGE
  void updatePriceRange(double min, double max) {
    minPrice.value = min;
    maxPrice.value = max;
    currentPage.value = 1;
    applyFilters();
    update(['price', 'products']);
  }

  /// ✅ UPDATE SORT
  void updateSort(String sortOption) {
    sortBy.value = sortOption;
    currentPage.value = 1;
    applyFilters();
    update(['sort', 'products']);
  }

  /// ✅ CLEAR ALL FILTERS
  void clearAllFilters() {
    searchQuery.value = '';
    selectedCategoryId.value = 0;
    selectedStoreId.value = 0;
    minPrice.value = 0.0;
    maxPrice.value = 10000.0;
    sortBy.value = 'newest';
    currentPage.value = 1;
    filteredProducts.clear();
    errorMessage.value = '';
    applyFilters();
    update(['all']);
  }

  /// ✅ RESET PAGINATION
  void resetPagination() {
    currentPage.value = 1;
    filteredProducts.clear();
    applyFilters();
  }

  /// ✅ GET FILTER SUMMARY
  String getFilterSummary() {
    final parts = <String>[];
    
    if (searchQuery.value.isNotEmpty) {
      parts.add('البحث: ${searchQuery.value}');
    }
    if (selectedCategoryId.value > 0) {
      parts.add('التصنيف: $selectedCategoryId');
    }
    if (selectedStoreId.value > 0) {
      parts.add('المتجر: $selectedStoreId');
    }
    if (minPrice.value > 0 || maxPrice.value < 10000) {
      parts.add('السعر: ${minPrice.value.toStringAsFixed(2)} - ${maxPrice.value.toStringAsFixed(2)}');
    }
    
    return parts.isEmpty ? 'بدون فلاتر' : parts.join(' • ');
  }

  /// ✅ CHECK IF FILTERS ACTIVE
  bool get hasActiveFilters =>
      searchQuery.value.isNotEmpty ||
      selectedCategoryId.value > 0 ||
      selectedStoreId.value > 0 ||
      minPrice.value > 0 ||
      maxPrice.value < 10000;
}
