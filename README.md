# thinking_analytics

The Official Thinking Analytics Flutter plugin. Used to track events and user properties to [Thinking Analytics](https://www.thinkingdata.cn).

## Getting Started

To use this plugin, add `thinking_analytics` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

Find the APP ID and Server URL from your Thinking Analytics project settings and TA cluster administrator.

Import `package:thinking_analytics/thinking_analytics.dart`, and get an instance of `ThinkingAnalyticsAPI` with your APP ID and Server URL.

In the example below - replace the string `APP_ID` and `SERVER_URL` with your own APP ID and Server URL.

In addition, several named parameters are allowed to be passed to the getInstance function for additional options, including:
* timeZone: default timeZone in native for serializing date to string of required format.
* mode: [ThinkingAnalyticsMode]. Currently we support 3 modes including normal, debug, and debug only.

### Example

```dart
import 'package:thinking_analytics/thinking_analytics.dart';


Future<void> example() async {
  final ThinkingAnalyticsAPI ta = await ThinkingAnalyticsAPI.getInstance('APP_ID', 'https://SERVER_URL');

  // optional. set your own distinct ID as an anonymous ID
  ta.identify('you distinct ID');

  // optional. set account ID for the user
  ta.login('the account ID');

  // track an simple event.
  ta.track('example_event');

  // track an event with properties
  ta.track('another_event', properties: <String, dynamic>{
    'PROP_INT': 5678,
    'PROP_DOUBLE': 12.3,
    'PROP_DATE': DateTime.now(),
    'PROP_LIST': ['apple', 'ball', 1234],
    'PROP_BOOL': false,
    'PROP_STRING': 'flutter test',
    });

  // set user properties
  ta.userSet(<String, dynamic>{
    'USER_INT': 1,
    'USER_DOUBLE': 50.12,
    'USER_LIST': ['apple', 'ball', 'cat', 1, DateTime.now().toUtc()],
    'USER_BOOL': true,
    'USER_STRING': 'a user value',
    'USER_DATE': DateTime.now(),
    });

  // optional. post local data to server immediately
  ta.flush();
}
```
