import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/category_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CategoriesSlider extends StatefulWidget {
  final Function(String) onCategorySelected;
  const CategoriesSlider({super.key, required this.onCategorySelected});

  @override
  State<CategoriesSlider> createState() => _CategoriesSliderState();
}

class _CategoriesSliderState extends State<CategoriesSlider> {
  List<CategoryModel> categories = [];
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
      final fetchedCategories = await _backendService.getCategories();
      
      if (mounted) {
        setState(() {
          categories = fetchedCategories;
          isLoading = false;
        });
        if (categories.isNotEmpty) {
          widget.onCategorySelected(categories.first.id.toString());
        }
        if (kDebugMode) debugPrint('Đã tải ${categories.length} danh mục');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        if (kDebugMode) debugPrint('Lỗi tải danh mục: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
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
                          widget.onCategorySelected(category.id.toString());
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 6, right: 14, top: 6, bottom: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: currentIndex == index
                                ? AppColor.primary(context)
                                : AppColor.container(context),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (category.iconUrl != null &&
                                  category.iconUrl!.isNotEmpty)
                                Container(
                                  width: 28,
                                  height: 28,
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: category.iconUrl!,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(
                                              strokeWidth: 2),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error, size: 14),
                                    ),
                                  ),
                                ),
                              if (category.iconUrl != null &&
                                  category.iconUrl!.isNotEmpty)
                                const SizedBox(width: 8),
                              Text(
                                category.name,
                                style: AppTextStyle.bodyBold(context,
                                    fontSize: 15,
                                    color: currentIndex == index
                                        ? Colors.white
                                        : AppColor.textTitle(context)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
