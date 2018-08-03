//
//  DirectionsViewController.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 7/30/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseDatabase
import Firebase
import EstimoteProximitySDK

class DirectionsViewController: UIViewController {

    /*
     Credentials to Estimote Cloud API:
     App ID: rei-beacon-app-iwl
     App Token: 1f2ca4468134f76e44478897b3114042
     
     Zones:
     beetroot - lobby
     lemon - elevator
     candy - front door
     */
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var progressBar: UIView!
    
    var client : clientREI!
    let realm = try! Realm()
    var proximityObserver: ProximityObserver!
    var configured = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tbc = tabBarController as! MenuViewController
        self.client = tbc.client
        
        if self.client == nil {
            if let tbc = tabBarController as? MenuViewController {tbc.pressedLogOut = true}
            do {try self.realm.write{self.realm.deleteAll()}}
            catch{print(error)}
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        // Setting up Estimote Observer
        let cloudCredentials = CloudCredentials(appID: "rei-beacon-app-iwl",
                                                   appToken: "1f2ca4468134f76e44478897b3114042")
        
        self.proximityObserver = ProximityObserver(
            credentials: cloudCredentials,
            onError: { error in
                print("proximity observer error: \(error)")
        })
        
        let zone1 = ProximityZone(tag: "lobby", range: .far)
        let zone2 = ProximityZone(tag: "elevator", range: .far)
        let zone3 = ProximityZone(tag: "front door", range: .far)
        settingUpZones(z1 : zone1, z2 : zone2, z3 : zone3)
        self.proximityObserver.startObserving([zone1, zone2, zone3])
        setTextandProgress(client == nil ? "start" : client.loc)
        print("completed Direction viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !configured {
            let tbc = tabBarController as! MenuViewController
            self.client = tbc.client
            setTextandProgress(client == nil ? "start" : client.loc)
        }
        configured = true
    }
    
    // MARK: - UI Update Functions
    
    func setTextandProgress(_ location : String) {
        if (location == "lobby") {
            self.directionsLabel.text = "Enter Elevator"
            self.img.image = UIImage(named: "lobby")
            progressBar.frame.size.width = UIScreen.main.bounds.width * (1/3)
        } else if (location == "elevator") {
            self.directionsLabel.text = "Press 4"
            self.img.image = UIImage(named: "button")
            if let tbc = tabBarController as? MenuViewController {
                tbc.tabBar.items![1].badgeValue = " "
            }
            progressBar.frame.size.width = UIScreen.main.bounds.width * (2/3)
        } else if (location == "front door") {
            self.directionsLabel.text = "Proceed to REI door"
            self.img.image = UIImage(named: "front")
            progressBar.frame.size.width = UIScreen.main.bounds.width * (3/3)
        } else {
            self.directionsLabel.text = "Go to Lobby Doors"
            self.img.image = UIImage(named: "doors")
            progressBar.frame.size.width = UIScreen.main.bounds.width * 0
        }
    }
    
    // MARK: - Estimote Observer Functions
    
    func editVisitedLocs(append additionalLoc : String) {
        self.client.visitedLocs = self.client.visitedLocs + " " + additionalLoc + ","
    }
    
    func zAction(zone : ProximityZone) {
        if zone.tag == "elevator" {self.editVisitedLocs(append: zone.tag)}
        print(zone.tag)
        self.setTextandProgress(zone.tag)
        // updateLocations(where: zone.tag)
    }
    
    func settingUpZones(z1 : ProximityZone, z2 : ProximityZone, z3 : ProximityZone) {
        z1.onEnter = {attachment in self.zAction(zone: z1)}
        z1.onContextChange = { zones in
            let locations: [String] = zones.map { context in
                return context.attachments["location"]!
            }
            if locations.count > 1 {
                if locations[1] == "elevator" {self.zAction(zone: z2)}
                if locations[1] == "front door" {self.zAction(zone: z3)}
            }
        }
        
        z2.onEnter = { attachment in self.zAction(zone: z2)}
        z2.onContextChange = { zones in
            let locations: [String] = zones.map { context in
                return context.attachments["location"]!
            }
            if locations.count > 1 {
                if locations[1] == "lobby" {self.zAction(zone: z1)}
                if locations[1] == "front door" {self.zAction(zone: z3)}
            }
        }
        
        z3.onEnter = { attachment in self.zAction(zone: z3) }
        z3.onContextChange = { zones in
            let locations: [String] = zones.map { context in
                return context.attachments["location"]!
            }
            if locations.count > 1 {
                if locations[1] == "lobby" {self.zAction(zone: z1)}
                if locations[1] == "elevator" {self.zAction(zone: z3)}
            }
        }
    }
    
    // MARK: - API Calls
    
    func updateLocations(where loc: String) {
        if client == nil {
            print(client == nil)
            if let tbc = self.tabBarController as? MenuViewController {tbc.pressedLogOut = true}
            do {try self.realm.write{self.realm.deleteAll()}}
            catch{print(error)}
            (self.tabBarController as? MenuViewController)?.dismissMenu()
            return
        }
        let db = Database.database().reference().child("Clients")
        db.child(client.id).updateChildValues(["loc" : loc]) { (error, ref) in
            if let error = error {print(error)}
        }
    }
}
