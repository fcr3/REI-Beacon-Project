//
//  AppDelegate.swift
//  REI Employee App
//
//  Created by Flaviano Reyes on 6/16/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseAuth
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var currentApp : UIApplication!
    let realm = try! Realm()
    var emp : employee!
    var db : DatabaseReference!
    let gcmMessageIDKey = "gcm.message_id"
    var refreshedToken : Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Pre-configuration steps
        currentApp = application
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        configureFirebaseAndNotifications(application)
        db = Database.database().reference().child("Clients")
        
        // COMMENT FOR TESTING PURPOSES
        // Grabbing existing employee data if it exists
        let empArray : Results<employee>? = realm.objects(employee.self)
        if empArray == nil || !empArray!.isEmpty {
            if empArray![0].isInvalidated || empArray![0].email == "" || empArray![0].password == "" {
                do {
                    try self.realm.write {realm.deleteAll()}
                    return true
                } catch {print(error)}
            } else {
                self.logIn(email: empArray![0].email, password: empArray![0].password)
            }
        } else {
            showNotification(with : "Greetings from the REI!",
                             body: "Please enter your employee login to use this application!")
        }
        
        return true
    }
    
    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email , password: password) { (user, error) in
            if let err = error {
                print(err)
            } else {
                let db = Database.database().reference().child(email.split(separator: ".")[0] + "")
                db.observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String, String> {
                        if snapVal["current"]! == UIDevice.current.identifierForVendor?.uuidString {
                            self.retrieveToken(em: email, pass : password)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Retrieve Token and Topic Posting
    
    func retrieveToken(em email: String, pass password: String) {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let err = error {
                print(err)
            } else {
                self.setNewToken(token: result!.token)
            }
        })
    }
    
    // MARK: - Persistent Database Functions
    
    func setNewToken(token: String) {
        let newEmp = realm.objects(employee.self)[0]
        do {
            try self.realm.write {
                newEmp.token = token
            }
            self.checkExistingData(who: newEmp)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Populate Id Array and Update Employee on Database
    
    func checkExistingData(who emp: employee) {
        let db = Database.database().reference().child("Employees")
        db.child(emp.email.split(separator: ".")[0] + "").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String, String> {
                emp.clientIds.removeAll()
                for id in snapVal["clientIds"]!.split(separator: ",") {
                    emp.clientIds.append(id + "")
                }
                self.update(who: emp)
            }
        }
    }
    
    func update(who emp: employee) {
        let db = Database.database().reference().child("Employees")
        db.child(emp.email.split(separator: ".")[0] + "").setValue(emp.employeeDictionary()) { (error, reference) in
            if let err = error {
                print(err)
            }
        }
    }
    
    // MARK: - Configuring Firebase and Notifications
    
    func configureFirebaseAndNotifications(_ application: UIApplication) {
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().isAutoInitEnabled = true
        
        let center = UNUserNotificationCenter.current()
        application.applicationIconBadgeNumber = 0
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Setting up Push Notifications
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: - Setting up notification alerts
    
    func showNotification(with title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = currentApp.applicationIconBadgeNumber + 1 as NSNumber
        content.sound = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: .none)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("We have an error \(error)")
            }
        }
    }
    
    // MARK: - Extra Functions

    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}

// MARK: - Extra Firebase Notification Setup

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        currentApp.registerForRemoteNotifications()
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        if !refreshedToken {
            refreshedToken = true
            InstanceID.instanceID().deleteID { (error) in
                if let error = error {print(error)}
                else {self.refreshedToken = true}
            }
        }
        
        if Auth.auth().currentUser != nil && !self.realm.objects(employee.self).isEmpty{
            if !self.realm.objects(employee.self)[0].isInvalidated {
                let emp = self.realm.objects(employee.self)[0]
                do {
                    try self.realm.write { emp.token = fcmToken }
                    self.updateToken(token: fcmToken)
                } catch {print(error)}
            }
        }
    }
    
    func updateToken(token: String) {
        let db = Database.database().reference().child("Employees")
        db.child(Auth.auth().currentUser!.email!.split(separator: ".")[0] + "").updateChildValues(["token" : token]) { (error, dbase) in
            if let error = error { print(error) }
        }
    }
    
    // [END refresh_token]
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}
