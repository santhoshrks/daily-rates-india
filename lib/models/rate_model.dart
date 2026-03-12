import 'package:flutter/material.dart';

/// Direction of price change compared to previous fetch.
enum PriceChange { up, down, unchanged }

/// Immutable data class representing a single market rate.
class RateModel {
  const RateModel({
    required this.title,
    required this.value,
    required this.updatedAt,
    required this.icon,
    this.prefix = '₹',
    this.iconBgColor = const Color(0xFFFFE0B2),
    this.iconFgColor = const Color(0xFFE65100),
    this.numericValue,
    this.previousNumericValue,
  });

  final String title;
  final String value;
  final DateTime updatedAt;
  final IconData icon;
  final String prefix;

  /// Category-specific colors for the icon container.
  final Color iconBgColor;
  final Color iconFgColor;

  /// Numeric values for computing price change direction.
  final double? numericValue;
  final double? previousNumericValue;

  /// Derived price change direction.
  PriceChange get change {
    if (numericValue == null || previousNumericValue == null) {
      return PriceChange.unchanged;
    }
    if (numericValue! > previousNumericValue!) return PriceChange.up;
    if (numericValue! < previousNumericValue!) return PriceChange.down;
    return PriceChange.unchanged;
  }

  RateModel copyWith({
    String? title,
    String? value,
    DateTime? updatedAt,
    IconData? icon,
    String? prefix,
    Color? iconBgColor,
    Color? iconFgColor,
    double? numericValue,
    double? previousNumericValue,
  }) {
    return RateModel(
      title: title ?? this.title,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      icon: icon ?? this.icon,
      prefix: prefix ?? this.prefix,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      iconFgColor: iconFgColor ?? this.iconFgColor,
      numericValue: numericValue ?? this.numericValue,
      previousNumericValue: previousNumericValue ?? this.previousNumericValue,
    );
  }
}
