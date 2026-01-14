import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

/// خدمة إدارة الاتصال بالإنترنت (بدون connectivity_plus)
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  bool _isConnected = false;
  Timer? _connectionCheckTimer;
  DateTime? _lastCheckTime;

  // قائمة الخوادم للفحص
  static const List<String> _checkServers = [
    '8.8.8.8', // Google DNS
    '1.1.1.1', // Cloudflare DNS
    'google.com', // Google
    'cloudflare.com', // Cloudflare
  ];

  /// Stream لحالة الاتصال
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// الحالة الحالية للاتصال
  bool get isConnected => _isConnected;

  /// تهيئة الخدمة
  Future<void> initialize() async {
    // التحقق من الحالة الأولية
    await checkConnection();

    // بدء فحص دوري للاتصال
    _startPeriodicConnectionCheck();
  }

  /// التحقق من حالة الاتصال بطريقة محسنة
  Future<bool> checkConnection() async {
    try {
      // تجنب الفحص المتكرر خلال 5 ثواني
      if (_lastCheckTime != null &&
          DateTime.now().difference(_lastCheckTime!).inSeconds < 5) {
        return _isConnected;
      }

      _lastCheckTime = DateTime.now();

      // محاولة الاتصال بعدة خوادم
      for (final server in _checkServers) {
        try {
          final result = await _lookupWithTimeout(server);
          if (result) {
            _updateConnectionStatus(true);
            return true;
          }
        } catch (_) {
          // تجربة الخادم التالي
          continue;
        }
      }

      // إذا فشلت جميع المحاولات
      _updateConnectionStatus(false);
      return false;
    } catch (e) {
      print('Error checking connection: $e');
      _updateConnectionStatus(false);
      return false;
    }
  }

  /// البحث عن عنوان مع timeout
  Future<bool> _lookupWithTimeout(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on TimeoutException {
      return false;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// تحديث حالة الاتصال
  void _updateConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectionStatusController.add(isConnected);

      // طباعة للتشخيص
      print('Connection status changed: $_isConnected');
    }
  }

  /// التحقق من نوع الاتصال (بديل بسيط)
  Future<ConnectionType> getConnectionType() async {
    if (!await checkConnection()) {
      return ConnectionType.none;
    }

    // يمكنك استخدام NetworkInterface للحصول على معلومات أكثر
    try {
      final interfaces = await NetworkInterface.list();

      for (var interface in interfaces) {
        if (interface.name.toLowerCase().contains('wlan') ||
            interface.name.toLowerCase().contains('wifi') ||
            interface.name.toLowerCase().contains('en0')) {
          return ConnectionType.wifi;
        }
        if (interface.name.toLowerCase().contains('mobile') ||
            interface.name.toLowerCase().contains('cellular') ||
            interface.name.toLowerCase().contains('pdp')) {
          return ConnectionType.mobile;
        }
      }

      return ConnectionType.other;
    } catch (e) {
      return ConnectionType.other;
    }
  }

  /// التحقق من جودة الاتصال
  Future<ConnectionQuality> checkConnectionQuality() async {
    if (!_isConnected) {
      return ConnectionQuality.none;
    }

    try {
      final stopwatch = Stopwatch()..start();

      // استخدام Socket للحصول على وقت الاستجابة الدقيق
      final socket = await Socket.connect(
        '8.8.8.8',
        53, // DNS port
        timeout: const Duration(seconds: 5),
      );

      stopwatch.stop();
      await socket.close();

      final responseTime = stopwatch.elapsedMilliseconds;

      if (responseTime < 50) {
        return ConnectionQuality.excellent;
      } else if (responseTime < 150) {
        return ConnectionQuality.good;
      } else if (responseTime < 500) {
        return ConnectionQuality.fair;
      } else {
        return ConnectionQuality.poor;
      }
    } catch (e) {
      return ConnectionQuality.poor;
    }
  }

  /// اختبار الاتصال بخادم معين
  Future<bool> testConnectionToServer(
    String host, {
    int port = 80,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: timeout,
      );
      await socket.close();
      return true;
    } on TimeoutException {
      return false;
    } on SocketException {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// التحقق من الاتصال بخوادم التطبيق
  Future<bool> checkAppServerConnection() async {
    const servers = [
      {'host': 'api.hggzk.com', 'port': 443}, // HTTPS
      {'host': 'hggzk.com', 'port': 443},
    ];

    for (final server in servers) {
      if (await testConnectionToServer(
        server['host'] as String,
        port: server['port'] as int,
        timeout: const Duration(seconds: 3),
      )) {
        return true;
      }
    }

    return false;
  }

  /// بدء الفحص الدوري للاتصال
  void _startPeriodicConnectionCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        await checkConnection();
      },
    );
  }

  /// إيقاف الفحص الدوري
  void stopPeriodicConnectionCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
  }

  /// إعادة تشغيل الخدمة
  Future<void> restart() async {
    stopPeriodicConnectionCheck();
    _lastCheckTime = null;
    await initialize();
  }

  /// فحص سريع للاتصال (للاستخدام المتكرر)
  Future<bool> quickCheck() async {
    try {
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 1),
      );
      await socket.close();
      _updateConnectionStatus(true);
      return true;
    } catch (_) {
      _updateConnectionStatus(false);
      return false;
    }
  }

  /// إغلاق الخدمة
  void dispose() {
    stopPeriodicConnectionCheck();
    _connectionStatusController.close();
  }
}

/// أنواع الاتصال
enum ConnectionType {
  none,
  wifi,
  mobile,
  ethernet,
  other,
}

/// جودة الاتصال
enum ConnectionQuality {
  none,
  poor,
  fair,
  good,
  excellent,
}

/// امتداد لجودة الاتصال
extension ConnectionQualityExtension on ConnectionQuality {
  String get displayName {
    switch (this) {
      case ConnectionQuality.none:
        return 'لا يوجد اتصال';
      case ConnectionQuality.poor:
        return 'اتصال ضعيف';
      case ConnectionQuality.fair:
        return 'اتصال مقبول';
      case ConnectionQuality.good:
        return 'اتصال جيد';
      case ConnectionQuality.excellent:
        return 'اتصال ممتاز';
    }
  }

  bool get isConnected {
    return this != ConnectionQuality.none;
  }

  Color get color {
    switch (this) {
      case ConnectionQuality.none:
        return Colors.red;
      case ConnectionQuality.poor:
        return Colors.orange;
      case ConnectionQuality.fair:
        return Colors.yellow;
      case ConnectionQuality.good:
        return Colors.lightGreen;
      case ConnectionQuality.excellent:
        return Colors.green;
    }
  }
}

/// امتداد لنوع الاتصال
extension ConnectionTypeExtension on ConnectionType {
  String get displayName {
    switch (this) {
      case ConnectionType.none:
        return 'غير متصل';
      case ConnectionType.wifi:
        return 'Wi-Fi';
      case ConnectionType.mobile:
        return 'شبكة الجوال';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.other:
        return 'اتصال آخر';
    }
  }

  IconData get icon {
    switch (this) {
      case ConnectionType.none:
        return Icons.signal_wifi_off;
      case ConnectionType.wifi:
        return Icons.wifi;
      case ConnectionType.mobile:
        return Icons.signal_cellular_4_bar;
      case ConnectionType.ethernet:
        return Icons.settings_ethernet;
      case ConnectionType.other:
        return Icons.device_hub;
    }
  }
}
