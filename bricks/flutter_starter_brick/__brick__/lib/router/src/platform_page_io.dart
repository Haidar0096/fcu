import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Page<T> platformPage<T>({
  required Widget child,
  required LocalKey pageKey,
  required String screenName,
}) {
  if (Platform.isIOS || Platform.isMacOS) {
    return CupertinoPage(child: child, key: pageKey, name: screenName);
  }
  return MaterialPage(child: child, key: pageKey, name: screenName);
}
