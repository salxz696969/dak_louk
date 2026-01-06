import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_picker_sheet.dart';
import 'package:dak_louk/core/media/media_model.dart';
import 'package:flutter/material.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/product_service.dart';
import 'package:dak_louk/ui/widgets/merchant/shared/add_media_section.dart';
import 'package:dak_louk/ui/widgets/merchant/shared/add_products_section.dart';
import 'package:dak_louk/ui/widgets/merchant/shared/product_selector_sheet.dart';

class PostForm extends StatefulWidget {
  const PostForm({super.key});

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();
  final _captionCtrl = TextEditingController();
  final List<MediaModel> _promoMedias = [];
  List<AddProductsModel> _selectedProducts = [];

  final _productService = ProductService();

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMedia() async {
    final path = await MediaPickerSheet.show(
      context,
      type: MediaType.image,
      folder: 'post_media',
    );
    if (path != null) {
      setState(() {
        _promoMedias.add(MediaModel(url: path, type: MediaType.image));
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _promoMedias.removeAt(index);
    });
  }

  void _addProduct() {
    showProductSelectorSheet(
      context: context,
      productService: _productService,
      selectedProducts: _selectedProducts,
      onProductsSelected: (selectedProducts) => setState(() {
        _selectedProducts = selectedProducts;
      }),
    );
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final dto = CreatePostDTO(
      caption: _captionCtrl.text.trim().isEmpty
          ? null
          : _captionCtrl.text.trim(),
      productIds: _selectedProducts.map((product) => product.id).toList(),
      promoMedias: _promoMedias,
    );

    Navigator.pop(context, dto);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Create Post',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Caption Field
              TextFormField(
                controller: _captionCtrl,
                decoration: InputDecoration(
                  labelText: 'Caption',
                  border: const OutlineInputBorder(),
                  hintText: 'Write your post caption...',
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              // Media Section
              MediaSection(
                medias: _promoMedias,
                onAddMedia: _addMedia,
                onRemoveMedia: _removeMedia,
              ),

              const SizedBox(height: 20),

              // Products Section
              ProductsSection(
                selectedProducts: _selectedProducts,
                onAddProduct: _addProduct,
                onRemoveProduct: _removeProduct,
              ),

              const SizedBox(height: 20),

              // Submit Button
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
                      'Create Post',
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
      ),
    );
  }
}
