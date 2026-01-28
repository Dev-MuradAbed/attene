import 'package:dio/dio.dart';
import 'package:attene_mobile/services/api/api_client.dart';
import 'package:attene_mobile/services/api/api_guard.dart';
import 'package:attene_mobile/models/product.dart';
import 'package:attene_mobile/models/store.dart';

/// Complete Search & Filter Service
/// Properly integrated with API documentation
class SearchFilterService {
  SearchFilterService._();

  /// ✅ PRODUCTS SEARCH - Using correct endpoint from API docs
  /// Endpoint: GET /products/search?page=1
  /// Filters: page, per_page, search, category_id, store_id, price_min, price_max
  static Future<Response> searchProducts({
    required int page,
    int perPage = 20,
    String? search,
    int? categoryId,
    int? storeId,
    double? priceMin,
    double? priceMax,
    String orderBy = 'id',
    String orderDir = 'desc',
    bool showLoading = true,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'orderBy': orderBy,
      'orderDir': orderDir,
      // Add optional filters only if provided
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null && categoryId > 0) 'category_id': categoryId,
      if (storeId != null && storeId > 0) 'store_id': storeId,
      if (priceMin != null && priceMin > 0) 'price_min': priceMin,
      if (priceMax != null && priceMax > 0) 'price_max': priceMax,
    };

    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/products/search',
        queryParameters: queryParams,
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل المنتجات...',
    );
  }

  /// ✅ ADMIN PRODUCTS - Different endpoint for admin
  /// Endpoint: GET /admin/products?page=1&per_page=10&section_id=3
  static Future<Response> adminSearchProducts({
    required int page,
    int perPage = 10,
    int? sectionId,
    String? search,
    bool showLoading = true,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (sectionId != null && sectionId > 0) 'section_id': sectionId,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/admin/products',
        queryParameters: queryParams,
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل المنتجات...',
    );
  }

  /// ✅ MERCHANT PRODUCTS - Merchant view of their products
  /// Endpoint: GET /merchants/products
  static Future<Response> merchantProducts({
    String? search,
    bool showLoading = true,
  }) {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
    };

    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/merchants/products',
        queryParameters: queryParams,
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل المنتجات...',
    );
  }

  /// ✅ STORES SEARCH
  /// Endpoint: GET /stores/search
  static Future<Response> searchStores({
    Map<String, dynamic>? filters,
    bool showLoading = true,
  }) {
    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/stores/search',
        queryParameters: filters ?? {},
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل المتاجر...',
    );
  }

  /// ✅ STORE PRODUCTS - Get products from specific store
  /// Endpoint: GET /products/search?store_id=7&page=2
  static Future<Response> storeProducts({
    required int storeId,
    required int page,
    int perPage = 20,
    String? search,
    bool showLoading = true,
  }) {
    final queryParams = <String, dynamic>{
      'store_id': storeId,
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/products/search',
        queryParameters: queryParams,
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل منتجات المتجر...',
    );
  }

  /// ✅ SEARCH CATEGORIES - For filter dropdowns
  /// Endpoint: GET /admin/categories?type=product
  static Future<Response> getCategories({
    String type = 'product',
    bool showLoading = false,
  }) {
    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/admin/categories',
        queryParameters: {'type': type},
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل التصنيفات...',
    );
  }

  /// ✅ ADMIN COMMENTS FILTER - With date range
  /// Endpoint: GET /admin/abusive-comments?user_id=&date_from=&date_to=&search=
  static Future<Response> adminFilterComments({
    required int page,
    int perPage = 5,
    int? userId,
    String? dateFrom,
    String? dateTo,
    String? search,
    bool showLoading = true,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (userId != null && userId > 0) 'user_id': userId,
      if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/admin/abusive-comments',
        queryParameters: queryParams,
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل التعليقات...',
    );
  }

  /// ✅ ADMIN REQUESTED SERVICES - With filters
  /// Endpoint: GET /admin/requested-services?user_name=&title=
  static Future<Response> adminFilterServices({
    required int page,
    int perPage = 10,
    String? userName,
    String? title,
    bool showLoading = true,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (userName != null && userName.isNotEmpty) 'user_name': userName,
      if (title != null && title.isNotEmpty) 'title': title,
    };

    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/admin/requested-services',
        queryParameters: queryParams,
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل الخدمات...',
    );
  }

  /// ✅ MERCHANT BLOGS FILTER
  /// Endpoint: GET /merchants/blogs?page=1&per_page=10&orderBy=id&orderDir=desc&title=blog
  static Future<Response> merchantBlogs({
    required int page,
    int perPage = 10,
    String orderBy = 'id',
    String orderDir = 'desc',
    String? title,
    bool showLoading = true,
  }) {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'orderBy': orderBy,
      'orderDir': orderDir,
      if (title != null && title.isNotEmpty) 'title': title,
    };

    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/merchants/blogs',
        queryParameters: queryParams,
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل المدونات...',
    );
  }

  /// ✅ Get single product by slug
  /// Endpoint: GET /products/search/:slug
  static Future<Response> getProductBySlug({
    required String slug,
    bool showLoading = true,
  }) {
    return ApiGuard.run(
      () => ApiClient.I.dio.get('/products/search/$slug'),
      showLoading: showLoading,
      loadingText: 'جاري تحميل المنتج...',
    );
  }

  /// ✅ Get single store by slug
  /// Endpoint: GET /stores/:slug
  static Future<Response> getStoreBySlug({
    required String slug,
    bool showLoading = true,
  }) {
    return ApiGuard.run(
      () => ApiClient.I.dio.get('/stores/$slug'),
      showLoading: showLoading,
      loadingText: 'جاري تحميل المتجر...',
    );
  }

  /// ✅ Get user's favorites
  /// Endpoint: GET /favorites?favs_type=store
  /// Requires: Authentication
  static Future<Response> getUserFavorites({
    String favsType = 'product', // store, product, service
    int page = 1,
    int perPage = 20,
    bool showLoading = false,
  }) {
    final queryParams = <String, dynamic>{
      'favs_type': favsType,
      'page': page,
      'per_page': perPage,
    };

    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/favorites',
        queryParameters: queryParams,
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل المفضلات...',
    );
  }

  /// ✅ ADMIN ANALYTICS FILTER
  /// Endpoint: GET /admin/analytics/overview/content?period=current_month
  static Future<Response> adminAnalytics({
    String section = 'content', // content, customers, analytics, latests
    String period = 'current_month', // current_month, last_year, etc
    bool showLoading = true,
  }) {
    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/admin/analytics/overview/$section',
        queryParameters: {'period': period},
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل الإحصائيات...',
    );
  }

  /// ✅ MERCHANT ANALYTICS
  /// Endpoint: GET /merchants/analytics/content?period=last_year
  static Future<Response> merchantAnalytics({
    String section = 'content', // content, analytics, followers, mostViewed
    String period = 'last_year',
    bool showLoading = true,
  }) {
    return ApiGuard.run(
      () => ApiClient.I.dio.get(
        '/merchants/analytics/$section',
        queryParameters: {'period': period},
      ),
      showLoading: showLoading,
      loadingText: 'جاري تحميل البيانات...',
    );
  }
}
