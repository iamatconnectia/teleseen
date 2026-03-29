import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/tools.dart';
import '../../../models/index.dart';
import '../../../services/index.dart';

class MetaSliderWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool cleanCache;

  const MetaSliderWidget({super.key, required this.config, this.cleanCache = false});

  @override
  State<MetaSliderWidget> createState() => _MetaSliderWidgetState();
}

class _MetaSliderWidgetState extends State<MetaSliderWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  List<Map<String, dynamic>> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void didUpdateWidget(MetaSliderWidget oldWidget) {
    if (widget.cleanCache && !oldWidget.cleanCache) {
      _loadBanners();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await Services().api.getMetaSlider();
      if (mounted) {
        setState(() {
          _banners = banners;
          _isLoading = false;
        });
        _startAutoPlay();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_pageController.hasClients) {
          final nextPage = (_currentPage + 1) % _banners.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final bannerHeight = screenWidth * 0.32; // Balanced aspect ratio

    return Container(
      height: bannerHeight + 30, // Extra space for indicators
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = _banners[index];
                    return GestureDetector(
                      onTap: () {
                        final link = banner['link']?.toString() ?? '';
                        if (link.isEmpty) return;

                        // Try to parse native navigation
                        final uri = Uri.tryParse(link);
                        if (uri != null && uri.pathSegments.isNotEmpty) {
                          final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
                          
                          // Category check: /product-category/slug/
                          if (link.contains('/product-category/')) {
                            final catIndex = segments.indexOf('product-category');
                            if (catIndex != -1 && catIndex + 1 < segments.length) {
                              final slug = segments[catIndex + 1];
                              NavigateTools.onTapNavigateOptions(
                                context: context,
                                config: {'category': slug, 'name': slug},
                              );
                              return;
                            }
                          }
                          // Product check: /product/slug/
                          if (link.contains('/product/')) {
                            final prodIndex = segments.indexOf('product');
                            if (prodIndex != -1 && prodIndex + 1 < segments.length) {
                              final slug = segments[prodIndex + 1];
                              NavigateTools.onTapNavigateOptions(
                                context: context,
                                config: {'product': slug},
                              );
                              return;
                            }
                          }
                        }

                        // Fallback to webview
                        NavigateTools.onTapNavigateOptions(
                          context: context,
                          config: {'url': link},
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FluxImage(
                            imageUrl: banner['image'] ?? '',
                            fit: BoxFit.cover,
                            width: screenWidth,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        final prevPage = (_currentPage - 1 + _banners.length) % _banners.length;
                        _pageController.animateToPage(prevPage, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        final nextPage = (_currentPage + 1) % _banners.length;
                        _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey.withOpacity(0.5),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
