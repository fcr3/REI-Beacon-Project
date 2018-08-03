//
//  AppDelegate.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 6/10/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import EstimoteProximitySDK
import Firebase
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate, CBCentralManagerDelegate {

    /* Zones:beetroot - lobby, lemon - elevator, candy - front door */
    
    var window: UIWindow?
    var currentApp : UIApplication!
    var zone1 : ProximityZone!
    var zone2 : ProximityZone!
    var zone3 : ProximityZone!
    let realm = try! Realm()
    
    var manager : CBCentralManager!
    let beaconManager = ESTBeaconManager()
    let proximityObserver = ProximityObserver(
        credentials: CloudCredentials(appID: "rei-beacon-app-iwl", appToken: "1f2ca4468134f76e44478897b3114042"),
        onError: { error in
            print("proximity observer error: \(error)")
        })
    
    //MARK: - Necessary Functions for Configuring App Delegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Setting up Bluetooth Delegate
        manager = CBCentralManager()
        manager.delegate = self
        
        // Beacon Manager
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        beaconManager.stopMonitoringForAllRegions()
        
        // Allowing Notifications to Appear
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        // Assigning application to our own instance var
        currentApp = application
        
        // Initial Setup of Firebase Connection
        FirebaseApp.configure()
        signIn()
        
        if manager.state == .poweredOn {
            settingUpObserver()
            setUpMonitor()
        }
        
        let idArray : Results<idPlaceholder>? = realm.objects(idPlaceholder.self)
        if idArray != nil  && !(idArray?.isEmpty)!{
            if (idArray?[0].isInvalidated)! {
                do {try self.realm.write {self.realm.deleteAll()}}
                catch {print(error)}
            }
        }
        return true
    }
    
    func signIn(_ callback: @escaping () -> Void = {}) {
        if Auth.auth().currentUser != nil {
            Auth.auth().signIn(withEmail: "app@client.com", password: "NUB9JAMJGbkwqBroilwd6sYy") { (result, error) in
                if let error = error {print(error)}
                else {callback()}
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0 // For Clear Badge Counts
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests() // To remove all pending notifications which are not delivered yet but scheduled.
        resetObserver()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        resetObserver()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        showNotification(with : "Waaaiiittt!",
                         body: "I can help you out if you keep me open!")
        
        print(self.realm.isEmpty)
    }
    
    //MARK: - Bluetooth Status Tracking
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.resetObserver()
            break
        case .poweredOff:
            self.proximityObserver.stopObservingZones()
            print("Bluetooth is Off.")
            break
        default:
            break
        }
    }
    
    //MARK: - Estimote Monitoring Functions
    
    func setUpMonitor() {
        self.beaconManager.startMonitoring(for:
            CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
                           major: 34955, minor: 24771, identifier: "lobby"))
        self.beaconManager.startMonitoring(for:
            CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
                           major: 51157, minor: 10938, identifier: "elevator"))
        self.beaconManager.startMonitoring(for:
            CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
                           major: 14314, minor: 26054, identifier: "front door"))
        print("Set Up Monitor")
    }

    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        if region.identifier == "lobby" {
            signIn() { () in self.z1Action(loc: region.identifier)}
            print("Beacon Manager Call Completed")
        }
        if region.identifier == "elevator" {
            signIn() {() in self.z2Action(loc: region.identifier)}
            print("Beacon Manager Call Completed")
        }
        if region.identifier == "front door" {
            signIn() {() in self.z3Action(loc: region.identifier)}
            print("Beacon Manager Call Completed")
        }
    }
    
    //MARK: - Setting up Estimote Observer and Zones
    
    func settingUpObserver() {
        zone1 = ProximityZone(tag: "lobby", range: .far)
        zone2 = ProximityZone(tag: "elevator", range: .far)
        zone3 = ProximityZone(tag: "front door", range: .far)
        settingUpZones(z1 : zone1, z2 : zone2, z3 : zone3)
        self.proximityObserver.startObserving([zone1, zone2, zone3])
        print("Set Up Observer")
    }
    
    func resetObserver() {
        self.proximityObserver.stopObservingZones()
        zone1 = ProximityZone(tag: "lobby", range: .far)
        zone2 = ProximityZone(tag: "elevator", range: .far)
        zone3 = ProximityZone(tag: "front door", range: .far)
        settingUpZones(z1 : zone1, z2 : zone2, z3 : zone3)
        self.proximityObserver.startObserving([zone1, zone2, zone3])
    }
    
    func z1Action(loc : String) {
        if !self.realm.objects(idPlaceholder.self).isEmpty {
            print("delegate z1")
            let idPh = self.realm.objects(idPlaceholder.self)[0]
            if !idPh.isInvalidated {
                let db = Database.database().reference().child("Clients")
                db.child(idPh.id).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String,String> {
                        var visitedLocs = snapVal["visitedLocs"]!
                        
                        if (visitedLocs.lowercased().range(of: loc) == nil) {
                            self.showNotification(with : "REI says Hello! Go to the Elevator!",
                                                  body: "Please proceed through the doors and go the elevator! Open the app for more options!")
                        } else {
                            self.showNotification(with : "Thank You for Coming",
                                                  body: "It was a pleasure! See you again soon!")
                        }
                        
                        visitedLocs = visitedLocs + " \(loc),"
                        db.child(idPh.id).updateChildValues(["loc" : loc, "visitedLocs": visitedLocs]) { (error, dbase) in
                            if let error = error { print(error) }
                        }
                    }
                }
            } else {
                showNotification(with : "Greetings from REI!",
                                 body: "This app can help you navigate to where you want to go!")
            }
        } else {
            showNotification(with : "Greetings from REI!",
                             body: "Please enter your employee login or your client Id to use this application!")
        }
    }
    
    func z1Action(zone : ProximityZone) {
        z1Action(loc: zone.tag)
        print("zone call completed")
    }
    
    func z2Action(loc : String) {
        if !self.realm.objects(idPlaceholder.self).isEmpty {
            print("delegate z2")
            let idPh = self.realm.objects(idPlaceholder.self)[0]
            if !idPh.isInvalidated {
                let db = Database.database().reference().child("Clients")
                db.child(idPh.id).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String,String> {
                        let visitedLocs = snapVal["visitedLocs"]! + " \(loc),"
                        db.child(idPh.id).updateChildValues(["loc" : loc, "visitedLocs": visitedLocs]) { (error, dbase) in
                            if let error = error { print(error) }
                        }
                    }
                }
            }
            self.showNotification(with : "Press 4 in the Elevator and btw... Want a Drink?",
                                  body: "Open the app for more options!")
        } else {
            showNotification(with : "Greetings from REI!",
                             body: "Please enter your employee login or your client Id to use this application!")
        }
    }
    
    func z2Action(zone : ProximityZone) {
        z2Action(loc: zone.tag)
        print("zone call completed")
    }
    
    func z3Action(loc : String) {
        if !self.realm.objects(idPlaceholder.self).isEmpty {
            print("delegate z3")
            let idPh = self.realm.objects(idPlaceholder.self)[0]
            if !idPh.isInvalidated {
                let db = Database.database().reference().child("Clients")
                db.child(idPh.id).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String,String> {
                        let visitedLocs = snapVal["visitedLocs"]! + " \(loc),"
                        db.child(idPh.id).updateChildValues(["loc" : loc, "visitedLocs": visitedLocs]) { (error, dbase) in
                            if let error = error { print(error) }
                        }
                    }
                }
                showNotification(with : "Welcome to Our Office!",
                                 body: "You are here!")
            } else {
                showNotification(with : "Welcome to Our Office!",
                                 body: "You are here!")
            }
        } else {
            showNotification(with : "Greetings from REI!",
                             body: "You are here!")
        }
    }
    
    func z3Action(zone : ProximityZone) {
        z3Action(loc: zone.tag)
        print("zone call completed")
    }
    
    func settingUpZones(z1 : ProximityZone, z2 : ProximityZone, z3 : ProximityZone) {
        z1.onEnter = { attachment in
            self.z1Action(zone: z1)
        }
        
        z1.onContextChange = { zones in
            let locations: [String] = zones.map { context in
                return context.attachments["location"]!
            }
            if locations.count > 1 {
                if locations[1] == "elevator" {self.z2Action(zone: z1)}
                if locations[1] == "front door" {self.z3Action(zone: z3)}
            }
        }
        
        z2.onEnter = { attachment in
            self.z2Action(zone: z2)
        }
        
        z2.onContextChange = { zones in
            let locations: [String] = zones.map { context in
                return context.attachments["location"]!
            }
            if locations.count > 1 {
                if locations[1] == "lobby" {self.z1Action(zone: z1)}
                if locations[1] == "front door" {self.z3Action(zone: z3)}
            }
        }
        
        z3.onEnter = { attachment in
            self.z3Action(zone: z3)
        }
        
        z3.onContextChange = { zones in
            let locations: [String] = zones.map { context in
                return context.attachments["location"]!
            }
            if locations.count > 1 {
                if locations[1] == "lobby" {self.z1Action(zone: z1)}
                if locations[1] == "elevator" {self.z2Action(zone: z3)}
            }
        }
    }
    
    //MARK: - Setting up notification alerts
    
    func showNotification(with title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = currentApp.applicationIconBadgeNumber + 1 as NSNumber
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("We have an error \(error)")
            }
        }
    }
    
    // MARK: - Other Transition Functions

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Needs to be implemented to receive notifications both in foreground and background
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }
}
