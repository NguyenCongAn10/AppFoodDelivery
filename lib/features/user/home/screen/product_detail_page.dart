import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/widgets/top_background_clipper.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/features/user/cart/provider/cart_provider.dart';
import 'package:delivery_apps/features/user/favorites/provider/favorite_provider.dart';
import 'package:delivery_apps/features/user/home/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailPage extends StatefulWidget {
  final FoodModel food;

  const ProductDetailPage({
    super.key,
    required this.food,
  });

  @override
  State<ProductDetailPage> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductDetailPage> {
  int itemCount = 1;
  final Map<int, int> _selectedSingleOptions = {};
  final Map<int, Set<int>> _selectedMultipleOptions = {};

  @override
  void initState() {
    super.initState();
    // Initialize required single-selection groups with the first option
    for (var group in widget.food.optionGroups) {
      if (group.selectionType == 'SINGLE' && group.options.isNotEmpty) {
        _selectedSingleOptions[group.id] = group.options.first.id;
      }
    }
  }

  double get totalPrice {
    double optionsPrice = 0.0;
    for (var group in widget.food.optionGroups) {
      if (group.selectionType == 'SINGLE') {
        final selectedId = _selectedSingleOptions[group.id];
        if (selectedId != null) {
          final option = group.options.firstWhere((o) => o.id == selectedId);
          optionsPrice += option.price;
        }
      } else {
        final selectedIds = _selectedMultipleOptions[group.id] ?? {};
        for (var id in selectedIds) {
          final option = group.options.firstWhere((o) => o.id == id);
          optionsPrice += option.price;
        }
      }
    }
    return (widget.food.price + optionsPrice) * itemCount;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                automaticallyImplyLeading: false,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: RoundIconCircle(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppColor.textTitle(context)),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  Consumer<FavoriteProvider>(
                    builder: (context, favoriteProvider, child) {
                      final isLiked =
                          favoriteProvider.isFavorite(widget.food.id);
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: RoundIconCircle(
                          icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isLiked
                                  ? Colors.red
                                  : AppColor.textSecondary(context)),
                          onTap: () {
                            favoriteProvider.toggleFavorite(widget.food);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: RoundIconCircle(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MainScreen(initialIndex: 1))),
                      icon: Icon(Icons.shopping_cart_outlined,
                          size: 18, color: AppColor.textTitle(context)),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      ClipPath(
                        clipper: TopBackgroundClipper(),
                        child: Container(
                          height: 300,
                          color: AppColor.primary(context),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: widget.food.imageUrl != null &&
                                      widget.food.imageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: widget.food.imageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.fastfood,
                                            size: 80),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey.shade200,
                                      child:
                                          const Icon(Icons.fastfood, size: 80),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.food.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.bodyBold(context,
                                  fontSize: 25,
                                  color: AppColor.textTitle(context)),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColor.primary(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (itemCount > 1)
                                        setState(() => itemCount--);
                                    },
                                    child: const Icon(Icons.remove,
                                        color: Colors.white),
                                  ),
                                  const Spacer(),
                                  Text("$itemCount",
                                      style: AppTextStyle.body(context,
                                          color: Colors.white)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => setState(() => itemCount++),
                                    child: const Icon(Icons.add,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("Description",
                          style: AppTextStyle.bodyBold(context,
                              color: AppColor.textTitle(context))),
                      const SizedBox(height: 8),
                      Text(widget.food.description ?? '',
                          style: AppTextStyle.body(context)),
                      const SizedBox(height: 20),
                      ...widget.food.optionGroups.map((group) {
                        if (group.selectionType == 'SINGLE') {
                          return _buildSingleSelectionGroup(group);
                        } else {
                          return _buildMultipleSelectionGroup(group);
                        }
                      }),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 10,
            right: 10,
            child: Consumer<CartProvider>(builder: (context, cart, child) {
              return Container(
                height: media.height * 0.07,
                padding: const EdgeInsets.only(left: 20, right: 10),
                decoration: BoxDecoration(
                  color: AppColor.primary(context),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text("\$${totalPrice.toStringAsFixed(2)}",
                        style: AppTextStyle.bodyBold(context,
                            fontSize: 20, color: Colors.white)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final List<FoodOptionModel> selectedOptions = [];
                          for (var group in widget.food.optionGroups) {
                            if (group.selectionType == 'SINGLE') {
                              final id = _selectedSingleOptions[group.id];
                              if (id != null) {
                                selectedOptions.add(group.options
                                    .firstWhere((o) => o.id == id));
                              }
                            } else {
                              final ids =
                                  _selectedMultipleOptions[group.id] ?? {};
                              for (var id in ids) {
                                selectedOptions.add(group.options
                                    .firstWhere((o) => o.id == id));
                              }
                            }
                          }

                          await cart.addFood(
                              widget.food, widget.food.restaurantId,
                              quantity: itemCount,
                              selectedOptions: selectedOptions);

                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColor.container(context),
                              title: Text(
                                "Added to cart",
                                style: AppTextStyle.body(context,
                                    color: AppColor.textTitle(context)),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pushReplacement(
                                      ctx,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              MainScreen(initialIndex: 1))),
                                  child: Text("Go to cart",
                                      style: AppTextStyle.bodyBold(context,
                                          color: AppColor.primary(context))),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text("Ok",
                                      style: AppTextStyle.bodyBold(context,
                                          color: AppColor.primary(context))),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 140,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppColor.container(context),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text("Add to cart",
                            style: AppTextStyle.bodyBold(context,
                                fontSize: 16,
                                color: AppColor.textTitle(context))),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSelectionGroup(FoodOptionGroupModel group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(group.name,
            style: AppTextStyle.bodyBold(context,
                fontSize: 18, color: AppColor.textTitle(context))),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: group.options.length,
            itemBuilder: (context, index) {
              final option = group.options[index];
              final isSelected = _selectedSingleOptions[group.id] == option.id;
              return GestureDetector(
                onTap: () => setState(
                    () => _selectedSingleOptions[group.id] = option.id),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColor.primary(context).withOpacity(0.1)
                        : AppColor.container(context),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected
                          ? AppColor.primary(context)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(option.name,
                          style: AppTextStyle.bodyBold(context,
                              color: isSelected
                                  ? AppColor.primary(context)
                                  : AppColor.textTitle(context))),
                      if (option.description != null)
                        Text(option.description!,
                            style: AppTextStyle.body(context,
                                fontSize: 12,
                                color: AppColor.textSecondary(context))),
                      if (option.price > 0)
                        Text("+\$${option.price}",
                            style: AppTextStyle.body(context,
                                fontSize: 12,
                                color: AppColor.primary(context))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleSelectionGroup(FoodOptionGroupModel group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(group.name,
            style: AppTextStyle.bodyBold(context,
                fontSize: 18, color: AppColor.textTitle(context))),
        const SizedBox(height: 12),
        ...group.options.map((option) {
          final isSelected =
              _selectedMultipleOptions[group.id]?.contains(option.id) ?? false;
          return GestureDetector(
            onTap: () {
              setState(() {
                final set = _selectedMultipleOptions[group.id] ?? {};
                if (isSelected) {
                  set.remove(option.id);
                } else {
                  set.add(option.id);
                }
                _selectedMultipleOptions[group.id] = set;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.container(context),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.primary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: (option.imageUrl != null &&
                              option.imageUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: option.imageUrl!,
                              width: 30,
                              height: 30,
                              placeholder: (context, url) => const SizedBox(
                                width: 25,
                                height: 25,
                                child:
                                    CircularProgressIndicator(strokeWidth: 1),
                              ),
                              errorWidget: (context, url, error) => Text(
                                  _getEmojiForOption(option.name),
                                  style: const TextStyle(fontSize: 20)),
                            )
                          : Text(_getEmojiForOption(option.name),
                              style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.name,
                            style: AppTextStyle.bodyBold(context,
                                color: AppColor.textTitle(context))),
                        if (option.price > 0)
                          Text("+\$${option.price}",
                              style: AppTextStyle.body(context,
                                  fontSize: 12,
                                  color: AppColor.textSecondary(context))),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        final set = _selectedMultipleOptions[group.id] ?? {};
                        if (val == true) {
                          set.add(option.id);
                        } else {
                          set.remove(option.id);
                        }
                        _selectedMultipleOptions[group.id] = set;
                      });
                    },
                    activeColor: AppColor.primary(context),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _getEmojiForOption(String name) {
    name = name.toLowerCase();
    if (name.contains('cheese')) return '🧀';
    if (name.contains('olive')) return '🫒';
    if (name.contains('onion')) return '🧅';
    if (name.contains('pepper')) return '🫑';
    if (name.contains('bacon')) return '🥓';
    if (name.contains('mushroom')) return '🍄';
    if (name.contains('tomato')) return '🍅';
    if (name.contains('pineapple')) return '🍍';
    return '🍴';
  }
}
