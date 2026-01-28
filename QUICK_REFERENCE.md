# 📋 Quick Reference Guide - Attene API Integration

**Quick links to common tasks**

---

## 🔍 Finding What You Need

### "How do I search for products?"
See: `lib/services/api/search_filter_service.dart`
```dart
await SearchFilterService.searchProducts(
  page: 1,
  search: 'laptop',
  categoryId: 5,
);
```
👉 [Full example](lib/view/search/screen/COMPLETE_SEARCH_EXAMPLES.dart)

---

### "How do I add a filter?"
See: `lib/view/search/controller/product_filter_controller.dart`
```dart
void updateCategory(int categoryId) {
  selectedCategoryId.value = categoryId;
  applyFilters();
}
```
👉 [Implementation guide](API_INTEGRATION_GUIDE.md#step-1-use-the-new-searchfilterservice)

---

### "How do I handle pagination?"
```dart
// In controller
Future<void> loadNextPage() async {
  if (isLoading.value || isLastPage) return;
  currentPage.value++;
  await applyFilters(resetPage: false);
}

// In UI
ElevatedButton(
  onPressed: controller.loadNextPage,
  child: Text('تحميل المزيد'),
)
```
👉 [Complete example](lib/view/search/screen/COMPLETE_SEARCH_EXAMPLES.dart#L93)

---

### "How do I show errors?"
```dart
// Automatically handled, just observe:
Obx(() => Text(controller.errorMessage.value))
```
👉 [Error handling](API_INTEGRATION_GUIDE.md#error-handling)

---

### "How do I make an admin API call?"
```dart
await SearchFilterService.adminSearchProducts(
  page: 1,
  sectionId: 3,
);
```
👉 [Admin endpoints](lib/services/api/search_filter_service.dart#L60)

---

### "How do I make a merchant API call?"
```dart
await SearchFilterService.merchantProducts(
  search: 'query',
);
```
👉 [Merchant endpoints](lib/services/api/search_filter_service.dart#L80)

---

## 📱 Common UI Patterns

### Search with live filtering
```dart
Obx(() => TextField(
  onChanged: controller.updateSearchQuery,
))
```

### Filter dropdown
```dart
Obx(() => DropdownButton<int>(
  value: controller.selectedCategoryId.value,
  onChanged: (value) => controller.updateCategory(value ?? 0),
))
```

### Price range slider
```dart
Obx(() => RangeSlider(
  values: RangeValues(
    controller.minPrice.value,
    controller.maxPrice.value,
  ),
  onChanged: (range) => controller.updatePriceRange(
    range.start,
    range.end,
  ),
))
```

### List with pagination
```dart
Obx(() => ListView.builder(
  itemCount: controller.filteredProducts.length + 1,
  itemBuilder: (_, i) {
    if (i == controller.filteredProducts.length) {
      return controller.isLastPage 
        ? SizedBox.shrink()
        : ElevatedButton(
            onPressed: controller.loadNextPage,
            child: Text('تحميل المزيد'),
          );
    }
    return ProductCard(product: controller.filteredProducts[i]);
  },
))
```

---

## 🔗 API Endpoints Quick Reference

| Feature | Endpoint | Method |
|---------|----------|--------|
| Search products | `/products/search` | GET |
| Admin products | `/admin/products` | GET |
| Merchant products | `/merchants/products` | GET |
| Store products | `/products/search?store_id=X` | GET |
| Search stores | `/stores/search` | GET |
| Single product | `/products/search/:slug` | GET |
| Single store | `/stores/:slug` | GET |
| User favorites | `/favorites` | GET |
| Admin comments | `/admin/abusive-comments` | GET |
| Merchant blogs | `/merchants/blogs` | GET |
| Admin analytics | `/admin/analytics/overview/:section` | GET |
| Merchant analytics | `/merchants/analytics/:section` | GET |

👉 [Full API documentation](API_INTEGRATION_GUIDE.md#-api-endpoints-mapping)

---

## 🚨 Common Mistakes

### ❌ Hardcoding URLs
```dart
// WRONG ❌
final response = await dio.get('/products/search?page=1');
```
**Fix**: Use `SearchFilterService`

### ❌ Ignoring status codes
```dart
// WRONG ❌
final products = response.data['data'];
```
**Fix**: Check `response.statusCode == 200` first

### ❌ API calls in build()
```dart
// WRONG ❌
Widget build(BuildContext context) {
  ApiHelper.get('/products');
}
```
**Fix**: Call in controller `onInit()`

### ❌ Not using Obx() for updates
```dart
// WRONG ❌
filter.value = newValue;
// UI won't update!
```
**Fix**: Use `Obx(() => ...)`

👉 [More examples](API_INTEGRATION_GUIDE.md#-common-mistakes--solutions)

---

## 🛠️ Setup Checklist

- [ ] Copy `search_filter_service.dart` to `lib/services/api/`
- [ ] Copy `product_filter_controller.dart` to `lib/view/search/controller/`
- [ ] Add `Get.put(ProductFilterController());` to `AppBindings`
- [ ] Test each endpoint individually
- [ ] Implement UI screens using examples
- [ ] Add error handling
- [ ] Test pagination
- [ ] Test all filters
- [ ] Performance test
- [ ] User acceptance testing

---

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| `.github/copilot-instructions.md` | AI agent guide with architecture |
| `API_INTEGRATION_GUIDE.md` | Detailed implementation guide |
| `IMPLEMENTATION_SUMMARY.md` | What was fixed and how |
| `COMPLETE_SEARCH_EXAMPLES.dart` | Working code examples |
| This file | Quick reference |

---

## 🧪 Testing an Endpoint

```dart
// 1. Import service
import 'package:attene_mobile/services/api/search_filter_service.dart';

// 2. Make call
final response = await SearchFilterService.searchProducts(
  page: 1,
  search: 'test',
);

// 3. Check response
if (response.statusCode == 200) {
  print('✅ Success');
  print('Data: ${response.data}');
} else {
  print('❌ Error: ${response.statusCode}');
  print('Message: ${response.data['message']}');
}
```

---

## 💡 Pro Tips

1. **Use `showLoading: false`** for auto-refresh calls
2. **Use `showLoading: true`** for user-initiated actions
3. **Always check `response.statusCode`** before processing
4. **Use `Obx()`** for reactive UI updates
5. **Call `applyFilters(resetPage: false)`** for pagination
6. **Call `applyFilters(resetPage: true)`** for new filters
7. **Test with print()** statements for debugging
8. **Use named parameters** for clarity

---

## 🔐 Authentication Note

All endpoints except public ones require:
```dart
Authorization: Bearer {token}
```

The `ApiGuard` and `ApiClient` handle this automatically. No manual header setup needed!

---

## 📞 Need Help?

1. Check `.github/copilot-instructions.md` for patterns
2. Review `API_INTEGRATION_GUIDE.md` for implementation
3. Look at `COMPLETE_SEARCH_EXAMPLES.dart` for working code
4. Search your API documentation for endpoint details
5. Debug with print() statements

---

## 🎯 Integration Checklist (Quick)

```dart
// 1. Register controller
class AppBindings extends Bindings {
  void dependencies() {
    Get.put(ProductFilterController());
  }
}

// 2. Use in screen
final controller = Get.find<ProductFilterController>();

// 3. Build UI
Obx(() => ListView(children: [...]))

// 4. Handle filters
controller.updateSearchQuery('test');
controller.updateCategory(5);
controller.loadNextPage();

// 5. Show results
controller.filteredProducts // Use this list
```

---

**Version**: 1.0  
**Last Updated**: January 28, 2026  
**Status**: ✅ Ready to Use
