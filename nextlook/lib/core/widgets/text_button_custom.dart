import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class TextButtonCustom extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const TextButtonCustom({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: AppTextStyles.buttonSmall),
    );
  }
}
