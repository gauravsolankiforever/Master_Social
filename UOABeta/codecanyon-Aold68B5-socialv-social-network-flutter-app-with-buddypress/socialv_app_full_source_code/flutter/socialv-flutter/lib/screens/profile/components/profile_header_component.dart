import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/constants.dart';

class ProfileHeaderComponent extends StatelessWidget {
  final String avatarUrl;
  final String? cover;

  ProfileHeaderComponent({required this.avatarUrl, this.cover});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              cover.validate().isNotEmpty
                  ? cachedImage(
                      cover,
                      width: context.width(),
                      height: 130,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRectOnly(topLeft: defaultAppButtonRadius.toInt(), topRight: defaultAppButtonRadius.toInt())
                  : Image.asset(
                      AppImages.profileBackgroundImage,
                      width: context.width(),
                      height: 130,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRectOnly(topLeft: defaultAppButtonRadius.toInt(), topRight: defaultAppButtonRadius.toInt()),
              Positioned(
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), shape: BoxShape.circle),
                  child: cachedImage(avatarUrl, height: 88, width: 88, fit: BoxFit.cover).cornerRadiusWithClipRRect(100),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
