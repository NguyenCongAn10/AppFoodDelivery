import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/big_text.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/model/product.dart';
import 'package:delivery_apps/server/firebase_service.dart';
import 'package:delivery_apps/view/home/categories_slider.dart';
import 'package:flutter/material.dart';

class ProductHome extends StatefulWidget {
  const ProductHome({super.key});

  @override
  State<ProductHome> createState() => _ProductHomeState();
}

class _ProductHomeState extends State<ProductHome> {
  @override
  Widget build(BuildContext context) {
    FirebaseService _firebaseService = FirebaseService();
    List<Product> products = [];
    String selectedCategory = "cat1";
    var media = MediaQuery.of(context).size;

    Future<void> _loadProducts() async {
      print("Đang tải sản phẩm cho danh mục: $selectedCategory");
      try {
        final loadedProducts =
            await _firebaseService.getProductByCategory(selectedCategory);
        print("Số sản phẩm tải được: ${loadedProducts.length}");
        setState(() {
          products = loadedProducts;
        });
      } catch (e) {
        print("Lỗi khi tải sản phẩm: $e");
        setState(() {
          products = [];
        });
      }
    }

    @override
    void initState() {
      super.initState();
      _loadProducts();
    }

    void _onCategorySelected(String categoryId) {
      setState(() {
        selectedCategory = categoryId;
      });
      _loadProducts();
    }

    return Column(children: [
      CategoriesSlider(onCategorySlected: _onCategorySelected),
      SizedBox(
        height: 20,
      ),
      Row(
        children: [
          NormalTextBold(color: TColor.primary, txt: "Top Picks"),
          Spacer(),
          IconButton(
              onPressed: () {}, icon: Icon(Icons.arrow_forward_ios_rounded))
        ],
      ),
      products.isEmpty
          ? Center(
              child:
                  NormalText(color: Colors.red, txt: "Khong co san pham nao"),
            )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 8),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Card(
                    color: Colors.grey[200],
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [Container()],
                      ),
                    ));
              },
            )
    ]);
  }
}
