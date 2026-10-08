import 'package:flutter/material.dart';
import 'package:patakha_khata/core/constants/app_colors.dart';

class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({super.key, required this.name, this.size = 48});

  final String name;
  final double size;

  Color get _bgColor {
    final hash = name.hashCode.abs();
    final colors = [
      AppColors.avatarPeach,
      AppColors.avatarTan,
      AppColors.avatarPeach,
    ];
    return colors[hash % colors.length];
  }

  Color get _textColor {
    final hash = name.hashCode.abs();
    return hash.isEven ? AppColors.primaryDark : AppColors.avatarTanText;
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _bgColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.33,
        ),
      ),
    );
  }
}
