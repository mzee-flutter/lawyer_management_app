import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FilePreviewShimmer extends StatelessWidget {
  const FilePreviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }
}
