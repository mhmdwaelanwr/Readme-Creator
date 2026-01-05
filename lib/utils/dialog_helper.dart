import 'dart:async';
import 'package:flutter/material.dart';

/// Safe wrapper around showDialog that ensures the [context] is mounted and
/// that a Navigator exists before opening the dialog. It schedules the
/// dialog show to the next frame to avoid calling into the widget tree during
/// a build scope which can cause "dirty widget in the wrong build scope" errors.
Future<T?> showSafeDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool useRootNavigator = false,
  bool barrierDismissible = true,
}) {
  if (!context.mounted) return Future.value(null);

  final navigator = Navigator.maybeOf(context);
  if (navigator == null) return Future.value(null);

  final completer = Completer<T?>();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) {
      completer.complete(null);
      return;
    }
    try {
      showDialog<T>(
        context: context,
        builder: builder,
        useRootNavigator: useRootNavigator,
        barrierDismissible: barrierDismissible,
      ).then((value) {
        if (!completer.isCompleted) completer.complete(value);
      }).catchError((e) {
        if (!completer.isCompleted) completer.complete(null);
      });
    } catch (e) {
      if (!completer.isCompleted) completer.complete(null);
    }
  });

  return completer.future;
}

