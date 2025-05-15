import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  final bool darkMode;
  final bool notificationsEnabled;
  final bool autoPlayVideos;
  final String language;
  final String fontSize;
  final bool dataSaver;
  final bool locationEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  UserSettings({
    required this.darkMode,
    required this.notificationsEnabled,
    required this.autoPlayVideos,
    required this.language,
    required this.fontSize,
    required this.dataSaver,
    required this.locationEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'dark_mode': darkMode,
      'notifications_enabled': notificationsEnabled,
      'auto_play_videos': autoPlayVideos,
      'language': language,
      'font_size': fontSize,
      'data_saver': dataSaver,
      'location_enabled': locationEnabled,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      darkMode: map['dark_mode'] ?? false,
      notificationsEnabled: map['notifications_enabled'] ?? true,
      autoPlayVideos: map['auto_play_videos'] ?? true,
      language: map['language'] ?? 'zh_CN',
      fontSize: map['font_size'] ?? 'medium',
      dataSaver: map['data_saver'] ?? false,
      locationEnabled: map['location_enabled'] ?? true,
      soundEnabled: map['sound_enabled'] ?? true,
      vibrationEnabled: map['vibration_enabled'] ?? true,
    );
  }

  factory UserSettings.defaultSettings() {
    return UserSettings(
      darkMode: false,
      notificationsEnabled: true,
      autoPlayVideos: true,
      language: 'zh_CN',
      fontSize: 'medium',
      dataSaver: false,
      locationEnabled: true,
      soundEnabled: true,
      vibrationEnabled: true,
    );
  }

  UserSettings copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? autoPlayVideos,
    String? language,
    String? fontSize,
    bool? dataSaver,
    bool? locationEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return UserSettings(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoPlayVideos: autoPlayVideos ?? this.autoPlayVideos,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      dataSaver: dataSaver ?? this.dataSaver,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = toMap();
    for (var entry in map.entries) {
      if (entry.value is bool) {
        await prefs.setBool(entry.key, entry.value as bool);
      } else if (entry.value is String) {
        await prefs.setString(entry.key, entry.value as String);
      }
    }
  }

  static Future<UserSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSettings.fromMap({
      'dark_mode': prefs.getBool('dark_mode'),
      'notifications_enabled': prefs.getBool('notifications_enabled'),
      'auto_play_videos': prefs.getBool('auto_play_videos'),
      'language': prefs.getString('language'),
      'font_size': prefs.getString('font_size'),
      'data_saver': prefs.getBool('data_saver'),
      'location_enabled': prefs.getBool('location_enabled'),
      'sound_enabled': prefs.getBool('sound_enabled'),
      'vibration_enabled': prefs.getBool('vibration_enabled'),
    });
  }
}
