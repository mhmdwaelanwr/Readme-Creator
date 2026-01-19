import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Safe wrapper around showDialog that ensures the [context] is mounted and
/// that a Navigator exists before opening the dialog.
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
        barrierColor: Colors.black.withAlpha(100),
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

class StyledDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget>? actions;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry contentPadding;

  const StyledDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.width,
    this.height,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 0, 24, 24),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width ?? 500,
          height: height,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.black.withAlpha(150) 
                      : Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withAlpha(30) 
                        : Colors.white.withAlpha(100),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: title,
                    ),
                    Flexible(
                      child: Padding(
                        padding: contentPadding,
                        child: SizedBox(
                          width: double.infinity,
                          child: content,
                        ),
                      ),
                    ),
                    if (actions != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DialogHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;

  const DialogHeader({super.key, required this.title, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = color ?? AppColors.primary;

    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withAlpha(60),
                  primaryColor.withAlpha(20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primaryColor.withAlpha(40),
              ),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 22,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.color,
    this.opacity = 0.05,
    this.borderRadius = 16,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = color ?? (isDark ? Colors.white : Colors.black);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: baseColor.withAlpha((opacity * 255).toInt()),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: baseColor.withAlpha(20),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
