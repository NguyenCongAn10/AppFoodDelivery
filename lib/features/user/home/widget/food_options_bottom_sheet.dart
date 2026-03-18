import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/features/user/cart/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodOptionsBottomSheet extends StatefulWidget {
  final FoodModel food;
  final int restaurantId;

  const FoodOptionsBottomSheet({
    super.key,
    required this.food,
    required this.restaurantId,
  });

  @override
  State<FoodOptionsBottomSheet> createState() => _FoodOptionsBottomSheetState();
}

class _FoodOptionsBottomSheetState extends State<FoodOptionsBottomSheet> {
  final Map<int, int> _selectedSingleOptions = {};
  final Map<int, Set<int>> _selectedMultipleOptions = {};
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Initialize single selection defaults
    for (var group in widget.food.optionGroups) {
      if (group.selectionType == 'SINGLE' && group.options.isNotEmpty) {
        _selectedSingleOptions[group.id] = group.options.first.id;
      }
    }
  }

  double get _totalPrice {
    double basePrice = widget.food.price;
    double optionsPrice = 0;

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

    return (basePrice + optionsPrice) * _quantity;
  }

  String _getEmojiForOption(String name) {
    name = name.toLowerCase();
    if (name.contains("egg")) return "🍳";
    if (name.contains("cheese")) return "🧀";
    if (name.contains("bacon")) return "🥓";
    if (name.contains("avocado")) return "🥑";
    if (name.contains("chili")) return "🌶️";
    if (name.contains("onion")) return "🧅";
    if (name.contains("tomato")) return "🍅";
    if (name.contains("beef")) return "🥩";
    if (name.contains("chicken")) return "🍗";
    if (name.contains("coke") || name.contains("pepsi")) return "🥤";
    if (name.contains("fry") || name.contains("fries")) return "🍟";
    return "✨";
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: widget.food.imageUrl != null && widget.food.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.food.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood, size: 30),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.fastfood),
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.food.name,
                      style: AppTextStyle.bodyBold(context, fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "\$${widget.food.price}",
                      style: AppTextStyle.accent(context, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                   IconButton(
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColor.primary(context),
                  ),
                  Text("$_quantity", style: AppTextStyle.bodyBold(context)),
                  IconButton(
                    onPressed: () {
                      setState(() => _quantity++);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColor.primary(context),
                  ),
                ],
              )
            ],
          ),
          const Divider(height: 30),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: widget.food.optionGroups.map((group) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          group.name,
                          style: AppTextStyle.bodyBold(context, fontSize: 16),
                        ),
                      ),
                      if (group.selectionType == 'SINGLE')
                        ...group.options.map((option) {
                          final isSelected = _selectedSingleOptions[group.id] == option.id;
                          return RadioListTile<int>(
                            value: option.id,
                            groupValue: _selectedSingleOptions[group.id],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedSingleOptions[group.id] = val);
                              }
                            },
                            title: Text(option.name, style: AppTextStyle.body(context)),
                            secondary: Text("+\$${option.price}", style: AppTextStyle.bodyBold(context, color: AppColor.primary(context))),
                            activeColor: AppColor.primary(context),
                            contentPadding: EdgeInsets.zero,
                          );
                        })
                      else
                        ...group.options.map((option) {
                          final selectedIds = _selectedMultipleOptions[group.id] ?? {};
                          final isSelected = selectedIds.contains(option.id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedIds.add(option.id);
                                } else {
                                  selectedIds.remove(option.id);
                                }
                                _selectedMultipleOptions[group.id] = selectedIds;
                              });
                            },
                            title: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppColor.inputFill(context),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: (option.imageUrl != null && option.imageUrl!.isNotEmpty)
                                        ? CachedNetworkImage(
                                            imageUrl: option.imageUrl!,
                                            width: 25,
                                            height: 25,
                                            placeholder: (context, url) => const SizedBox(
                                              width: 25,
                                              height: 25,
                                              child: CircularProgressIndicator(strokeWidth: 1),
                                            ),
                                            errorWidget: (context, url, error) => Text(
                                              _getEmojiForOption(option.name),
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          )
                                        : Text(_getEmojiForOption(option.name), style: const TextStyle(fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(option.name, style: AppTextStyle.body(context)),
                              ],
                            ),
                            secondary: Text("+\$${option.price}", style: AppTextStyle.bodyBold(context, color: AppColor.primary(context))),
                            activeColor: AppColor.primary(context),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.trailing,
                          );
                        }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                final List<FoodOptionModel> selectedOptions = [];
                for (var group in widget.food.optionGroups) {
                  if (group.selectionType == 'SINGLE') {
                    final id = _selectedSingleOptions[group.id];
                    if (id != null) {
                      selectedOptions.add(group.options.firstWhere((o) => o.id == id));
                    }
                  } else {
                    final ids = _selectedMultipleOptions[group.id] ?? {};
                    for (var id in ids) {
                      selectedOptions.add(group.options.firstWhere((o) => o.id == id));
                    }
                  }
                }

                await context.read<CartProvider>().addFood(
                  widget.food,
                  widget.restaurantId,
                  quantity: _quantity,
                  selectedOptions: selectedOptions,
                );

                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Add to Cart • \$${_totalPrice.toStringAsFixed(2)}",
                    style: AppTextStyle.bodyBold(context, color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
