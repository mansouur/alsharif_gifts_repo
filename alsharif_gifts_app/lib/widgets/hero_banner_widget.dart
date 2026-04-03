import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class HeroBannerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final Function(Map<String, dynamic>)? onBannerTap;

  const HeroBannerWidget({super.key, required this.banners, this.onBannerTap});

  @override
  State<HeroBannerWidget> createState() => _HeroBannerWidgetState();
}

class _HeroBannerWidgetState extends State<HeroBannerWidget> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 220,
            autoPlay: widget.banners.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            viewportFraction: 1.0,
            onPageChanged: (index, _) => setState(() => _current = index),
          ),
          items: widget.banners.map((banner) => GestureDetector(
            onTap: () => widget.onBannerTap?.call(banner),
            child: _buildBannerItem(banner),
          )).toList(),
        ),
        if (widget.banners.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.banners.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _current == entry.key ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _current == entry.key
                        ? AppTheme.primary
                        : AppTheme.primary.withAlpha(60),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildBannerItem(Map<String, dynamic> banner) {
    final imageRef = banner['imageRef'] as String?;
    final imageUrl = imageRef != null ? SanityConfig.imageUrl(imageRef) : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                ),
              )
            else
              Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(180),
                  ],
                ),
              ),
            ),
            // Text content
            Positioned(
              bottom: 20,
              right: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (banner['title'] != null)
                    Text(
                      banner['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  if (banner['subtitle'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      banner['subtitle'],
                      style: TextStyle(
                          color: Colors.white.withAlpha(200), fontSize: 13),
                    ),
                  ],
                  if (banner['buttonText'] != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        banner['buttonText'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
