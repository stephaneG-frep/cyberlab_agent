import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Réglage du rappel quotidien (désactivé par défaut).
class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;
  const ReminderSettings({
    this.enabled = false,
    this.hour = 19,
    this.minute = 0,
  });

  factory ReminderSettings.fromJson(Object? raw) {
    if (raw is! Map) return const ReminderSettings();
    int clampInt(Object? v, int max, int fallback) =>
        v is int && v >= 0 && v <= max ? v : fallback;
    return ReminderSettings(
      enabled: raw['enabled'] == true,
      hour: clampInt(raw['hour'], 23, 19),
      minute: clampInt(raw['minute'], 59, 0),
    );
  }

  Map<String, Object> toJson() => {
    'enabled': enabled,
    'hour': hour,
    'minute': minute,
  };

  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Planification pure (testable) : premier rappel à l'heure choisie,
/// aujourd'hui si l'heure n'est pas passée ET qu'aucune activité n'a encore
/// eu lieu aujourd'hui, sinon demain. Le rappel se répète ensuite chaque
/// jour ; il est replanifié à chaque ouverture et à chaque activité, ce qui
/// saute le jour où l'on a déjà pratiqué.
DateTime nextReminder(
  ReminderSettings s, {
  required DateTime now,
  required bool activeToday,
}) {
  final today = DateTime(now.year, now.month, now.day, s.hour, s.minute);
  if (!activeToday && today.isAfter(now)) return today;
  return DateTime(now.year, now.month, now.day + 1, s.hour, s.minute);
}

/// Texte du rappel, sans chiffre qui pourrait devenir faux entre deux
/// replanifications.
({String title, String body}) reminderText({required bool hasStreak}) => (
  title: 'CyberLab Agent',
  body: hasStreak
      ? 'Prolongez votre série : un quiz, un CTF ou une alerte SOC suffisent.'
      : 'Une petite session cyber aujourd\'hui ? Quelques minutes suffisent.',
);

/// Planificateur de notifications (injectable pour les tests).
abstract class ReminderScheduler {
  /// Demande l'autorisation d'afficher des notifications (Android 13+).
  Future<bool> requestPermission();

  /// Programme un rappel quotidien à partir de [first] (remplace l'ancien).
  Future<void> scheduleDaily(DateTime first, String title, String body);

  Future<void> cancel();
}

/// Implémentation Android : notification LOCALE (aucun serveur, aucune
/// donnée envoyée), horaire approximatif (pas d'alarme exacte : aucune
/// permission sensible). Replanifiée après un redémarrage du téléphone.
class LocalReminderScheduler implements ReminderScheduler {
  static const _id = 1001;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  Future<void> _init() => _ready ??= () async {
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fuseau inconnu : l'heure du premier rappel reste juste (instant
      // absolu), seule la répétition peut dériver d'une heure au
      // changement d'heure.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> requestPermission() async {
    await _init();
    return await _android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> scheduleDaily(DateTime first, String title, String body) async {
    await _init();
    await _plugin.cancel(id: _id);
    await _plugin.zonedSchedule(
      id: _id,
      scheduledDate: tz.TZDateTime.from(first, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Rappel quotidien',
          channelDescription:
              'Un rappel par jour pour garder le rythme d\'apprentissage.',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel() async {
    await _init();
    await _plugin.cancel(id: _id);
  }
}

/// Implémentation en mémoire (tests).
class MemoryReminderScheduler implements ReminderScheduler {
  MemoryReminderScheduler({this.grantPermission = true});
  bool grantPermission;
  DateTime? scheduled;
  String? body;
  int cancels = 0;

  @override
  Future<bool> requestPermission() async => grantPermission;

  @override
  Future<void> scheduleDaily(DateTime first, String title, String b) async {
    scheduled = first;
    body = b;
  }

  @override
  Future<void> cancel() async {
    scheduled = null;
    cancels++;
  }
}
