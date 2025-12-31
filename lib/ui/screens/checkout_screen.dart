import 'package:dak_louk/domain/models/index.dart';
import 'package:dak_louk/ui/widgets/add_and_remove_button.dart';
import 'package:dak_louk/ui/widgets/appbar.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final CartModel cart;
  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Appbar(title: 'Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductSection(cart: widget.cart),
            const SizedBox(height: 20),
            _DeliveryInformationSection(),
            const SizedBox(height: 20),
            _OrderSummarySection(cart: widget.cart),
            const SizedBox(height: 20),
            _ProceedButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  final CartModel cart;
  const _ProductSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = cart.ui();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image(
              image: AssetImage(ui.image[0]),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ui.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                ui.sellerName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ui.sellerRating.toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              const Icon(Icons.star, size: 12, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ui.price,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          AddAndRemoveButton(cart: cart, baseQuantity: cart.quantity),
        ],
      ),
    );
  }
}

class _DeliveryInformationSection extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delivery Information",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Full Name"),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your full name...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 12),
                Text("Address"),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your address...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 12),
                Text("Phone Number"),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your phone number...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 12),
                Text("Delivery Notes (optional)"),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Any special instructions for delivery...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderSummarySection extends StatelessWidget {
  final CartModel cart;
  const _OrderSummarySection({required this.cart});

  @override
  Widget build(BuildContext context) {
    double deliveryFee = 5.00;
    double price = double.tryParse(cart.ui().price.replaceAll('\$', '')) ?? 0.0;
    final ui = cart.ui();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text("Subtotal:"), Text(ui.price)],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Delivery Fee:"),
              Text("\$${deliveryFee.toStringAsFixed(2)}"),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total:",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${(price + deliveryFee).toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProceedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      height: 50,
      child: InkWell(
        onTap: () {
          // Handle payment
        },
        child: const Center(
          child: Text(
            'Proceed to Payment',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
