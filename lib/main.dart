import 'package:flutter/material.dart';
import 'package:hedieaty/home_page.dart';
import 'package:hedieaty/login_page.dart';
import 'package:hedieaty/theme_data.dart';
import 'package:hedieaty/profile_page.dart';
import 'package:hedieaty/eventList_page.dart';
import 'package:hedieaty/giftList_page.dart';
import 'package:hedieaty/giftDetails_page.dart';
import 'package:hedieaty/splash_screen.dart';
import 'package:hedieaty/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'MyPledgedGifts.dart';
import 'firebase_options.dart';
import 'package:hedieaty/createEvent.dart';
import 'package:hedieaty/editEvent_page.dart';
import 'package:hedieaty/editGift_page.dart';
import 'friend_Event.dart';
import 'friend_gifts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined permission');
  }
}
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  print('Received foreground message: ${message.notification?.title}');
  if (message.notification != null) {
    // Show local notification
    await _showNotification(message);
  }
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
requestPermission();
  // Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // You can also add notification foreground listener here if needed
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a foreground message: ${message.notification?.title}');
    if (message.notification != null) {
      // Handle foreground notification here (e.g., show a local notification)
    }
  });
  // Initialize Local Notifications
  var initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Set foreground message handler
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);


  runApp(MyApp());
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.notification?.title}');
  // Handle the background message here (e.g., show a local notification)
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Hedieaty",
      theme: ThemeClass.lightTheme,
      initialRoute: '/Splash',
      routes: {
        "/Splash":(context)=> SplashScreen(),
        '/home':(context)=>HomePage(),
        '/Profile':(context)=> MyProfile(),
        '/EventList':(context)=>EventListPage(),
        '/GiftList':(context)=>GiftListPage(),
        '/GiftDetailsList':(context)=>CreateGift(eventId: '',userId:''),
        '/signup':(context)=>SignUpPage(),
        '/login':(context)=>LoginPage(),
        '/createEvent':(context)=>CreateEvent(),
        '/editEvent': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EditEvent(eventId: args['eventId']);
        },
        '/editgift': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return EditGift(
            eventId: args['eventId']!,
            giftId: args['giftId']!,
          );
        },
        '/friend_event':(context)=>FriendEventPage(),
        '/friend_gifts':(context)=>FriendGiftListPage(),
        // '/offlineEventlsit':(context)=>OfflineEventListPage(userId: '',),
        '/pledged_gifts':(context)=>MyPledgedGiftsPage(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hedieaty"),
        ),
      ),
    );
  }
}
