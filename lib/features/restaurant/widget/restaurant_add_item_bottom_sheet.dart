import 'dart:io';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/category_model.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RestaurantAddItemBottomSheet extends StatefulWidget {
  final FoodModel? food;

  const RestaurantAddItemBottomSheet({super.key, this.food});

  @override
  State<RestaurantAddItemBottomSheet> createState() => _RestaurantAddItemBottomSheetState();
}

class _OptionForm {
  TextEditingController nameController;
  TextEditingController priceController;
  _OptionForm({required String name, required String price}) 
    : nameController = TextEditingController(text: name),
      priceController = TextEditingController(text: price);
}

class _OptionGroupForm {
  TextEditingController nameController;
  bool isRequired;
  String selectionType;
  List<_OptionForm> options;
  _OptionGroupForm({required String name, this.isRequired = false, this.selectionType = 'SINGLE', List<_OptionForm>? options})
    : nameController = TextEditingController(text: name),
      options = options ?? [];
}

class _RestaurantAddItemBottomSheetState extends State<RestaurantAddItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  
  bool _isAvailable = true;
  CategoryModel? _selectedCategory;
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSaving = false;
  String? _existingImageUrl;
  
  final List<_OptionGroupForm> _optionGroups = [];

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.food != null) {
      _nameController.text = widget.food!.name;
      _descController.text = widget.food!.description ?? '';
      _priceController.text = widget.food!.price.toStringAsFixed(0);
      _isAvailable = widget.food!.isAvailable;
      _existingImageUrl = widget.food!.imageUrl;

      for (var group in widget.food!.optionGroups) {
        _optionGroups.add(_OptionGroupForm(
          name: group.name,
          isRequired: group.isRequired,
          selectionType: group.selectionType,
          options: group.options.map((o) => _OptionForm(name: o.name, price: o.price.toStringAsFixed(0))).toList(),
        ));
      }
    }
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await BackendService().getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        if (widget.food != null && widget.food!.categoryId != null) {
          try {
            _selectedCategory = _categories.firstWhere((c) => c.id == widget.food!.categoryId);
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      String? imageUrl;
      
      // Upload image to Supabase if selected
      if (_imageFile != null) {
        final fileName = _imageFile!.path.split('/').last;
        imageUrl = await SupabaseService.uploadImage(_imageFile!, fileName);
        if (imageUrl == null) {
          throw Exception('Failed to upload image to Supabase.');
        }
      } else {
        imageUrl = _existingImageUrl;
      }

      final payload = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'is_available': _isAvailable,
        if (imageUrl != null) 'image_url': imageUrl,
        if (_selectedCategory != null) 'category_id': _selectedCategory!.id,
        'option_groups': _optionGroups.map((g) => {
          'name': g.nameController.text.trim(),
          'is_required': g.isRequired,
          'selection_type': g.selectionType,
          'options': g.options.map((o) => {
             'name': o.nameController.text.trim(),
             'price': double.tryParse(o.priceController.text.trim()) ?? 0.0,
          }).toList(),
        }).toList(),
      };

      if (widget.food == null) {
        await BackendService().createFood(payload);
      } else {
        await BackendService().updateFood(widget.food!.id, payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.food == null ? 'Item added successfully!' : 'Item updated successfully!', style: const TextStyle(color: Colors.white)), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context, true); // Return true to signal success
      }
    } catch (e) {
      debugPrint('Error saving item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding for the keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.inputFill(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _isLoadingCategories
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.food == null ? 'Add Item' : 'Edit Item', style: AppTextStyle.bodyBold(context, fontSize: 18)),
                          IconButton(
                            icon: Icon(Icons.close, color: AppColor.textTitle(context)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Image Picker
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColor.secondaryBackground(context),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColor.textSecondary(context).withOpacity(0.3)),
                              image: _imageFile != null
                                ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                : (_existingImageUrl != null 
                                    ? DecorationImage(image: NetworkImage(_existingImageUrl!), fit: BoxFit.cover)
                                    : null),
                          ),
                          child: _imageFile == null && _existingImageUrl == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt, color: AppColor.textSecondary(context), size: 32),
                                      const SizedBox(height: 8),
                                      Text('Add Photo', style: AppTextStyle.body(context, fontSize: 12, color: AppColor.textSecondary(context))),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Name
                      Text('Name', style: AppTextStyle.bodyBold(context, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Spicy Chicken Burger',
                          hintStyle: AppTextStyle.body(context, color: AppColor.textSecondary(context)),
                          filled: true,
                          fillColor: AppColor.container(context),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Price
                      Text('Price', style: AppTextStyle.bodyBold(context, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g. 50000',
                          prefixText: '\$ ',
                          hintStyle: AppTextStyle.body(context, color: AppColor.textSecondary(context)),
                          filled: true,
                          fillColor: AppColor.container(context),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter a price';
                          if (double.tryParse(val.trim()) == null) return 'Invalid price';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Category Dropdown
                      Text('Category', style: AppTextStyle.bodyBold(context, fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<CategoryModel>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColor.container(context),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        hint: Text('Select Category', style: AppTextStyle.body(context, color: AppColor.textSecondary(context))),
                        items: _categories.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c.name, style: AppTextStyle.body(context)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                        validator: (val) => val == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text('Description', style: AppTextStyle.bodyBold(context, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'e.g. Description about the food item',
                          hintStyle: AppTextStyle.body(context, color: AppColor.textSecondary(context)),
                          filled: true,
                          fillColor: AppColor.container(context),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Options
                      _buildOptionsSection(),
                      const SizedBox(height: 24),

                      // Availability
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Available', style: AppTextStyle.bodyBold(context, fontSize: 14)),
                          Switch(
                            value: _isAvailable,
                            activeThumbColor: AppColor.primary(context),
                            activeTrackColor: AppColor.primary(context).withValues(alpha: 0.4),
                            onChanged: (val) => setState(() => _isAvailable = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary(context),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(widget.food == null ? 'Save Item' : 'Update Item', style: AppTextStyle.bodyBold(context, color: Colors.white, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Options & Add-ons', style: AppTextStyle.bodyBold(context, fontSize: 16)),
            TextButton.icon(
              onPressed: () {
                setState(() => _optionGroups.add(_OptionGroupForm(name: '')));
              },
              icon: Icon(Icons.add, size: 18, color: AppColor.primary(context)),
              label: Text('Add Group', style: AppTextStyle.bodyBold(context, fontSize: 13, color: AppColor.primary(context))),
            )
          ],
        ),
        if (_optionGroups.isEmpty)
          Text('No options added.', style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context))),
        ..._optionGroups.asMap().entries.map((entry) {
          final index = entry.key;
          final group = entry.value;
          return Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.secondaryBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.textSecondary(context).withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: group.nameController,
                        style: AppTextStyle.bodyBold(context, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Group Name (e.g. Size)',
                          hintStyle: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context)),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => setState(() => _optionGroups.removeAt(index)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: group.isRequired,
                      onChanged: (val) => setState(() => group.isRequired = val ?? false),
                      activeColor: AppColor.primary(context),
                    ),
                    Text('Required', style: AppTextStyle.body(context, fontSize: 13)),
                    const Spacer(),
                    DropdownButton<String>(
                      value: group.selectionType,
                      underline: const SizedBox(),
                      style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textTitle(context)),
                      items: const [
                        DropdownMenuItem(value: 'SINGLE', child: Text('Single Selection')),
                        DropdownMenuItem(value: 'MULTIPLE', child: Text('Multiple Selection')),
                      ],
                      onChanged: (val) => setState(() => group.selectionType = val ?? 'SINGLE'),
                    ),
                  ],
                ),
                const Divider(),
                ...group.options.asMap().entries.map((optEntry) {
                  final optIndex = optEntry.key;
                  final opt = optEntry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: opt.nameController,
                            style: AppTextStyle.body(context, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Option Name',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: opt.priceController,
                            keyboardType: TextInputType.number,
                            style: AppTextStyle.body(context, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: '+0',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (val) {
                              if (val != null && val.isNotEmpty && double.tryParse(val) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(() => group.options.removeAt(optIndex)),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => group.options.add(_OptionForm(name: '', price: ''))),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Option'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColor.primary(context),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
