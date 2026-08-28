import 'package:flutter/material.dart';

Page<T> platformPage<T>({
  required Widget child,
  required LocalKey pageKey,
  required String screenName,
}) => MaterialPage(child: child, key: pageKey, name: screenName);
