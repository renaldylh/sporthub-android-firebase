import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_theme.dart';
import 'cart_provider.dart';
import 'checkout_page.dart';

class KeranjangPage extends StatelessWidget {
  const KeranjangPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text("Keranjang Saya"),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: cart.cartItems.isEmpty
          ? const Center(
              child: Text(
                "Keranjang masih kosong 😢",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cart.cartItems[index];
                      final imageUrl = item["image"]?.toString() ?? '';
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.shopping_bag,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.shopping_bag,
                                    color: Colors.grey,
                                  ),
                          ),
                          title: Text(item["title"] ?? ''),
                          subtitle: Text(
                              "Rp ${(item["price"] ?? 0).toStringAsFixed(0)} x ${item["qty"] ?? 1}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => cart.removeFromCart(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: Rp ${cart.totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CheckoutPage()),
                          );
                        },
                        child: const Text("Checkout", style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
