import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Konfigurasi Firebase
        FirebaseApp.configure()
        print("Firebase configured in iOS")
        GeneratedPluginRegistrant.register(with: self)
        
        // Delegate untuk notifikasi
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        // Daftar notifikasi remote
        application.registerForRemoteNotifications()
        
        // Delegate Firebase Messaging
        Messaging.messaging().delegate = self
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Handle notifikasi saat aplikasi di foreground
    @available(iOS 10.0, *)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("Foreground notification received: \(notification.request.content.userInfo)")
        completionHandler([.alert, .badge, .sound])
    }
    
    // Handle notifikasi saat user berinteraksi
    @available(iOS 10.0, *)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped: \(userInfo)")
        
        if let screen = userInfo["screen"] as? String, let invoiceCode = userInfo["invoice_code"] as? String {
            let controller = window?.rootViewController as? FlutterViewController
            let channel = FlutterMethodChannel(
                name: "notification_navigation",
                binaryMessenger: controller!.binaryMessenger
            )
            channel.invokeMethod("navigate", arguments: ["screen": screen, "invoiceCode": invoiceCode])
        }
        completionHandler()
    }
    
    // Saat APNs token diterima
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs Token: \(tokenString)")
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("FCM Token is nil")
            return
        }
        print("FCM Token: \(fcmToken)")
    }
}
