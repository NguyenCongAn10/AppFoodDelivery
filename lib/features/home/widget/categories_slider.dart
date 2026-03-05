import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/category.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/material.dart';

class CategoriesSlider extends StatefulWidget {
  final Function(String) onCategorySelected;
  const CategoriesSlider({super.key, required this.onCategorySelected});

  @override
  State<CategoriesSlider> createState() => _CategoriesSliderState();
}

class _CategoriesSliderState extends State<CategoriesSlider> {
  List<Category> categories = [];
  int currentIndex = 0;
  bool isLoading = true;

  final BackendService _backendService = BackendService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final foods = await _backendService.getFoods();
      // Derive unique categories from foods list
      final seen = <String>{};
      final derived = <Category>[];
      for (final f in foods) {
        final catId = f.restaurantId.toString();
        if (seen.add(catId)) {
          derived.add(Category(id: catId, name: 'Restaurant $catId', image: ''));
        }
      }
      if (mounted) {
        setState(() {
          categories = derived;
          isLoading = false;
        });
        debugPrint('Đã tải ${categories.length} danh mục');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        debugPrint('Lỗi tải danh mục: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => currentIndex = index);
                          widget.onCategorySelected(category.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: currentIndex == index
                                ? AppColor.primary(context)
                                : Colors.grey[100],
                          ),
                          child: Text(
                            category.name,
                            style: AppTextStyle.bodyBold(context,
                                fontSize: 15,
                                color: currentIndex == index
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
