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
      '${dotenv.env["BASE_URL"]}auth'; 

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? androidPlatformChannelSpecifics =
        message.notification?.android; 

    const String channelId =
        'rfc_apps_default_channel'; 
    const String channelName =
        'Notifikasi Umum'; 
    const String channelDescription =
        'Channel untuk notifikasi umum aplikasi RFC Apps'; 

    
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max, 
      priority: Priority.high,
      ticker: 'ticker',
      icon: androidPlatformChannelSpecifics?.smallIcon ??
          '@drawable/ic_notification', 
      
    );

    
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS:
          darwinNotificationDetails, 
    );

    if (notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode, 
        notification.title,
        notification.body,
        notificationDetails,
        payload: jsonEncode(message.data), 
      );
    }
  }

  void _handleMessage(RemoteMessage message, {bool fromTerminated = false}) {
    if (message.notification != null) {
    }

    final String? notificationType =
        message.data['notificationType'] as String?;

    if (notificationType == 'ORDER_STATUS_UPDATE') {
      final String? orderId =
          message.data['pesananId'] as String?; 
      if (orderId != null && orderId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState
              ?.pushNamed('/order_details', arguments: orderId);
        });
      } else {;
      }
    } else if (notificationType == 'PROMO_BARU') {
      final String? promoId = message.data['promoId'] as String?;
      if (promoId != null) {
      }
    }
  }

  Future<void> setupMessageListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
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
          try {
            Map<String, dynamic> data =
                Map<String, dynamic>.from(jsonDecode(payload));
            RemoteMessage dummyMessage = RemoteMessage(data: data);
            _handleMessage(dummyMessage);
          } catch (e) {
          }
        }
      },
      
    );
    await requestNotificationPermission();
    handleTokenRefresh();
    await setupMessageListeners();
  }

  Future<void> _sendFcmTokenToBackend(String fcmToken,
      {bool isRetry = false}) async {
    try {
      final accessToken = await tokenService().getAccessToken();

      if (accessToken == null) {
        return; 
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/fcmToken'), 
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, String>{
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
      } else if (response.statusCode == 401 && !isRetry) {
        await tokenService().refreshToken(); 
        await _sendFcmTokenToBackend(fcmToken,
            isRetry: true); 
      } else {
      }
    } catch (e) {
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
      
      
      await getAndInitialSendFcmToken();
    } else {
    }
  }

  Future<void> getAndInitialSendFcmToken() async {
    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await _sendFcmTokenToBackend(fcmToken);
      } else {
      }
    } catch (e) {
    }
  }

  void handleTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newFcmToken) {
      _sendFcmTokenToBackend(newFcmToken);
    });
  }

  void initializeTokenManagement() {
    handleTokenRefresh();
  }
}
