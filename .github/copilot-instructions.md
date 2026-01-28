# Attene Mobile App - AI Coding Agent Instructions

**Last Updated**: January 28, 2026  
**Project Type**: Flutter Cross-Platform Mobile App (iOS, Android, Web, Desktop)  
**Architecture**: MVVM + GetX State Management + RESTful API

---

## 🎯 Project Overview

Attene is a comprehensive **multi-role marketplace platform** with three main user types:

- **Admin**: System management, content moderation, analytics
- **Merchant**: Store/product/service management, analytics
- **Customer**: Product search, shopping, chat, favorites, reviews

### Key Features
- Multi-vendor marketplace with products & services
- Real-time chat system
- User favorites & product comparison
- Admin dashboard with reporting & analytics
- Merchant analytics & coin-based system
- Media management (images/galleries)
- Role-based notifications
- Multi-language support (Arabic/English)

---

## 🏗️ Architecture & Critical Patterns

### 1. **State Management: GetX**
- Controllers extend `GetxController`
- Use `.obs` reactive variables (`.value` for single, `.assignAll()` for lists)
- Update UI with `update(['tag'])` or `Obx(() => ...)`
- Service locator: `Get.find<ServiceClass>()`

**Example**:
```dart
class ProductController extends GetxController {
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  
  void loadProducts() {
    isLoading.value = true;
    // API call...
    products.assignAll(data);
    update(['products']);
  }
}
```

### 2. **API Integration Pattern**
All API calls use `ApiHelper` and `ApiGuard`:

```dart
// ✅ CORRECT PATTERN
final response = await ApiHelper.get(
  path: '/products/search',
  queryParameters: {'page': 1, 'search': 'keyword'},
  withLoading: true,
  shouldShowMessage: true,
);

if (response?.statusCode == 200) {
  final data = response.data;
  // Process data
}
```

**API Base Structure**:
- Base URL: Set in `ApiClient` configuration
- All endpoints require `Authorization: Bearer {token}` header (except public endpoints)
- Responses follow standard format:
  ```json
  { "status": true|false, "message": "...", "data": {} }
  ```

### 3. **Authentication & Role-Based Access**
- **Login endpoint**: `POST /auth/login` → Returns Bearer token
- **Token storage**: Stored in `GetStorage` (secure local storage)
- **Middleware**: `AuthGuardMiddleware` protects routes
- **Role check**: User role determines available endpoints

**Endpoints by role**:
- Admin: `/admin/*`
- Merchant: `/merchants/*`
- User: Regular paths (products, stores, profile)

### 4. **Data Models & JSON Serialization**
Models use Dart `json_serializable` package:

```dart
@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String slug;
  final double price;
  final List<String> images;
  final int storeId;
  final bool isActive;

  Product({...});

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
```

### 5. **Service Locator Pattern**
Services registered in `AppBindings` for dependency injection:

```dart
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiHelper());
    Get.put(DataInitializerService());
    Get.put(ProductService());
  }
}
```

---

## 🔗 Filter & Search Integration Pattern

### File Structure
```
lib/
├── api/
│   ├── api_routes.dart         # API endpoint constants
│   ├── api_request.dart        # Request/response models
│   └── core/api_helper.dart    # HTTP client wrapper
├── services/api/
│   ├── home_service.dart       # Product/store search
│   └── api_guard.dart          # Response handling
├── view/search/
│   ├── controller/search_controller.dart
│   ├── screen/search_screen.dart
│   └── widget/
├── models/
│   ├── product.dart
│   ├── store.dart
│   └── service.dart
└── view/products/
    ├── controller/product_controller.dart
    └── screen/products_screen.dart
```

### Filter Code Integration Steps

