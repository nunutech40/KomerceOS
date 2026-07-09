import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/services/logout_cleanup_service.dart';

class FirebaseLogoutCleanupService implements LogoutCleanupService {
  final FirebaseMessaging firebaseMessaging;

  FirebaseLogoutCleanupService({FirebaseMessaging? firebaseMessaging})
      : firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  @override
  Future<void> cleanup() async {
    await firebaseMessaging.deleteToken();
  }
}
