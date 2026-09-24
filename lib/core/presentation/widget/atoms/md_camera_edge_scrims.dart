import 'package:flutter/material.dart';
import '../../../../config/constant/app_colors.dart';

class CameraEdgeScrims extends StatelessWidget {
  const CameraEdgeScrims({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Column(
        children: [
          _Scrim(height: 160, begin: Alignment.topCenter),
          Spacer(),
          _Scrim(height: 280, begin: Alignment.bottomCenter),
        ],
      ),
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim({required this.height, required this.begin});

  final double height;
  final Alignment begin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: -begin,
          colors: const [AppColors.cameraScrim, Colors.transparent],
        ),
      ),
    );
  }
}
