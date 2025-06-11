import 'package:thinking_analytics/td_analytics.dart';

class TDAnalyticsClone {
  static void init(TDConfig config) {
    TDAnalytics.initWithConfig(config);
  }

  static void track(String eventName, Map<String, dynamic> p) {
    TDAnalytics.track(eventName, properties: p);
  }
}
