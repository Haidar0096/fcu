import 'package:flutter/material.dart';

/// The fixed project spacing scale.
enum SpacingSize {
  /// 4.0
  spacing4(4),

  /// 8.0
  spacing8(8),

  /// 16.0
  spacing16(16),

  /// 24.0
  spacing24(24),

  /// 32.0
  spacing32(32);

  const SpacingSize(this.value);

  final double value;
}
