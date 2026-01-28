# 🔧 API Integration Guide - Attene Mobile App

**Last Updated**: January 28, 2026  
**Focus**: Properly linking Filter Code with API Endpoints

---

## 📋 Table of Contents

1. [Current Issues Found](#current-issues-found)
2. [Fixed Implementation](#fixed-implementation)
3. [API Endpoints Mapping](#api-endpoints-mapping)
4. [Integration Checklist](#integration-checklist)
5. [Common Mistakes & Solutions](#common-mistakes--solutions)

---

## ❌ Current Issues Found

### **Issue 1: Incomplete API Routes**
- `lib/api/api_routes.dart` has old endpoints (e.g., `/booking/`, `/branches/`)
- **Missing**: Modern endpoints like `/products/search`, `/stores/search`, `/merchants/*`

### **Issue 2: No Centralized Filter Service**
- Each component makes separate API calls
- No consistent error handling
- Query parameters built ad-hoc without validation

### **Issue 3: Search Screen Not Fully Implemented**
- `SearchScreen` has UI but no filter controller
- No connection to API for real-time filtering
- Hardcoded UI elements instead of dynamic data

### **Issue 4: Product Controller Incomplete**
- `ProductController` doesn't handle all filter parameters
- Missing pagination logic
- No cache management strategy

### **Issue 5: Missing Proper Response Handling**
- No validation of API response structure
- Error messages not user-friendly
- No fallback to cached data on failure

---

## ✅ Fixed Implementation

### **Step 1: Use the New SearchFilterService**

The `search_filter_service.dart` file includes all properly documented API methods:

```dart
// ✅ CORRECT - Using SearchFilterService
final response = await SearchFilterService.searchProducts(
  page: 1,
  search: 'laptop',
  categoryId: 5,
  storeId: 10,
  priceMin: 100,
  priceMax: 5000,
  orderDir: 'desc',
  showLoading: true,
);

if (response.statusCode == 200) {
  final data = response.data['data'] as List;
  final products = data.map((p) => Product.fromJson(p)).toList();
  // Use products...
}
```

### **Step 2: Use ProductFilterController**

The `product_filter_controller.dart` handles all filter state and logic:

```dart
// In your screen/widget
class MySearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductFilterController());
    
    return Column(
      children: [
        // Search input
        Obx(() => TextField(
          onChanged: controller.updateSearchQuery,
        )),
        
        // Apply filters
        ElevatedButton(
          onPressed: controller.applyFilters,
          child: Text('تطبيق الفلاتر'),
        ),
        
        // Results
        Obx(() {
          if (controller.isLoading.value) {
            return CircularProgressIndicator();
          }
          if (controller.filteredProducts.isEmpty) {
            return Text(controller.errorMessage.value.isEmpty 
              ? 'لا توجد نتائج' 
              : controller.errorMessage.value);
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

### **Step 3: Register in AppBindings**

Update `lib/main.dart` to register the filter controller:

```dart
class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiHelper());
    Get.put(ProductFilterController()); // ✅ ADD THIS
    Get.put(DataInitializerService());
    // ... other bindings
  }
}
```

---

## 📡 API Endpoints Mapping

### **Product Search - User View**
```
Endpoint: GET /products/search
Parameters: page, per_page, search, category_id, store_id, price_min, price_max, orderBy, orderDir
Auth: Not required
Use When: Customer browsing products
```

**Example**:
```dart
await SearchFilterService.searchProducts(
  page: 1,
  search: 'phone',
  categoryId: 5,
  orderDir: 'asc',
);
```

---

### **Products - Admin Panel**
```
Endpoint: GET /admin/products
Parameters: page, per_page, section_id, search
Auth: Required (Admin role)
Use When: Admin managing products
```

**Example**:
```dart
await SearchFilterService.adminSearchProducts(
  page: 1,
  sectionId: 3,
  search: 'tablet',
);
```

---

### **Products - Merchant Dashboard**
```
Endpoint: GET /merchants/products
Parameters: search (optional)
Auth: Required (Merchant role)
Use When: Merchant viewing their own products
```

**Example**:
```dart
await SearchFilterService.merchantProducts(
  search: 'inventory',
);
```

---

### **Store Products - Get specific store's products**
```
Endpoint: GET /products/search?store_id=7
Parameters: store_id, page, per_page, search
Auth: Not required
Use When: Viewing products from specific store
```

**Example**:
```dart
await SearchFilterService.storeProducts(
  storeId: 7,
  page: 1,
  search: 'laptop',
);
```

---

### **Stores Search**
```
Endpoint: GET /stores/search
Parameters: filters (dynamic)
Auth: Not required
Use When: Customer searching stores
```

---

### **Comments Filter (Admin)**
```
Endpoint: GET /admin/abusive-comments
Parameters: page, per_page, user_id, date_from, date_to, search
Auth: Required (Admin role)
Use When: Admin reviewing flagged comments
```

**Example**:
```dart
await SearchFilterService.adminFilterComments(
  page: 1,
  userId: 15,
  dateFrom: '2026-01-01',
  dateTo: '2026-01-28',
  search: 'offensive',
);
```

---

### **Analytics - Admin**
```
Endpoint: GET /admin/analytics/overview/{section}
Sections: content, customers, analytics, latests
Parameters: period (current_month, last_year, etc)
Auth: Required (Admin role)
```

---

### **Analytics - Merchant**
```
Endpoint: GET /merchants/analytics/{section}
Sections: content, analytics, followers, mostViewed
Parameters: period
Auth: Required (Merchant role)
```

---

## ✅ Integration Checklist

### **For Search/Filter Features**
- [ ] Import `SearchFilterService`
- [ ] Create filter controller extending `GetxController`
- [ ] Define reactive filter variables (`.obs`)
- [ ] Implement `applyFilters()` method
- [ ] Handle pagination with `loadNextPage()`
- [ ] Add error handling with try-catch
- [ ] Show loading state with `isLoading.value`
- [ ] Display user-friendly error messages
- [ ] Register controller in `AppBindings`
- [ ] Build UI using `Obx()` for reactivity

### **For API Calls**
- [ ] Use `SearchFilterService` methods (don't hardcode endpoints)
- [ ] Pass all relevant filter parameters
- [ ] Check `response.statusCode == 200`
- [ ] Parse `response.data['data']` not just `response.data`
- [ ] Handle `response.data['meta']` for pagination info
- [ ] Catch `DioException` for network errors
- [ ] Show loading with `showLoading: true` for user-initiated actions
- [ ] Use `showLoading: false` for auto-refresh calls

### **For Error Handling**
- [ ] Check response status code
- [ ] Display error messages in Arabic
- [ ] Provide fallback UI (empty state, retry button)
- [ ] Log errors with timestamps for debugging
- [ ] Never leave user without feedback

### **For Pagination**
- [ ] Track `currentPage` and `totalCount`
- [ ] Check `isLastPage` before loading more
- [ ] Append new items (don't replace list)
- [ ] Show loading indicator during pagination
- [ ] Disable pagination button when at last page

---

## 🐛 Common Mistakes & Solutions

### **❌ Mistake 1: Hardcoding API URLs**
```dart
// ❌ WRONG
final response = await dio.get('https://api.example.com/products/search?page=1');
```

**✅ Solution**: Use `SearchFilterService`
```dart
// ✅ CORRECT
final response = await SearchFilterService.searchProducts(page: 1);
```

---

### **❌ Mistake 2: Not Handling Response Structure**
```dart
// ❌ WRONG
final products = response.data; // Could crash!
```

**✅ Solution**: Parse correctly with null safety
```dart
// ✅ CORRECT
final data = response.data['data'] as List? ?? [];
final products = data.map((p) => Product.fromJson(p)).toList();
```

---

### **❌ Mistake 3: Ignoring Status Codes**
```dart
// ❌ WRONG
final response = await dio.get('/products/search');
final products = response.data; // What if 401?
```

**✅ Solution**: Check status before processing
```dart
// ✅ CORRECT
if (response.statusCode == 200) {
  // Process data
} else if (response.statusCode == 401) {
  Get.offAllNamed('/login');
} else {
  showError('فشل: ${response.data['message']}');
}
```

---

### **❌ Mistake 4: Making API Calls in build()**
```dart
// ❌ WRONG
Widget build(BuildContext context) {
  ApiHelper.get('/products'); // Called every rebuild!
  return Container();
}
```

**✅ Solution**: Call in controller, not UI
```dart
// ✅ CORRECT
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    // API call here
  }
}
```

---

### **❌ Mistake 5: Replacing List Instead of Appending**
```dart
// ❌ WRONG - For pagination
filteredProducts.assignAll(newProducts); // Replaces everything!
```

**✅ Solution**: Check if paginating
```dart
// ✅ CORRECT
if (resetPage) {
  filteredProducts.assignAll(products);
} else {
  filteredProducts.addAll(products); // Append for pagination
}
```

---

### **❌ Mistake 6: Missing Required Parameters**
```dart
// ❌ WRONG - 'page' required for pagination
await SearchFilterService.searchProducts(search: 'laptop');
```

**✅ Solution**: Include required parameters
```dart
// ✅ CORRECT
await SearchFilterService.searchProducts(
  page: 1,
  search: 'laptop',
);
```

---

### **❌ Mistake 7: Not Updating After State Change**
```dart
// ❌ WRONG
filter.value = newValue;
// UI might not update!
```

**✅ Solution**: Call update() or use Obx()
```dart
// ✅ CORRECT - Option 1
filter.value = newValue;
update(['filter']);

