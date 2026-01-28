import 'package:attene_mobile/general_index.dart';
import 'package:attene_mobile/view/search/controller/product_filter_controller.dart';
import 'package:attene_mobile/component/product_card.dart';

/// ✅ EXAMPLE 1: Complete Search Screen with Filters
/// Shows proper API integration, error handling, and pagination
class CompleteSearchScreen extends StatelessWidget {
  const CompleteSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the filter controller (must be registered in AppBindings)
    final controller = Get.find<ProductFilterController>();

    return Scaffold(
      appBar: AppBar(title: Text('البحث عن المنتجات')),
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            children: [
              // ============ SEARCH & FILTER BAR ============
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  spacing: 12,
                  children: [
                    // Search field
                    TextField(
                      onChanged: controller.updateSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن منتج...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    // Filter row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showFilterBottomSheet(context, controller),
                            icon: Icon(Icons.filter_list),
                            label: Text('الفلاتر'),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: controller.hasActiveFilters
                              ? controller.clearAllFilters
                              : null,
                          child: Text('مسح الفلاتر'),
                        ),
                      ],
                    ),

                    // Filter summary
                    if (controller.hasActiveFilters)
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          controller.getFilterSummary(),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),

              // ============ LOADING STATE ============
              if (controller.isLoading.value && controller.filteredProducts.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ),

              // ============ ERROR STATE ============
              if (controller.errorMessage.value.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: controller.applyFilters,
                        child: Text('حاول مجددا'),
                      ),
                    ],
                  ),
                ),

              // ============ EMPTY STATE ============
              if (controller.filteredProducts.isEmpty &&
                  !controller.isLoading.value &&
                  controller.errorMessage.value.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.search, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا توجد نتائج'),
                      Text(
                        'حاول تعديل الفلاتر',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

              // ============ PRODUCTS LIST ============
              if (controller.filteredProducts.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredProducts.length + 1,
                  itemBuilder: (context, index) {
                    // Last item: pagination button
                    if (index == controller.filteredProducts.length) {
                      if (!controller.isLastPage) {
                        return Padding(
                          padding: EdgeInsets.all(16),
                          child: controller.isLoading.value
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: controller.loadNextPage,
                                  child: Text('تحميل المزيد'),
                                ),
                        );
                      }
                      return SizedBox.shrink();
                    }

                    // Product item
                    return ProductCard(
                      product: controller.filteredProducts[index],
                    );
                  },
                ),

              // ============ PAGINATION INFO ============
              if (controller.filteredProducts.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'عرض ${controller.filteredProducts.length} من ${controller.totalCount.value}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  /// ✅ Filter bottom sheet
  void _showFilterBottomSheet(
    BuildContext context,
    ProductFilterController controller,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheetContent(controller: controller),
    );
  }
}

/// ✅ EXAMPLE 2: Filter Bottom Sheet
class FilterBottomSheetContent extends StatelessWidget {
  final ProductFilterController controller;

  const FilterBottomSheetContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'الفلاتر',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: Navigator.of(context).pop,
                    icon: Icon(Icons.close),
                  ),
                ],
              ),

              Divider(),

              // Category filter
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('التصنيف'),
                  SizedBox(height: 8),
                  DropdownButton<int>(
                    isExpanded: true,
                    value: controller.selectedCategoryId.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateCategory(value);
                      }
                    },
                    items: [
                      DropdownMenuItem(value: 0, child: Text('كل التصنيفات')),
                      DropdownMenuItem(value: 1, child: Text('الإلكترونيات')),
                      DropdownMenuItem(value: 2, child: Text('الملابس')),
                      DropdownMenuItem(value: 3, child: Text('الكتب')),
                    ],
                  ),
                ],
              ),

              // Store filter
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المتجر'),
                  SizedBox(height: 8),
                  DropdownButton<int>(
                    isExpanded: true,
                    value: controller.selectedStoreId.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateStore(value);
                      }
                    },
                    items: [
                      DropdownMenuItem(value: 0, child: Text('جميع المتاجر')),
                      DropdownMenuItem(value: 1, child: Text('متجر أ')),
                      DropdownMenuItem(value: 2, child: Text('متجر ب')),
                    ],
                  ),
                ],
              ),

              // Price range
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('نطاق السعر'),
                  SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(
                      controller.minPrice.value,
                      controller.maxPrice.value,
                    ),
                    min: 0,
                    max: 10000,
                    onChanged: (values) {
                      controller.updatePriceRange(values.start, values.end);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.minPrice.value.toStringAsFixed(2)} د.أ',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${controller.maxPrice.value.toStringAsFixed(2)} د.أ',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              // Sort option
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الترتيب'),
                  SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: controller.sortBy.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateSort(value);
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'newest',
                        child: Text('الأحدث'),
                      ),
                      DropdownMenuItem(
                        value: 'popular',
                        child: Text('الأكثر شهرة'),
                      ),
                      DropdownMenuItem(
                        value: 'price_low',
                        child: Text('السعر: الأقل أولا'),
                      ),
                      DropdownMenuItem(
                        value: 'price_high',
                        child: Text('السعر: الأعلى أولا'),
                      ),
                    ],
                  ),
                ],
              ),

              Divider(),

              // Apply button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyFilters();
                        Navigator.pop(context);
                      },
                      child: Text('تطبيق الفلاتر'),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}

/// ✅ EXAMPLE 3: Admin Products Filter Screen
class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductFilterController());

    return Scaffold(
      appBar: AppBar(title: Text('إدارة المنتجات')),
      body: Obx(() => Column(
            children: [
              // Admin-specific filters
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  spacing: 8,
                  children: [
                    // Section filter (Admin only)
                    TextField(
                      onChanged: (value) {
                        // This would need a custom method
                        controller.updateSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'البحث في المنتجات',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: controller.applyFilters,
                          child: Text('بحث'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: controller.filteredProducts.length,
                        itemBuilder: (_, i) => AdminProductTile(
                          product: controller.filteredProducts[i],
                        ),
                      ),
              ),
            ],
          )),
    );
  }
}

/// Placeholder for admin product tile
class AdminProductTile extends StatelessWidget {
  final Product product;

  const AdminProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text('${product.price} د.أ'),
      trailing: PopupMenuButton(
        itemBuilder: (_) => [
          PopupMenuItem(child: Text('تعديل')),
          PopupMenuItem(child: Text('حذف')),
        ],
      ),
    );
  }
}

// Placeholder Product class for compilation
class Product {
  final int id;
  final String name;
  final String slug;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
