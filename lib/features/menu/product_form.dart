import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'mock_data.dart';

class ProductForm extends StatefulWidget {
  final MenuProduct? product;
  final List<String> categories;

  const ProductForm({super.key, this.product, required this.categories});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late String _category;
  String? _imagePath;
  bool _featured = false;
  bool _available = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product == null ? '0' : '${widget.product!.stock}');
    _category = widget.product?.category ?? widget.categories.first;
    _featured = widget.product?.featured ?? false;
    _available = widget.product?.available ?? true;
    _imagePath = widget.product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product == null ? 'Add Product' : 'Edit Product',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ProductImagePicker(
                imagePath: _imagePath,
                onChanged: (path) => setState(() => _imagePath = path),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              if (widget.product == null) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Opening stock',
                    helperText: '0 means the item is out of stock',
                  ),
                ),
              ],
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: widget.categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (v) => setState(() => _category = v ?? widget.categories.first),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _featured,
                onChanged: (v) => setState(() => _featured = v),
                title: const Text('Featured'),
              ),
              SwitchListTile(
                value: _available,
                onChanged: (v) => setState(() => _available = v),
                title: const Text('Available'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final price = double.tryParse(_priceController.text);
                      final stock = int.tryParse(_stockController.text) ?? 0;
                      if (name.isEmpty || price == null || price < 0 || stock < 0) return;
                      Navigator.of(context).pop(MenuProduct(
                        id: widget.product?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                        name: name,
                        price: price,
                        category: _category,
                        featured: _featured,
                        available: _available,
                        stock: widget.product == null ? stock : widget.product!.stock,
                        variants: widget.product?.variants ?? const [],
                        modifiers: widget.product?.modifiers ?? const [],
                        description: widget.product?.description ?? '',
                        imagePath: _imagePath,
                      ));
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImagePicker extends StatelessWidget {
  const _ProductImagePicker({required this.imagePath, required this.onChanged});
  final String? imagePath;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final image = imagePath == null
        ? const Center(child: Icon(Icons.add_a_photo_outlined, size: 36))
        : Image.file(File(imagePath!), fit: BoxFit.cover);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Product image'),
      const SizedBox(height: 8),
      Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 96, height: 96, child: image)),
        const SizedBox(width: 12),
        Expanded(child: Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(
            onPressed: () async {
              final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200);
              if (image != null) onChanged(image.path);
            },
            icon: const Icon(Icons.photo_library_outlined), label: const Text('Gallery'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1200);
              if (image != null) onChanged(image.path);
            },
            icon: const Icon(Icons.camera_alt_outlined), label: const Text('Camera'),
          ),
          if (imagePath != null) TextButton(onPressed: () => onChanged(null), child: const Text('Remove')),
        ])),
      ]),
    ]);
  }
}