// ✅ CORRECT - Option 2 (Automatic)
Obx(() => Text(filter.value));
```

---

## 🚀 Quick Start Guide

### **1. Add Search to Home Screen**

```dart
// In your home screen controller
class HomeController extends GetxController {
  final filterController = Get.find<ProductFilterController>();
  
  @override
  void onInit() {
    super.onInit();
    filterController.applyFilters(); // Load initial products
  }
}

// In your home screen widget
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFilterController>();
    
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.filteredProducts.length,
          itemBuilder: (_, i) => ProductCard(
            product: controller.filteredProducts[i],
          ),
        );
      }),
    );
  }
}
```

---

### **2. Add Filter Bottom Sheet**

```dart
class FilterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFilterController>();
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Category filter
          Obx(() => DropdownButton(
            value: controller.selectedCategoryId.value,
            onChanged: (value) => controller.updateCategory(value ?? 0),
            items: [...],
          )),
          
          // Price range
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
            onPressed: () {
              controller.applyFilters();
              Navigator.pop(context);
            },
            child: Text('تطبيق'),
          ),
        ],
      ),
    );
  }
}
```

---

### **3. Add Pagination to List**

```dart
ListView.builder(
  itemCount: controller.filteredProducts.length + 1,
  itemBuilder: (context, index) {
    if (index == controller.filteredProducts.length) {
      if (controller.hasMorePages.value) {
        return Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          return ElevatedButton(
            onPressed: controller.loadNextPage,
            child: Text('تحميل المزيد'),
          );
        });
      }
      return SizedBox.shrink();
    }
    return ProductCard(product: controller.filteredProducts[index]);
  },
)
```

---

## 📞 Support

If you encounter issues:

1. Check that `SearchFilterService` method exists for your use case
2. Verify API endpoint from documentation
3. Check response structure in network tab
4. Ensure authentication headers are included
5. Print debug messages with `print('🔍 [DEBUG] ...')`
6. Check `.github/copilot-instructions.md` for patterns

---

**Status**: ✅ Ready for Implementation  
**Next Steps**: Test each endpoint individually before integrating  
**Questions**: Refer to API documentation or check existing controllers
