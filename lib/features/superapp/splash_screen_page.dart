import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/common/convert_string_to_map.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/features/home/bloc/home_page_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../common/global/bloc/auth/auth_bloc.dart';
import '../../common/global/router/app_router.dart';
import '../../common/global/router/router_utils.dart';
import '../../core/data/datasources/preferences/shared_pref.dart';
import '../../core/domain/entities/auth_state.dart';
import '../../firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_kom');

const InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  if (message.notification != null) {
    if (message.data['data'] != null) {
      await _showNotificationFromBackgroundMessage(message);
    }
  }
}

Future<void> _showNotificationFromBackgroundMessage(
    RemoteMessage message) async {
  final notification = message.notification;
  Map<String, dynamic> data = message.data;
  if (notification != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('high_importance_channel', 'channel_id',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode, // Notification ID
      notification.title ?? '',
      notification.body ?? '',
      platformChannelSpecifics,
      payload: data.toString(),
    );
  }
}

class SplashCreenPage extends StatefulWidget {
  const SplashCreenPage({super.key});

  @override
  State<SplashCreenPage> createState() => _SplashCreenPageState();
}

class _SplashCreenPageState extends State<SplashCreenPage> {
  final pref = di.locator<SharedPref>();
  String versiLocal = '';
  String versionRemote = '';
  String versionRemoteIos = '';
  String typeUpdate = '';
  bool initialized = false;
  bool isgreater = false;
  var _bloc;
  String? statusAccount = "";
  int kmPoint = 0;
  List<dynamic> listInvoices = [];
  //Withdrawal
  String checktransaction = "withdrawal";
  String checkStatusWithdraw = "";

  @override
  void initState() {
    super.initState();
    _initializeBloc();
    startSplashScreen();
  }

  void _initializeBloc() {
    _bloc = context.read<HomePageBloc>();
  }

  void handleNotificationClick(NotificationResponse data) {
    String? dataN = data.payload;
    if (dataN != null) {
      Map<String, dynamic> data = parseStringToMap(dataN);
      String? target = data['target_id'];
      String? type = data['type'];
      if (type == null) {
        String? invoice = data['invoice_code'];
        AppRouter.router.pushNamed(
          PAGES.invoiceReportSummary.screenName,
          queryParameters: {'invoiceCode': invoice},
        );
      } else {
        AppRouter.router.push(PAGES.feeddetail.screenPath, extra: target);
      }
    }
  }

  Future<void> initialFirebase() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final fcmToken = await FirebaseMessaging.instance.getToken();
    await pref.saveFcmToken(fcmToken ?? '');

    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) {})
        .onError((err) {});

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        handleNotificationClick(response);
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max, // Set importance as a named argument
    );

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // handleNotificationClick(initialMessage);
      // handleNotificationClickTest(initialMessage);
      handleNotificationClick(NotificationResponse(
        payload: initialMessage.data.toString(),
        notificationResponseType: NotificationResponseType.selectedNotification,
      ));
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(NotificationResponse(
        payload: message.data.toString(),
        notificationResponseType: NotificationResponseType.selectedNotification,
      ));
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotificationFromBackgroundMessage(message);
    });
  }

  Future<void> startSplashScreen() async {
    await _fetchRemoteConfig();
    await initialFirebase();
  }

  Future<void> _fetchRemoteConfig() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval:
          const Duration(hours: 1), //change to 12 hour when to prod
    ));

    await remoteConfig.fetchAndActivate();
    versionRemote = remoteConfig.getString('version');
    versionRemoteIos = remoteConfig.getString('versionIos');
    typeUpdate = remoteConfig.getString('type');
    await pref.saveRemoteVersion(versionRemote);
    await _getVersionLocale();
  }

  Future<void> _getVersionLocale() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versiLocal = packageInfo.version;
    if (Platform.isIOS) {
      await _performSplashScreenLogic(versionRemoteIos, versiLocal);
    } else {
      await _performSplashScreenLogic(versionRemote, versiLocal);
    }
  }

  Future<void> isRemoteGreater(String remote, String local) async {
    int versionA = int.parse(remote.replaceAll('.', ''));
    int versionB = int.parse(local.replaceAll('.', ''));

    if (versionA > versionB) {
      isgreater = true;
    } else if (versionA == versionB) {
      isgreater = false;
    } else {
      isgreater = false;
    }
  }

  Future<void> _performSplashScreenLogic(String remote, String local) async {
    await Future.delayed(const Duration(seconds: 2));
    await isRemoteGreater(remote, local);

    if (isgreater == true && typeUpdate == 'major') {
      AppRouter.router.go(PAGES.forceUpdatePage.screenPath);
      return;
    }

    // Tunggu AuthBloc selesai cek session sebelum navigasi
    // agar router redirect yang berbasis AuthStatus tidak konflik
    if (!mounted) return;
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state.status == AuthStatus.initial ||
        authBloc.state.status == AuthStatus.checking) {
      await authBloc.stream.firstWhere(
        (s) =>
            s.status != AuthStatus.initial && s.status != AuthStatus.checking,
      );
    }

    // Router sudah reaktif — cukup navigate ke main, redirect akan handle sisanya
    AppRouter.router.go(PAGES.main.screenPath);
  }

  //Handle Check Account
  checkAccountOff(BuildContext context, HomePageState state) {
    //Handle when partner off dont have invoice and kmpoint 0
    if (state.statusCheckTopup == RequestStatus.success &&
        checktransaction == 'withdrawal') {
      checkStatusWithdraw = "withdrawal proses";
    } else if (state.statusCheckTopup == RequestStatus.empty &&
        checktransaction == 'withdrawal') {
      checkStatusWithdraw = "empty";
    }
    if (statusAccount == "off" &&
        listInvoices.isEmpty &&
        kmPoint < 1 &&
        checkStatusWithdraw == "withdrawal proses") {
      _bloc.add(const LogoutButtonPressedEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomePageBloc, HomePageState>(
        listener: (context, state) {
          if (state.status == RequestStatus.success &&
              state.operation == 'getProfile') {
            //Handle Null Safety KMPOIN
            kmPoint = state.profileData?.kmPoin ?? 0;
            statusAccount = state.profileData?.accountStatus;
          }
          if (state.invoicesData.isNotEmpty && listInvoices.isEmpty) {
            listInvoices.addAll(state.invoicesData);
          }
          checkAccountOff(context, state);
        },
        builder: (context, state) {
          return Container(
            color: Colors.white,
            child: Center(
              // FractionallySizedBox → lebar 60% layar (responsive di semua device)
              // AspectRatio → jaga proporsi asli logo 227:61 tanpa overflow
              child: FractionallySizedBox(
                widthFactor: 0.6,
                child: AspectRatio(
                  aspectRatio: 227 / 61,
                  child: SvgPicture.asset(
                    'assets/images/superapp/logo_splash_screen.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
