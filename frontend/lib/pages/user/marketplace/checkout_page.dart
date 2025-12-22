import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../app_theme.dart';
import '../../../services/api_client.dart';
import '../../../services/upload_service.dart';
import 'cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _addressController = TextEditingController();
  final UploadService _uploadService = UploadService.instance;
  
  bool _isSubmitting = false;
  String? _orderId;
  String? _paymentProofUrl;
  DateTime? _expiresAt;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  bool _isExpired = false;
  String _orderStatus = 'pending';

  // Bank info
  static const String bankName = 'BCA';
  static const String accountNumber = '1234567890';
  static const String accountHolder = 'Banyumas SportHub';

  @override
  void dispose() {
    _addressController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_expiresAt == null) return;
      
      final remaining = _expiresAt!.difference(DateTime.now());
      if (remaining.isNegative) {
        setState(() {
          _isExpired = true;
          _orderStatus = 'expired';
          _remainingTime = Duration.zero;
        });
        timer.cancel();
      } else {
        setState(() => _remainingTime = remaining);
      }
    });
  }

  Future<void> _submitOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan alamat pengiriman"), backgroundColor: Colors.red),
      );
      return;
    }

    if (cart.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Keranjang kosong"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final items = cart.cartItems.map((item) => {
        'name': item['title'],
        'price': item['price'],
        'quantity': item['qty'],
      }).toList();

      final response = await ApiClient.instance.post('/orders', {
        'items': items,
        'totalAmount': cart.totalPrice,
        'shippingAddress': _addressController.text.trim(),
        'paymentMethod': 'manual-transfer',
      });

      final order = response['order'];
      setState(() {
        _orderId = order['id'];
        _expiresAt = DateTime.parse(order['expiresAt']);
        _orderStatus = order['status'];
        _isSubmitting = false;
      });
      
      _startCountdown();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order berhasil dibuat! Silakan upload bukti transfer."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _uploadPaymentProof() async {
    try {
      final file = await _uploadService.pickImage();
      if (file == null) return;

      setState(() => _isSubmitting = true);

      final imageUrl = await _uploadService.uploadImage(file);
      
      await ApiClient.instance.post('/orders/$_orderId/payment-proof', {
        'paymentProofUrl': imageUrl,
      });

      setState(() {
        _paymentProofUrl = imageUrl;
        _orderStatus = 'paid';
        _isSubmitting = false;
      });

      // Clear cart after successful payment
      Provider.of<CartProvider>(context, listen: false).clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bukti transfer berhasil diupload! Menunggu verifikasi admin."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload: $e"), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Items
            const Text("Pesanan Anda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: cart.cartItems.map((item) => ListTile(
                  leading: item['image'] != null && item['image'].toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50, height: 50,
                              color: Colors.grey[200],
                              child: const Icon(Icons.shopping_bag),
                            ),
                          ),
                        )
                      : Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shopping_bag),
                        ),
                  title: Text(item['title'] ?? ''),
                  subtitle: Text("Rp ${item['price']?.toStringAsFixed(0) ?? '0'} x ${item['qty'] ?? 1}"),
                  trailing: Text("Rp ${((item['price'] ?? 0) * (item['qty'] ?? 1)).toStringAsFixed(0)}"),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Total
            Card(
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text("Rp ${cart.totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Address input (before order submitted)
            if (_orderId == null) ...[
              const Text("Alamat Pengiriman *", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Masukkan alamat lengkap pengiriman...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Buat Pesanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],

            // After order submitted - show payment info
            if (_orderId != null) ...[
              // Bank Info
              const Text("Transfer ke Rekening", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(bankName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("No. Rekening:"),
                          SelectableText(accountNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Atas Nama:"),
                          Text(accountHolder, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Countdown Timer
              if (!_isExpired && _orderStatus == 'pending') ...[
                Card(
                  color: Colors.orange.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.orange, size: 32),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Batas Waktu Transfer", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                            Text(_formatDuration(_remainingTime),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Expired message
              if (_isExpired) ...[
                Card(
                  color: Colors.red.withOpacity(0.1),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Pesanan telah expired karena tidak ada pembayaran dalam 10 jam.",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Upload payment proof
              if (!_isExpired && _orderStatus == 'pending') ...[
                const Text("Upload Bukti Transfer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _isSubmitting ? null : _uploadPaymentProof,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                    ),
                    child: _isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Tap untuk upload bukti transfer", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
              ],

              // Payment proof uploaded / paid status
              if (_orderStatus == 'paid') ...[
                Card(
                  color: Colors.green.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 32),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Bukti transfer sudah diupload! Menunggu verifikasi admin.",
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        if (_paymentProofUrl != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(_paymentProofUrl!, height: 150, fit: BoxFit.cover),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              // Delivery status
              if (_orderStatus == 'delivery') ...[
                Card(
                  color: Colors.blue.withOpacity(0.1),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.blue, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Pesanan Anda sedang dalam proses pengiriman!",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
