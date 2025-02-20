import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

Future<T?> showInfoDialog<T>({
  required BuildContext context,
  required String title,
  required String body,
  required String confirmButtonText,
  required VoidCallback? onConfirm,
}) async {
  final Widget result = Padding(
    padding: const EdgeInsets.all(30),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
      child: Container(
        decoration: BoxDecoration(
          color: context.themeData.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  title,
                  style: context.typography?.title5.copyWith(
                    color: context.themeData.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Flexible(
                child: Text(
                  body,
                  style: context.typography?.body5.copyWith(
                    color: context.themeData.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: Align(
                  heightFactor: 1,
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onConfirm,
                    child: Text(
                      confirmButtonText,
                      style: context.typography?.body4.copyWith(
                        fontWeight: FontWeight.w500,
                        color:
                            onConfirm != null
                                ? context.themeData.colorScheme.onSurface
                                : context.themeData.colorScheme.onSurface
                                    .withValues(alpha: 0.28),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  return showCustomGeneralDialog<T>(
    context: context,
    content: result,
    barrierColor: context.themeData.defaultScrim,
    barrierDismissible: false,
  );
}
