import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:rfc_apps/service/token.dart';
import 'package:rfc_apps/main.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _baseUrl =
      '${dotenv.env["BASE_URL"]}auth'; // Pindahkan ke sini agar bisa diakses oleh fungsi lain

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? androidPlatformChannelSpecifics =
        message.notification?.android; // Ambil detail Android dari FCM jika ada

    const String channelId =
        'rfc_apps_default_channel'; // Ganti dengan ID channel Anda
    const String channelName =
        'Notifikasi Umum'; // Ganti dengan nama channel Anda
    const String channelDescription =
        'Channel untuk notifikasi umum aplikasi RFC Apps'; // Ganti dengan deskripsi

    // --- 3. Siapkan detail notifikasi untuk Android ---
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max, // Prioritas tertinggi
      priority: Priority.high,
      ticker: 'ticker',
      icon: androidPlatformChannelSpecifics?.smallIcon ??
          '@drawable/ic_notification', // Gunakan ikon dari FCM atau default
      // sound: RawResourceAndroidNotificationSound('nama_file_suara_custom_tanpa_ekstensi'), // Jika punya suara custom di android/app/src/main/res/raw
    );

    // Untuk iOS (meskipun tidak Anda gunakan, ini contoh minimal)
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS:
          darwinNotificationDetails, // Tetap sertakan meskipun tidak dipakai agar tidak error
    );

    // Tampilkan notifikasi
    if (notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode, // ID unik untuk setiap notifikasi
        notification.title,
        notification.body,
        notificationDetails,
        payload: jsonEncode(message.data), // Kirim data FCM sebagai payload
      );
      print(' Lokal Notifikasi ditampilkan: ${notification.title}');
    }
  }

  void _handleMessage(RemoteMessage message, {bool fromTerminated = false}) {
    print('🔔 Pesan diterima! Dari Terminated: $fromTerminated');
    print('   ID Pesan: ${message.messageId}');
    if (message.notification != null) {
      print(
          '   Notifikasi: ${message.notification!.title} - ${message.notification!.body}');
    }
    print('   Data: ${message.data}');

    final String? notificationType =
        message.data['notificationType'] as String?;

    if (notificationType == 'ORDER_STATUS_UPDATE') {
      final String? orderId =
          message.data['pesananId'] as String?; // Ambil pesananId
      if (orderId != null && orderId.isNotEmpty) {
        print('Navigasi ke detail pesanan ID: $orderId');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState
              ?.pushNamed('/order_details', arguments: orderId);
        });
      } else {
        print('⚠️ pesananId tidak ditemukan atau kosong di data notifikasi.');
      }
    } else if (notificationType == 'PROMO_BARU') {
      final String? promoId = message.data['promoId'] as String?;
      if (promoId != null) {
        print('Navigasi ke halaman promo ID: $promoId');
      }
    }
  }

  Future<void> setupMessageListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Pesan diterima saat aplikasi di FOREGROUND:');
      _handleMessage(message);
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 Aplikasi dibuka dari BACKGROUND oleh pesan:');
      _handleMessage(message);
    });

    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 Aplikasi dibuka dari TERMINATED oleh pesan:');
      _handleMessage(initialMessage, fromTerminated: true);
    }
  }
               
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        final String? payload = notificationResponse.payload;
        if (payload != null) {
          print('🔔 Notifikasi LOKAL di-tap, payload: $payload');
          try {
            Map<String, dynamic> data =
                Map<String, dynamic>.from(jsonDecode(payload));
            RemoteMessage dummyMessage = RemoteMessage(data: data);
            _handleMessage(dummyMessage);
          } catch (e) {
            print("Error decoding or handling local notification payload: $e");
          }
        }
      },
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground, // Untuk background isolate (lebih advanced)
    );
    await requestNotificationPermission();
    handleTokenRefresh();
    await setupMessageListeners();
  }

  Future<void> _sendFcmTokenToBackend(String fcmToken,
      {bool isRetry = false}) async {
    try {
      print('🔄 Attempting to send FCM token to backend: $fcmToken');
      final accessToken = await tokenService().getAccessToken();

      if (accessToken == null) {
        print('⚠️ Auth token not found. Cannot send FCM token.');
        return; // Jangan kirim jika tidak ada token otentikasi
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/fcmToken'), // Menggunakan _baseUrl
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, String>{
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM token successfully sent to backend');
      } else if (response.statusCode == 401 && !isRetry) {
        print(
            '⚠️ FCM token send failed (401). Attempting to refresh auth token...');
        await tokenService().refreshToken(); // Coba refresh token otentikasi
        await _sendFcmTokenToBackend(fcmToken,
            isRetry: true); // Coba kirim lagi FCM token, tandai sebagai retry
      } else {
        print('❌ Failed to send FCM token. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM token to backend: $e');
    }
  }

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission for notifications');
      // Jika izin diberikan, langsung coba dapatkan dan kirim token FCM
      // Ini akan mencoba mengirim jika pengguna sudah login (memiliki accessToken)
      await getAndInitialSendFcmToken();
    } else {
      print('❌ User declined or has not accepted permission for notifications');
    }
  }

  Future<void> getAndInitialSendFcmToken() async {
    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        print('🔑 Initial FCM Token: $fcmToken');
        await _sendFcmTokenToBackend(fcmToken);
      } else {
        print('⚠️ Initial FCM Token is null.');
      }
    } catch (e) {
      print('Error getting initial FCM token: $e');
    }
  }

  void handleTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newFcmToken) {
      print('🔄 FCM Token refreshed by system: $newFcmToken');
      _sendFcmTokenToBackend(newFcmToken);
    });
  }

  void initializeTokenManagement() {
    handleTokenRefresh();
  }
}
