//
//  MenuViewController.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 7/29/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//
//  Credits:
//  Messaging Icon titled "Email free icon" by Chanut
//  Directisons Icon titled "Placeholder free icon" by Smashicons

import Foundation
import Firebase
import FirebaseDatabase
import RealmSwift
import UIKit

class MenuViewController: UITabBarController, CBCentralManagerDelegate {

    var client: clientREI!
    let realm = try! Realm()
    var id: String!
    var manager : CBCentralManager!
    var pressedLogOut = false
    let db : DatabaseReference = Database.database().reference().child("Clients")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(client)
        manager = CBCentralManager()
        manager.delegate = self
        if client == nil {
            do { try self.realm.write {self.realm.deleteAll()}}
            catch{print(error)}
            self.dismiss(animated: true, completion: nil)
            return
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.resetObserver()
            setUpClients()
            setUpListenerForLogOut()
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            break
        case .poweredOff:
            self.dismissMenu()
            print("Bluetooth is Off.")
            break
        default:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if client == nil {
            do { try self.realm.write {self.realm.deleteAll()}}
            catch{print(error)}
            self.dismiss(animated: true, completion: nil)
            return
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.resetObserver()
            manager = CBCentralManager()
            manager.delegate = self
            setUpClients()
            setUpListenerForLogOut()
        }
    }
    
    func setUpClients() {
        for controllers in self.viewControllers! {
            if controllers.isViewLoaded {
                if controllers.title == "NavDirections" {
                    if let vc = controllers.childViewControllers[0] as? DirectionsViewController {
                        vc.client = self.client
                        // vc.proximityObserver.stopObservingZones()
                        print(vc.title ?? "Nothing")
                    }
                } else if controllers.title == "NavMessages" {
                    if let vc = controllers.childViewControllers[0] as? MessagesViewController {
                        vc.client = self.client
                        // vc.proximityObserver.stopObservingZones()
                        print(vc.title ?? "Nothing")
                    }
                } else if controllers.title == "NavSettings" {
                    if let vc = controllers.childViewControllers[0] as? InfoViewController {
                        vc.client = self.client
                        print(vc.title ?? "Nothing")
                    }
                }
            }
        }
    }

    func setUpListenerForLogOut() {
        if client == nil {
            do {try self.realm.write{self.realm.deleteAll()}}
            catch {print(error)}
            self.dismiss(animated: true, completion: nil)
        }
        db.child(client.id).observe(DataEventType.childRemoved) { (snapshot) in
            if snapshot.value != nil {
                if (self.selectedViewController?.isViewLoaded)! {
                    self.selectedViewController?.dismiss(animated: true, completion: {
                        do {try self.realm.write{self.realm.deleteAll()}}
                        catch{print(error)}
                        self.dismissMenu()
                    })
                }
            }
        }
    }
    
    func dismissMenu() {
        for controllers in self.viewControllers! {
            if controllers.isViewLoaded {
                if controllers.childViewControllers[0].isViewLoaded {
                    controllers.childViewControllers[0].dismiss(animated: true, completion: nil)
                }
                controllers.dismiss(animated: true, completion: nil)
            }
        }
        do { try self.realm.write {self.realm.deleteAll()}}
        catch{print(error)}
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !pressedLogOut {return}
        for controllers in self.viewControllers! {
            if controllers.isViewLoaded {
                if controllers.title == "NavDirections" && controllers.childViewControllers[0].isViewLoaded {
                    if let vc = controllers.childViewControllers[0] as? DirectionsViewController {
                        //vc.proximityObserver.stopObservingZones()
                        print(vc.title ?? "Nothing")
                    }
                } else if controllers.title == "NavMessages" && controllers.childViewControllers[0].isViewLoaded {
                    if let vc = controllers.childViewControllers[0] as? MessagesViewController {
                        //vc.proximityObserver.stopObservingZones()
                        print(vc.title ?? "Nothing")
                    }
                } else if controllers.title == "NavSettings" && controllers.childViewControllers[0].isViewLoaded {
                    if let vc = controllers.childViewControllers[0] as? InfoViewController {
                        //vc.db.removeAllObservers()
                        print(vc.title ?? "Nothing")
                    }
                }
            }
        }
        self.client = nil
        // db.removeAllObservers()
    }
}
