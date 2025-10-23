import 'package:flutter/material.dart';

/// Predefined spacing sizes for consistent UI spacing (4-unit steps)
enum SpacingSize {
  /// 4.0
  spacing4(4),

  /// 8.0
  spacing8(8),

  /// 12.0
  spacing12(12),

  /// 16.0
  spacing16(16),

  /// 20.0
  spacing20(20),

  /// 24.0
  spacing24(24),

  /// 28.0
  spacing28(28),

  /// 32.0
  spacing32(32),

  /// 36.0
  spacing36(36),

  /// 40.0
  spacing40(40),

  /// 44.0
  spacing44(44),

  /// 48.0
  spacing48(48),

  /// 52.0
  spacing52(52),

  /// 56.0
  spacing56(56),

  /// 60.0
  spacing60(60),

  /// 64.0
  spacing64(64);

  const SpacingSize(this.value);

  final double value;
}