**1. Define Filter State in Controller**:
```dart
class ProductFilterController extends GetxController {
  // Filter variables
  final RxString searchQuery = ''.obs;
  final RxInt selectedCategoryId = 0.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 10000.0.obs;
  final RxInt selectedStoreId = 0.obs;
  final RxString sortBy = 'newest'.obs; // newest, popular, price_low, price_high
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool isLoading = false.obs;
  
  // Results
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxInt totalCount = 0.obs;
  
  // Fetch products with current filters
  Future<void> applyFilters() async {
    isLoading.value = true;
    currentPage.value = 1;
    
    try {
      final filters = {
        'page': currentPage.value,
        'per_page': 20,
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        if (selectedCategoryId.value > 0) 'category_id': selectedCategoryId.value,
        if (selectedStoreId.value > 0) 'store_id': selectedStoreId.value,
        if (minPrice.value > 0) 'price_min': minPrice.value,
        if (maxPrice.value < 10000) 'price_max': maxPrice.value,
        'orderBy': 'id',
        'orderDir': sortBy.value == 'newest' ? 'desc' : 'asc',
      };
      
      final response = await HomeService.searchProducts(filters: filters);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final products = data
            .map((p) => Product.fromJson(p))
            .toList();
        filteredProducts.assignAll(products);
        totalCount.value = response.data['meta']?['total'] ?? 0;
      }
    } catch (e) {
      print('❌ Filter error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Update filters and reapply
  void updateSearchQuery(String value) {
    searchQuery.value = value;
    applyFilters();
  }
  
  void updateCategory(int categoryId) {
    selectedCategoryId.value = categoryId;
    applyFilters();
  }
  
  void updatePriceRange(double min, double max) {
    minPrice.value = min;
    maxPrice.value = max;
    applyFilters();
  }
  
  void loadNextPage() {
    currentPage.value++;
    applyFilters();
  }
}
```

**2. Build Filter UI with Controller**:
```dart
class ProductFilterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFilterController>();
    
    return Column(
      children: [
        // Search input
        Obx(() => TextFiledAatene(
          hintText: 'ابحث عن منتج',
          onChanged: controller.updateSearchQuery,
        )),
        
        // Category filter
        Obx(() => DropdownButton<int>(
          value: controller.selectedCategoryId.value,
          onChanged: (id) => controller.updateCategory(id ?? 0),
          items: [...],
        )),
        
        // Price range slider
        Obx(() => RangeSlider(
          values: RangeValues(
            controller.minPrice.value,
            controller.maxPrice.value,
          ),
          onChanged: (range) => controller.updatePriceRange(
            range.start,
            range.end,
          ),
        )),
        
        // Apply button
        ElevatedButton(
          onPressed: controller.applyFilters,
          child: Text('تطبيق الفلاتر'),
        ),
        
        // Results
        Obx(() {
          if (controller.isLoading.value) {
            return CircularProgressIndicator();
          }
          return ListView.builder(
            itemCount: controller.filteredProducts.length,
            itemBuilder: (_, i) => ProductCard(
              product: controller.filteredProducts[i],
            ),
          );
        }),
      ],
    );
  }
}
```

---

## 📡 Key API Endpoints (From Your API Docs)

### **Public Endpoints** (No Auth Required)
- `GET /pages/home` - Home page content
- `GET /products/search?page=1&search=&category_id=&store_id=` - Search products
- `GET /stores/:slug` - Store details
- `GET /products/search/:slug` - Product details
- `GET /reviews/product/:slug` - Product reviews

### **Authenticated Endpoints** (User Token Required)
- `POST /auth/login` - Get auth token
- `GET /auth/account` - Current user profile
- `GET /favorites?favs_type=product` - User favorites
- `POST /favorites/add` - Add to favorites
- `GET /followings` - User followings
- `POST /followings/follow` - Follow store/user

### **Admin Endpoints** (`/admin/*`)
- `GET /admin/products?page=1&per_page=10&section_id=3`
- `GET /admin/abusive-comments?user_id=&date_from=&date_to=`
- `POST /admin/notifications/send` - Send notifications
- `GET /admin/analytics/overview/content?period=current_month`

### **Merchant Endpoints** (`/merchants/*`)
- `GET /merchants/products` - Merchant's products
- `GET /merchants/orders` - Merchant's orders
- `GET /merchants/analytics/content?period=last_year`
- `POST /merchants/blogs` - Create blog

---

## 🛠️ Common Developer Workflows

### **Adding a New Filter Feature**
1. Add reactive variable to controller: `final RxString filterValue = ''.obs;`
2. Create filter update method: `void updateFilter(String value) { filterValue.value = value; applyFilters(); }`
3. Add to API query parameters in `applyFilters()`
4. Build UI widget with `Obx(() => ...)`
5. Test with mock data first, then real API

### **Fixing API Integration Errors**

**Error: 401 Unauthorized**
- Check token exists in storage: `final token = GetStorage().read('auth_token');`
- Verify token in request header: `Authorization: Bearer $token`
- Relogin if expired: `await AuthController.logout();`

**Error: 422 Validation**
- Check query parameter names match API docs exactly
- Validate data types (int vs string)
- Ensure required fields are provided

