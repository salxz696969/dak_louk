import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_picker_sheet.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:flutter/material.dart';

class ProductsUpdateForm extends StatefulWidget {
  final ProductVM product;

  const ProductsUpdateForm({super.key, required this.product});

  @override
  State<ProductsUpdateForm> createState() => _ProductsUpdateFormState();
}

class _ProductsUpdateFormState extends State<ProductsUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;

  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product.name);
    _descCtrl = TextEditingController(text: widget.product.description ?? '');
    _priceCtrl = TextEditingController(text: widget.product.price.toString());
    _qtyCtrl = TextEditingController(text: widget.product.quantity.toString());
    imageUrl = widget.product.mediaUrls?.isNotEmpty ?? false
        ? widget.product.mediaUrls!.first
        : null;
  }

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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final dto = UpdateProductDTO(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text),
      quantity: int.parse(_qtyCtrl.text),
      imageUrl: imageUrl,
    );

    Navigator.pop(context, dto);
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
                'Edit Product',
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
                    const Icon(Icons.image, color: Colors.grey),
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
                onTap: _submit,
                child: const Center(
                  child: Text(
                    'Update',
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
