import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_picker_sheet.dart';
import 'package:dak_louk/core/media/media_model.dart';
import 'package:flutter/material.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/product_service.dart';
import 'package:dak_louk/ui/widgets/merchant/shared/add_media_section.dart';
import 'package:dak_louk/ui/widgets/merchant/shared/add_products_section.dart';
import 'package:dak_louk/ui/widgets/merchant/shared/product_selector_sheet.dart';

class PostEditForm extends StatefulWidget {
  final PostVM post;

  const PostEditForm({super.key, required this.post});

  @override
  State<PostEditForm> createState() => _PostEditFormState();
}

class _PostEditFormState extends State<PostEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _captionCtrl;
  final List<MediaModel> _promoMedias = [];
  List<AddProductsModel> _selectedProducts = [];

  final _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _captionCtrl = TextEditingController(text: widget.post.caption ?? '');
    if (widget.post.promoMedias != null) {
      _promoMedias.addAll(
        widget.post.promoMedias!.map(
          (m) => MediaModel(
            url: m.url,
            type: m.mediaType == 'video' ? MediaType.video : MediaType.image,
          ),
        ),
      );
    } else {
      _promoMedias.addAll([]);
    }
    _selectedProducts.addAll(
      widget.post.products.map(
        (product) => AddProductsModel(
          id: product.id,
          name: product.name,
          price: product.price,
          medias: product.medias,
        ),
      ),
    );
  }

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
      selectedProducts: _selectedProducts
          .map(
            (product) => AddProductsModel(
              id: product.id,
              name: product.name,
              price: product.price,
              medias: product.medias,
            ),
          )
          .toList(),
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

    final dto = UpdatePostDTO(
      caption: _captionCtrl.text.trim().isEmpty
          ? null
          : _captionCtrl.text.trim(),
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Edit Post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                selectedProducts: _selectedProducts
                    .map(
                      (product) => AddProductsModel(
                        id: product.id,
                        name: product.name,
                        price: product.price,
                        medias: product.medias,
                      ),
                    )
                    .toList(),
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
                      'Update Post',
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
