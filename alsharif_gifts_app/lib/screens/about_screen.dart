import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/sanity_service.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final SanityService _service = SanityService();
  late Future<Map<String, dynamic>?> _settings;

  @override
  void initState() {
    super.initState();
    _settings = _service.getStoreSettings();
  }

  Future<void> _openWhatsApp(String number) async {
    const message = 'مرحباً، أريد الاستفسار عن منتجاتكم';
    final url = Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _settings,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final storeName = data?['storeName'] ?? 'متجرنا';
          final storeSubtitle = data?['storeSubtitle'] ?? '';
          final whatsapp = data?['whatsappNumber'] ?? '';
          final hours = data?['workingHours'] ?? '';
          final address = data?['address'] ?? '';
          final about = data?['about'] ?? '';
          final coverRef = data?['coverRef'] as String?;
          final logoRef = data?['logoRef'] as String?;
          final coverUrl = coverRef != null ? SanityConfig.imageUrl(coverRef) : null;
          final logoUrl = logoRef != null ? SanityConfig.imageUrl(logoRef) : null;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 260,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover image or gradient
                      if (coverUrl != null)
                        CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
                          ),
                        )
                      else
                        Container(decoration: const BoxDecoration(gradient: AppTheme.darkGradient)),
                      // Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(60),
                              Colors.black.withAlpha(180),
                            ],
                          ),
                        ),
                      ),
                      // Logo + name centered
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(80),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: logoUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: logoUrl,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, _, _) => Container(
                                          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                                          child: const Icon(Icons.card_giftcard, color: Colors.white, size: 36),
                                        ),
                                      )
                                    : Container(
                                        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                                        child: const Icon(Icons.card_giftcard, color: Colors.white, size: 36),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              storeName,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            if (storeSubtitle.isNotEmpty)
                              Text(
                                storeSubtitle,
                                style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.transparent,
                title: const Text('من نحن',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // About
                        if (about.isNotEmpty) ...[
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('عن المتجر'),
                                const SizedBox(height: 10),
                                Text(
                                  about,
                                  style: const TextStyle(
                                      fontSize: 14, height: 1.8, color: Color(0xFF4B5563)),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (hours.isNotEmpty) ...[
                          _buildInfoRow(Icons.access_time, 'ساعات العمل', hours),
                          const SizedBox(height: 10),
                        ],
                        if (address.isNotEmpty) ...[
                          _buildInfoRow(Icons.location_on_outlined, 'الموقع', address),
                          const SizedBox(height: 10),
                        ],
                        if (whatsapp.isNotEmpty) ...[
                          _buildInfoRow(Icons.phone_outlined, 'واتساب', '+$whatsapp'),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _openWhatsApp(whatsapp),
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: const Text(
                                'تواصل معنا على واتساب',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          'نسخة التطبيق 1.0.0',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(2)),
        ),
      ],
    );
  }
}
