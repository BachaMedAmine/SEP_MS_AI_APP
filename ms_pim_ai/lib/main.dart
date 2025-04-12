import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.notification?.title} - ${message.notification?.body}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize local notifications
  await _initializeLocalNotifications();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permissions for iOS
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

// Initialize local notifications for both Android and iOS
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MS_PIM_AI Health Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        appBarTheme: const AppBarTheme(
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HealthDashboard(),
    );
  }
}

Future<void> sendHealthDataForPrediction(List<double> healthData, BuildContext context) async {
  const url = "http://192.168.100.7:4000/predict";
  print("Sending request to Flask server at $url");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "features": healthData,
      }),
    );

    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final label = result["label"];
      final confidence = result["confidence"];
      print("Prediction received: $label ($confidence%)");
      await _showNotification("$label ($confidence%)");

      // Add a fallback alert dialog for debugging
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Prediction Result'),
          content: Text("Prediction: $label ($confidence%)"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print("Failed to get prediction: ${response.statusCode}");
    }
  } catch (e) {
    print("Error sending request to Flask server: $e");
  }
}

Future<void> _showNotification(String message) async {
  print("Attempting to show notification: $message");

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'ms_alerts',
    'MS Relapse Alerts',
    importance: Importance.max,
    priority: Priority.high,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    threadIdentifier: 'ms_alerts',
    subtitle: 'Health Alert',
    sound: 'default',
    badgeNumber: 1,
  );

  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  // Add a small delay to ensure the notification renders
  await Future.delayed(const Duration(milliseconds: 500));

  await flutterLocalNotificationsPlugin.show(
    0,
    'MS Relapse Prediction',
    message,
    details,
  ).then((_) {
    print("Notification displayed successfully");
  }).catchError((error) {
    print("Error displaying notification: $error");
  });
}

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({super.key});

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  final int _selectedIndex = 0;
  String? _fcmToken;

  final List<HealthMetric> _healthMetrics = [
    HealthMetric(
      title: 'Heart Rate',
      value: '82 bpm',
      icon: Icons.favorite,
      color: Colors.red.shade400,
      bgColor: Colors.red.shade50,
    ),
    HealthMetric(
      title: 'HRV',
      value: '65 ms',
      icon: Icons.timeline,
      color: Colors.purple.shade400,
      bgColor: Colors.purple.shade50,
    ),
    HealthMetric(
      title: 'Sleep Score',
      value: '87/100',
      icon: Icons.nightlight_round,
      color: Colors.indigo.shade400,
      bgColor: Colors.indigo.shade50,
    ),
    HealthMetric(
      title: 'Steps',
      value: '8,432',
      icon: Icons.directions_walk,
      color: Colors.green.shade400,
      bgColor: Colors.green.shade50,
    ),
    HealthMetric(
      title: 'Body Temperature',
      value: '36.6 °C',
      icon: Icons.thermostat,
      color: Colors.amber.shade400,
      bgColor: Colors.amber.shade50,
    ),
    HealthMetric(
      title: 'SpO₂',
      value: '98%',
      icon: Icons.air,
      color: Colors.lightBlue.shade400,
      bgColor: Colors.lightBlue.shade50,
    ),
    HealthMetric(
      title: 'Stress Level',
      value: '32/100',
      icon: Icons.bolt,
      color: Colors.orange.shade400,
      bgColor: Colors.orange.shade50,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize Firebase Messaging
    _initializeFirebaseMessaging();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received foreground message: ${message.notification?.title} - ${message.notification?.body}");
      _showNotification("${message.notification?.title}: ${message.notification?.body}");
    });

    // Handle message when the app is opened from a terminated state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message opened app: ${message.notification?.title} - ${message.notification?.body}");
    });
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Wait for APNS token on iOS
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      String? apnsToken;
      int attempts = 0;
      const maxAttempts = 10;

      while (apnsToken == null && attempts < maxAttempts) {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          print("APNS token not available yet, retrying in 1 second...");
          await Future.delayed(const Duration(seconds: 1));
          attempts++;
        }
      }

      if (apnsToken == null) {
        print("Failed to get APNS token after $maxAttempts attempts.");
        return;
      }
      print("APNS token received: $apnsToken");
    }

    // Now safe to get FCM token
    try {
      _fcmToken = await FirebaseMessaging.instance.getToken();
      print("FCM Token: $_fcmToken");
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  List<double> _getHealthData() {
    final data = [
      double.parse(_healthMetrics[0].value.replaceAll(' bpm', '')), // Heart Rate
      double.parse(_healthMetrics[1].value.replaceAll(' ms', '')), // HRV
      double.parse(_healthMetrics[2].value.split('/')[0]), // Sleep Score
      double.parse(_healthMetrics[3].value.replaceAll(',', '')), // Steps
      double.parse(_healthMetrics[4].value.replaceAll(' °C', '')), // Body Temperature
      double.parse(_healthMetrics[5].value.replaceAll('%', '')), // SpO₂
      double.parse(_healthMetrics[6].value.split('/')[0]), // Stress Level
    ];
    print("Health data collected: $data");
    return data;
  }

  void _predictRelapse(BuildContext context) async {
    final healthData = _getHealthData();
    print("Sending health data to Flask server: $healthData");
    await sendHealthDataForPrediction(healthData, context);
  }

  void _testNotification() async {
    await _showNotification("Test Notification (100%)");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _buildHealthMetricsGrid(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _predictRelapse(context),
                  child: const Text('Predict MS Relapse'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _testNotification,
                  child: const Text('Test Notification'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue.shade500,
            Colors.lightBlue.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'MS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF0369A1),
              child: Text(
                'MS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _healthMetrics.length,
      itemBuilder: (context, index) {
        return _buildMetricCard(_healthMetrics[index], index);
      },
    );
  }

  Widget _buildMetricCard(HealthMetric metric, int index) {
    return Hero(
      tag: 'metric-$index',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 500 + (index * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Card(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: metric.bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      metric.icon,
                      color: metric.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    metric.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HealthMetric {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  HealthMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}