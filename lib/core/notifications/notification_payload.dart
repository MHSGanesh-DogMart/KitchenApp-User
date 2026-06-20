import '../routing/route_names.dart';
import '../utils/logger.dart';

/// Parses an FCM data payload into a route to navigate to.
///
/// Backend should send `data` like:
///   { "type": "order", "id": "123" }
///   { "type": "chat", "id": "u_42" }
class NotificationPayload {
  const NotificationPayload({required this.route, this.args});
  final String route;
  final Object? args;

  static NotificationPayload? parse(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return null;
    try {
      final type = (data['type'] ?? '').toString();
      final id = data['id']?.toString();
      switch (type) {
        case 'notifications':
          return const NotificationPayload(route: RouteNames.notifications);
        case 'order':
        case 'detail':
        case 'item':
          return NotificationPayload(route: RouteNames.detail, args: {'id': id});
        case 'chat':
          return NotificationPayload(route: RouteNames.detail, args: {'chatId': id});
        default:
          AppLogger.w('Unknown notification type: $type');
          return null;
      }
    } catch (e) {
      AppLogger.e('Notification payload parse error', e);
      return null;
    }
  }
}
