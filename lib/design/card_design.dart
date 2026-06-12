import 'package:flutter/material.dart';

import 'app_colors.dart';

Widget cardContainer({double? height, required Widget child}) {
  return Container(
    width: double.infinity,
    height: height,
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      surfaceTintColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    ),
  );
}
