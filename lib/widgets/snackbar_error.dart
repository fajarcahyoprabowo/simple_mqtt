import 'package:flutter/material.dart';

class SnackbarError extends SnackBar {
  const SnackbarError({
    super.key,
    required super.content,
  });

  @override
  Color? get backgroundColor => Colors.red;
}
