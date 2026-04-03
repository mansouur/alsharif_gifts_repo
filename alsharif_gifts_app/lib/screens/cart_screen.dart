import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item_model.dart';
import '../core/theme.dart';
import '../core/formatters.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  static const String _whatsappNumber = '971503565455';

  @override
  void dispose() {
    _cityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _sendWhatsApp(CartProvider cart) async {
    if (_cityController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال المدينة والعنوان')),
      );
      return;
    }

    final itemsText = cart.items.map((item) {
      final price = item.product.onSale && item.product.discountPercent != null
          ? '${item.product.formattedFinalPrice} (خصم ${item.product.discountPercent}%)'
          : item.product.formattedPrice;
      return '• ${item.product.name}\n  الكمية: ${item.quantity} × $price = ${formatPrice(item.total)}';
    }).join('\n\n');

    final message = '''طلب جديد من تطبيق الشريف للهدايا 🎁

المنتجات:
$itemsText

💰 الإجمالي: ${formatPrice(cart.totalPrice)}

📍 المدينة: ${_cityController.text.trim()}
🏠 العنوان: ${_addressController.text.trim()}
${_notesController.text.trim().isNotEmpty ? '📝 ملاحظات: ${_notesController.text.trim()}' : ''}''';

    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$_whatsappNumber?text=$encoded');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (mounted) {
        cart.clear();
        _cityController.clear();
        _addressController.clear();
        _notesController.clear();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح واتساب')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, _) => cart.items.isNotEmpty
                ? TextButton(
                    onPressed: () => _confirmClear(cart),
                    child: const Text('مسح الكل',
                        style: TextStyle(color: Colors.white)),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: AppTheme.primary.withAlpha(128)),
                  const SizedBox(height: 16),
                  const Text('السلة فارغة',
                      style:
                          TextStyle(fontSize: 18, color: AppTheme.secondary)),
                  const SizedBox(height: 8),
                  const Text('أضف منتجات من صفحة المنتجات',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Items list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...cart.items.map((item) => _buildCartItem(item, cart)),
                    const SizedBox(height: 8),
                    // Total
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatPrice(cart.totalPrice),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                          const Text(
                            'الإجمالي',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Delivery details
                    const Text(
                      'تفاصيل التوصيل',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cityController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'المدينة *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'العنوان التفصيلي *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Send button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _sendWhatsApp(cart),
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text(
                          'إرسال الطلب عبر واتساب',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cart) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Quantity controls
            Column(
              children: [
                IconButton(
                  onPressed: () => cart.increment(item.product.id),
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppTheme.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: () => cart.decrement(item.product.id),
                  icon: Icon(
                    item.quantity == 1
                        ? Icons.delete_outline
                        : Icons.remove_circle_outline,
                    color: item.quantity == 1 ? Colors.red : AppTheme.primary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.product.formattedFinalPrice} × ${item.quantity}',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    formatPrice(item.total),
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.product.firstImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.product.firstImage,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        width: 70,
                        height: 70,
                        color: AppTheme.primary.withAlpha(51),
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: AppTheme.primary.withAlpha(51),
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('مسح السلة'),
        content: const Text('هل تريد مسح جميع المنتجات من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            child:
                const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
