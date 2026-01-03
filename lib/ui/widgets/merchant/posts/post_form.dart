import 'package:flutter/material.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/post_service.dart';
import 'package:dak_louk/domain/services/merchant/product_service.dart';
import 'package:dak_louk/ui/widgets/merchant/posts/media_section.dart';
import 'package:dak_louk/ui/widgets/merchant/posts/products_section.dart';
import 'package:dak_louk/ui/widgets/merchant/shared/product_selector_sheet.dart';

class PostForm extends StatefulWidget {
  final PostVM? post;
  final void Function(PostVM savedPost)? onSaved;

  const PostForm({super.key, this.post, this.onSaved});

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();
  final _captionCtrl = TextEditingController();
  final List<String> _mediaUrls = [];
  final List<PostProductVM> _selectedProducts = [];

  bool _saving = false;
  final _service = PostService();
  final _productService = ProductService();

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _captionCtrl.text = widget.post!.caption ?? '';
      if (widget.post!.promoMedias != null) {
        _mediaUrls.addAll(widget.post!.promoMedias!.map((m) => m.url));
      }
      _selectedProducts.addAll(widget.post!.products);
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  void _addMedia() {
    showDialog(
      context: context,
      builder: (context) {
        final urlController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Media'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'Enter media URL',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (urlController.text.isNotEmpty) {
                  setState(() {
                    _mediaUrls.add(urlController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaUrls.removeAt(index);
    });
  }

  void _addProduct() {
    showProductSelectorSheet(
      context: context,
      productService: _productService,
      selectedProducts: _selectedProducts,
      onProductsSelected: () => setState(() {}),
    );
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      PostVM? result;

      if (widget.post == null) {
        // Create new post
        result = await _service.createPost(
          CreatePostDTO(
            caption: _captionCtrl.text.trim().isEmpty
                ? null
                : _captionCtrl.text.trim(),
          ),
        );
      } else {
        // Update existing post
        result = await _service.updatePost(
          widget.post!.id,
          UpdatePostDTO(
            caption: _captionCtrl.text.trim().isEmpty
                ? null
                : _captionCtrl.text.trim(),
          ),
        );
      }

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
    final isEditing = widget.post != null;

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
                  isEditing ? 'Edit Post' : 'Create Post',
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
                mediaUrls: _mediaUrls,
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
                  onTap: _saving ? null : _submit,
                  child: _saving
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Center(
                          child: Text(
                            isEditing ? 'Update Post' : 'Create Post',
                            style: const TextStyle(
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
