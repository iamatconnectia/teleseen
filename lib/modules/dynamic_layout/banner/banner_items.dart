import 'package:flutter/material.dart';
import 'package:flux_ui/flux_ui.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/entities/product.dart';
import '../../../screens/detail/widgets/video_feature.dart';
import '../../../services/services.dart';
import '../../../widgets/common/parallax_image.dart';
import '../config/banner_config.dart';

class BannerItemWidget extends StatelessWidget {
  final BannerItemConfig config;
  final double? width;
  final double padding;
  final BoxFit? boxFit;
  final double radius;
  final double? height;
  final Function onTap;
  final bool enableParallax;
  final double parallaxImageRatio;
  final bool isSoundOn,
      autoPlayVideo,
      enableTimeIndicator,
      doubleTapToFullScreen;

  /// The controller for the animated stack container
  final AnimatedStackContainerController? animatedController;

  const BannerItemWidget({
    super.key,
    required this.config,
    required this.padding,
    this.width,
    this.boxFit,
    required this.radius,
    this.height,
    required this.onTap,
    this.enableParallax = false,
    this.parallaxImageRatio = 1.2,
    this.isSoundOn = false,
    this.autoPlayVideo = false,
    this.enableTimeIndicator = true,
    this.doubleTapToFullScreen = false,
    this.animatedController,
  });

  @override
  Widget build(BuildContext context) {
    switch (config.type) {
      case BannerType.animated:
        return AnimatedStackContainer(
          animatedConfig:
              config.animatedConfig ?? AnimatedStackContainerData.fromJson({}),
          controller: animatedController,
          onTapHandler: (context, config) {
            if (config != null) {
              NavigateTools.onTapNavigateOptions(
                context: context,
                config: config,
              );
            }
          },
        );

      case BannerType.video:
        return BannerVideoItem(
          config: config,
          padding: padding,
          isSoundOn: isSoundOn,
          autoPlayVideo: autoPlayVideo,
          enableTimeIndicator: enableTimeIndicator,
          doubleTapToFullScreen: doubleTapToFullScreen,
        );

      case BannerType.image:
        return BannerImageItem(
          config: config,
          padding: padding,
          width: width,
          boxFit: boxFit,
          radius: radius,
          height: height,
          onTap: onTap,
          enableParallax: enableParallax,
          parallaxImageRatio: parallaxImageRatio,
        );
    }
  }
}

/// The Banner type to display the image
class BannerImageItem extends StatefulWidget {
  final BannerItemConfig config;
  final double? width;
  final double padding;
  final BoxFit? boxFit;
  final double radius;
  final double? height;
  final Function onTap;
  final bool enableParallax;
  final double parallaxImageRatio;
  final BoxShadowConfig? boxShadowConfig;

  const BannerImageItem({
    super.key,
    required this.config,
    required this.padding,
    this.width,
    this.boxFit,
    required this.radius,
    this.height,
    required this.onTap,
    this.enableParallax = false,
    this.parallaxImageRatio = 1.2,
    this.boxShadowConfig,
  });

  @override
  State<BannerImageItem> createState() => _StateBannerImageItem();
}

class _StateBannerImageItem extends State<BannerImageItem> {
  Product? _product;

  @override
  void initState() {
    super.initState();
    // Only fetch product if bannerWithProduct is enabled
    if (widget.config.bannerWithProduct) {
      _fetchProduct();
    }
  }

