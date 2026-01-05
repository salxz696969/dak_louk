import 'package:dak_louk/domain/models/models.dart';
import 'package:flutter/material.dart';

class MerchantProductItem extends StatelessWidget {
  final ProductVM product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MerchantProductItem({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('product-${product.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        onDelete();
        return false; // Don't actually dismiss, handle in callback
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              (product.mediaUrls?.isNotEmpty ?? false)
                  ? product.mediaUrls!.first
                  : 'assets/images/plane.jpg',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
          trailing: IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
        ),
      ),
    );
  }
}
