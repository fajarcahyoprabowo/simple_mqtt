import 'package:flutter/material.dart';

class AppFieldDecoration extends InputDecoration {
  const AppFieldDecoration({required super.labelText});

  @override
  bool? get isDense => true;

  @override
  InputBorder? get border {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
    );
  }
}
