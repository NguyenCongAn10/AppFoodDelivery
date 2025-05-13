import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/model/category.dart';
import 'package:delivery_apps/server/firebase_service.dart';
import 'package:flutter/material.dart';

import '../../common/color_extention.dart';

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

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await _firebaseService.getCategories();
      if (mounted) {
        setState(() {
          categories = loadedCategories;
          isLoading = false;
        });
        print('Đã tải ${categories.length} danh mục');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        print('Lỗi tải danh mục: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                      });
                      widget.onCategorySelected(category.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 8, 10, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: currentIndex == index
                            ? TColor.main
                            : Colors.grey[100],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 24,
                              height: 24,
                              color: Colors.white,
                              child: Image.network(
                                category.image,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const CircularProgressIndicator(
                                      strokeWidth: 2);
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                      'Lỗi tải hình ảnh: ${category.image}, $error');
                                  return const Icon(Icons.error, size: 20);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          NormalTextBold(
                            color: currentIndex == index
                                ? Colors.white
                                : Colors.black,
                            txt: category.name,
                            size: 15,
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