  void _fetchProduct() async {
    final productId = widget.config.jsonData['product']?.toString() ??
        (widget.config.products.isNotEmpty
            ? widget.config.products.first
            : null);

    if (productId != null) {
      try {
        final product = await Services().api.getProduct(productId);
        if (mounted) {
          setState(() {
            _product = product;
          });
        }
      } catch (e) {
        printLog('Error fetching product for banner: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paddingVal = widget.config.padding ?? widget.padding;
    final radiusVal = widget.config.radius ?? widget.radius;

    final screenSize = MediaQuery.of(context).size;
    final itemWidth = widget.width ?? screenSize.width;
    final boxShadow = widget.boxShadowConfig ?? BoxShadowConfig.empty();

    final buttonConfig = widget.config.button;
    final titleConfig = widget.config.title;
    final descriptionConfig = widget.config.description;

    final buttonTextTheme = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: HexColor(buttonConfig?.textColor),
          fontFamily: buttonConfig?.fontFamily,
          fontSize: buttonConfig?.fontSize,
        );

    final descriptionTextTheme =
        Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: HexColor(descriptionConfig?.color),
      fontSize: descriptionConfig?.fontSize,
      fontFamily: descriptionConfig?.fontFamily,
      shadows: <Shadow>[
        if (descriptionConfig?.enableShadow ?? false)
          const Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 3.0,
            color: Colors.black,
          ),
      ],
    );

    final titleTextTheme = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: HexColor(titleConfig?.color),
      fontSize: titleConfig?.fontSize,
      fontFamily: titleConfig?.fontFamily,
      fontWeight: FontWeight.bold,
      shadows: <Shadow>[
        if (titleConfig?.enableShadow ?? false)
          const Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 3.0,
            color: Colors.black,
          ),
      ],
    );

    // Determine which image to use
    var imageUrl = widget.config.image;
    if (widget.config.bannerWithProduct && _product != null && _product!.images.isNotEmpty) {
      // Use dynamic product image only if bannerWithProduct is enabled
      imageUrl = _product!.images.first;
    }

    return GestureDetector(
      onTap: () =>
          buttonConfig == null ? widget.onTap(widget.config.jsonData) : null,
      child: Container(
        width: itemWidth,
        height: widget.height,
        constraints: const BoxConstraints(minHeight: 10.0),
        child: Stack(
          children: [
            if (widget.enableParallax)
              ParallaxImage(
                image: imageUrl,
                ratio: widget.parallaxImageRatio,
              )
            else
              Container(
                margin: EdgeInsets.symmetric(horizontal: paddingVal),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValueOpacity(boxShadow.colorOpacity),
                      blurRadius: boxShadow.blurRadius,
                      spreadRadius: boxShadow.spreadRadius,
                      offset: Offset(
                        boxShadow.x,
                        boxShadow.y,
                      ),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radiusVal),
                  child: FluxImage(
                    imageUrl: imageUrl,
                    fit: widget.boxFit ?? BoxFit.fitWidth,
                    width: itemWidth,
                    height: widget.height,
                  ),
                ),
              ),
            if (descriptionConfig != null)
              Align(
                alignment: descriptionConfig.alignment,
                child: Text(
                  descriptionConfig.text,
                  style: ThemeHelper.getFont(
                    descriptionConfig.fontFamily,
                    textStyle: descriptionTextTheme,
                  ),
                ),
              ),
            if (titleConfig != null)
              Align(
                alignment: titleConfig.alignment,
                child: Text(
                  titleConfig.text,
                  style: ThemeHelper.getFont(
                    titleConfig.fontFamily,
                    textStyle: titleTextTheme,
                  ),
                ),
              ),
            if (buttonConfig != null)
              Align(
                alignment: buttonConfig.alignment,
                child: InkWell(
                  onTap: () => widget.onTap(widget.config.jsonData),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                        color: HexColor(buttonConfig.backgroundColor),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      buttonConfig.text,
                      style: ThemeHelper.getFont(
                        buttonConfig.fontFamily,
                        textStyle: buttonTextTheme,
                      ),
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

class BannerVideoItem extends StatelessWidget {
  final BannerItemConfig config;
  final bool isSoundOn,
      autoPlayVideo,
      enableTimeIndicator,
      doubleTapToFullScreen;
  final double padding;

  const BannerVideoItem({
    super.key,
    required this.config,
    this.isSoundOn = false,
    this.autoPlayVideo = false,
    this.enableTimeIndicator = true,
    this.doubleTapToFullScreen = false,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    var paddingVal = config.padding ?? padding;

    return Padding(
      padding: EdgeInsets.only(left: paddingVal, right: paddingVal),
      child: FeatureVideoPlayer(
        config.video ?? '',
        autoPlay: autoPlayVideo,
        isSoundOn: isSoundOn,
        enableTimeIndicator: enableTimeIndicator,
        aspectRatio: 16 / 9,
        doubleTapToFullScreen: doubleTapToFullScreen,
        showFullScreenButton: true,
        showVolumeButton: true,
      ),
    );
  }
}
