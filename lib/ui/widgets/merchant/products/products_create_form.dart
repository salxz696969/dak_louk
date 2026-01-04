import 'dart:io';

import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_picker_sheet.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/product_service.dart';
import 'package:flutter/material.dart';

class ProductsCreateForm extends StatefulWidget {
  final void Function(ProductVM savedProduct)? onSaved;

  const ProductsCreateForm({super.key, this.onSaved});

  @override
  State<ProductsCreateForm> createState() => _ProductsCreateFormState();
}

class _ProductsCreateFormState extends State<ProductsCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  bool _saving = false;
  final _service = ProductService();
  String? imageUrl;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await MediaPickerSheet.show(
      context,
      type: MediaType.image,
      folder: 'product_images',
    );
    if (path != null) {
      setState(() => imageUrl = path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final result = await _service.createProduct(
        CreateProductDTO(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          price: double.parse(_priceCtrl.text),
          quantity: int.parse(_qtyCtrl.text),
          imageUrl: imageUrl,
        ),
      );

      widget.onSaved?.call(result!);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add Product',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Image Picker
            InkWell(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(imageUrl!),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        imageUrl == null
                            ? 'Tap to select product image (optional)'
                            : '${imageUrl!.split('/').last}',
                        style: TextStyle(
                          color: imageUrl == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  double.tryParse(v ?? '') == null ? 'Invalid price' : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _qtyCtrl,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  int.tryParse(v ?? '') == null ? 'Invalid quantity' : null,
            ),

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              height: 48,
              child: InkWell(
                onTap: _saving ? null : _submit,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Center(
                        child: Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