**Error: 404 Not Found**
- Verify endpoint path matches API documentation
- Check base URL configuration in `ApiClient`
- Verify request method (GET vs POST) is correct

### **Caching Strategy**
Use `GetStorage` for local persistence:
```dart
final storage = GetStorage();
// Save
storage.write('products', jsonEncode(products));
// Read
final cached = storage.read('products');
final products = List.from(jsonDecode(cached ?? '[]'));
```

---

## 🎨 UI/UX Component Library

Key reusable components found in codebase:
- `TextFiledAatene` - Custom text input with RTL support
- `AateneButton` - Primary/secondary button styles
- `ProductCard` - Product display card
- `AppBar` - Custom app bar with localization
- `BottomNavigationBar` - Navigation bar

**RTL Support Pattern**:
```dart
final isRTL = LanguageUtils.isRTL;
// Use with Padding, Row, Column for proper RTL/LTR alignment
```

---

## 📋 Naming Conventions

- **Files**: `snake_case.dart` (e.g., `product_controller.dart`)
- **Classes**: `PascalCase` (e.g., `ProductController`)
- **Variables**: `camelCase` (e.g., `productList`)
- **Constants**: `CONSTANT_CASE` or `camelCase` for API routes
- **Reactive vars**: Prefix with context (e.g., `_isLoading`, `_products`)
- **Imports**: Use barrel files `import 'index.dart'`

---

## 🔍 File Structure Best Practices

```dart
// 1. Imports (sorted: dart, packages, local)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../general_index.dart';

// 2. Constants at top
const Duration _animationDuration = Duration(milliseconds: 300);

// 3. Class/Function declaration
class MyController extends GetxController {
  // 3.1 Properties (private first, public after)
  final _privateVar = ''.obs;
  final publicVar = ''.obs;
  
  // 3.2 Getters
  String get formattedValue => ...
  
  // 3.3 Lifecycle methods
  @override
  void onInit() { super.onInit(); }
  
  // 3.4 Public methods
  void updateValue() { }
  
  // 3.5 Private methods
  void _internalLogic() { }
}
```

---

## 🚨 Common Pitfalls to Avoid

❌ **DON'T**:
- Use `GetX` without proper controller registration
- Make API calls in `build()` method
- Forget `update(['tag'])` after state change
- Mix stateful/stateless widgets with `Obx()`
- Hardcode API URLs (use constants from `api_routes.dart`)
- Ignore response status codes (always check `statusCode == 200`)

✅ **DO**:
- Register controllers in `AppBindings`
- Use `GetX` controllers for state management
- Call APIs in controller methods, not UI
- Test filter logic with print statements first
- Use environment variables for API configuration
- Handle errors gracefully with user messages

---

## 📚 Essential Files Reference

| File | Purpose |
|------|---------|
| [lib/api/api_routes.dart](lib/api/api_routes.dart) | API endpoint constants |
| [lib/api/core/api_helper.dart](lib/api/core/api_helper.dart) | HTTP client wrapper |
| [lib/services/api/home_service.dart](lib/services/api/home_service.dart) | Product search API |
| [lib/view/search/controller/search_controller.dart](lib/view/search/controller/search_controller.dart) | Search logic |
| [lib/view/products/controller/product_controller.dart](lib/view/products/controller/product_controller.dart) | Product filtering |
| [lib/models/product.dart](lib/models/product.dart) | Product data model |
| [lib/main.dart](lib/main.dart) | App entry point & bindings |

---

## 🔗 Related Documentation

- **API Documentation**: See `/API_DOCS.md` (12 collections with full endpoints)
- **GetX Documentation**: https://github.com/jonataslaw/getx
- **Dart/Flutter**: https://flutter.dev/docs

---

## 💡 Code Examples

### Example 1: Complete Filter Implementation
[See detailed example in FILTER_IMPLEMENTATION.md - create this file after]

### Example 2: API Error Handling
```dart
try {
  final response = await ApiHelper.get(path: '/products/search');
  if (response.statusCode == 200) {
    // Success
  } else if (response.statusCode == 401) {
    Get.offAllNamed('/login');
  } else if (response.statusCode == 422) {
    // Validation error
    showValidationError(response.data['errors']);
  }
} on DioException catch (e) {
  print('❌ Network error: ${e.message}');
  showErrorDialog('فشل الاتصال بالخادم');
}
```

---

**Version**: 1.0  
**Last Updated By**: AI Coding Agent  
**Next Review**: When API structure changes or new features added
