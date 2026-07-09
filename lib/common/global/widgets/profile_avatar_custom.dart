import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatarCustom extends StatelessWidget {
  final String backgroundImage;
  final double w;
  final double h;

  const ProfileAvatarCustom(
      {Key? key,
      required this.backgroundImage,
      required this.w,
      required this.h})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w,
      height: h,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: backgroundImage,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
