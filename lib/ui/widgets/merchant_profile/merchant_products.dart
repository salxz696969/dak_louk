import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/user/merchant_service.dart';
import 'package:flutter/material.dart';

class MerchantProducts extends StatelessWidget {
  final MerchantService _merchantService = MerchantService();
  final int merchantId;
  MerchantProducts({required this.merchantId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MerchantProductsVM>>(
      future: _merchantService.getMerchantProducts(merchantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No products found.')),
          );
        }
        final products = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 9 / 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductContainer(product: product);
          },
        );
      },
    );
  }
}

class _ProductContainer extends StatelessWidget {
  final MerchantProductsVM product;

  const _ProductContainer({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // You can implement navigation to product detail page here
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image(image: AssetImage(product.image), fit: BoxFit.cover),
          ),
          // Slight gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                ),
              ),
            ),
          ),
          // Product info at the bottom
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black12,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.quantity} left',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
