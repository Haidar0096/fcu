import 'package:{{proj_name}}/variables/variables.dart';
import 'package:{{proj_name}}/infrastructure/logging/logging.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';

class CustomNetworkImageImpl extends CustomNetworkImage {
  CustomNetworkImageImpl({
    required super.imageUrl,
    super.key,
    super.width,
    super.height,
    super.fit,
    super.placeholderFit,
    super.errorWidgetFit,
    super.placeholderBorderRadius,
    super.errorWidgetBorderRadius,
  });

  @override
  void Function(Object) get errorListener => _errorListener;

  void _errorListener(Object error) {
    final message = 'Error loading network image from $imageUrl';
    serviceProvider.get<EventLogger>().recordEvent(
      message: message,
      stackTrace: StackTrace.current,
      level: EventLoggerLevel.error,
    );
    serviceProvider.get<AppLogger>().log(message);
  }
}
