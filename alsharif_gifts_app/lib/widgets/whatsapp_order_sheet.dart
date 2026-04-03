import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product_model.dart';
import '../core/theme.dart';
import '../core/formatters.dart';

class WhatsAppOrderSheet extends StatefulWidget {
  final ProductModel product;

  const WhatsAppOrderSheet({super.key, required this.product});

  @override
  State<WhatsAppOrderSheet> createState() => _WhatsAppOrderSheetState();
}

class _WhatsAppOrderSheetState extends State<WhatsAppOrderSheet> {
  int _quantity = 1;
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

  double get _total => widget.product.finalPrice * _quantity;

  Future<void> _sendWhatsApp() async {
    if (_cityController.text.trim().isEmpty || _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال المدينة والعنوان')),
      );
      return;
    }

    final price = widget.product.onSale && widget.product.discountPercent != null
        ? '${widget.product.formattedFinalPrice} (بعد خصم ${widget.product.discountPercent}%)'
        : widget.product.formattedPrice;

    final message = '''طلب جديد من تطبيق الشريف للهدايا 🎁

المنتج: ${widget.product.name}
الكمية: $_quantity
سعر الوحدة: $price
الإجمالي: ${formatPrice(_total)}

المدينة: ${_cityController.text.trim()}
العنوان: ${_addressController.text.trim()}
${_notesController.text.trim().isNotEmpty ? 'ملاحظات: ${_notesController.text.trim()}' : ''}''';

    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$_whatsappNumber?text=$encoded');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'طلب عبر واتساب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.product.name,
              style: const TextStyle(color: AppTheme.secondary, fontSize: 13),
            ),
            const Divider(height: 24),

            // Quantity
            Row(
              children: [
                const Text('الكمية:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppTheme.primary,
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primary,
                ),
              ],
            ),

            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'الإجمالي: ${formatPrice(_total)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // City
            TextField(
              controller: _cityController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'المدينة *',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),

            // Address
            TextField(
              controller: _addressController,
              textAlign: TextAlign.right,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'العنوان التفصيلي *',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            TextField(
              controller: _notesController,
              textAlign: TextAlign.right,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 20),

            // WhatsApp button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendWhatsApp,
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
          ],
        ),
      ),
    );
  }
}
