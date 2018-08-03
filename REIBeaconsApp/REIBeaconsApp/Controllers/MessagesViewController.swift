//
//  MessagesViewController.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 7/30/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import RealmSwift
import EstimoteProximitySDK
import Firebase
import FirebaseDatabase

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var promptTableView: UITableView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    
    var client : clientREI!
    let realm = try! Realm()
    var promptArray : [String]!
    var proximityObserver : ProximityObserver!
    var configured = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tbc = tabBarController as! MenuViewController
        self.client = tbc.client
        
        if client == nil {
            if let tbc = tabBarController as? MenuViewController {tbc.pressedLogOut = true}
            do { try self.realm.write {self.realm.deleteAll()}}
            catch{print(error)}
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.promptArray = self.client.messages.map({ (string) -> String in
            return string + ""
        })
        print(self.promptArray)
        print(self.client.visitedLocs)
        
        self.configureTableView()
        self.promptTableView.isHidden = true
        self.buttonView.isHidden = true
        if self.promptArray == nil || self.promptArray.count == 0 {self.promptArray = [""]}
        if self.client.visitedLocs.range(of: "elevator") != nil && !configured {
            self.promptTableView.isHidden = false
            self.buttonView.isHidden = false
            if self.promptArray.index(of: "Okay! We will have it ready for you!") != nil {
                self.buttonView.isHidden = true
            } else if self.promptArray.index(of: "Okay! See you soon!") != nil {
                self.buttonView.isHidden = true
            } else if self.promptArray.index(of: "What would you like to drink?") != nil {
                tbc.tabBar.items![1].badgeValue = " "
                self.leftButton.setTitle("Water", for: .normal)
                self.rightButton.setTitle("Coffee", for: .normal)
            } else {
                tbc.tabBar.items![1].badgeValue = " "
                self.promptArray.removeAll(keepingCapacity: false)
                self.promptArray = ["Would you like something to drink?"]
                self.leftButton.setTitle("Yes", for: .normal)
                self.rightButton.setTitle("No", for: .normal)
            }
        }
        
        self.configured = true
        setUpEstimoteObservers()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tbc = tabBarController as? MenuViewController {
            tbc.tabBar.items![1].badgeValue = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tbc = tabBarController as! MenuViewController
        self.client = tbc.client
    }
    
    
    // MARK: - Setting Up Estimote Observers
    
    func setUpEstimoteObservers() {
        let cloudCredentials = CloudCredentials(appID: "rei-beacon-app-iwl",
                                                   appToken: "1f2ca4468134f76e44478897b3114042")
        
        self.proximityObserver = ProximityObserver(
            credentials: cloudCredentials,
            onError: { error in
                print("proximity observer error: \(error)")
        })
        let zone1 = ProximityZone(tag: "lobby", range: .near)
        let zone2 = ProximityZone(tag: "elevator", range: .near)
        settingUpZones(z1 : zone1, z2 : zone2)
        self.proximityObserver.startObserving([zone2])
    }
    
    func settingUpZones(z1: ProximityZone, z2: ProximityZone) {
        z1.onEnter = { attachment in
            print("sensed")
            if self.client != nil {self.loadData()}
            else{
                if let tbc = self.tabBarController as? MenuViewController {tbc.pressedLogOut = true}
                do {try self.realm.write{self.realm.deleteAll()}}
                catch {print(error)}
                (self.tabBarController as? MenuViewController)?.dismissMenu()
            }
        }
        z2.onEnter = { attachment in
            print("sensed")
            if self.client != nil {self.loadData()}
            else{
                if let tbc = self.tabBarController as? MenuViewController {tbc.pressedLogOut = true}
                do {try self.realm.write{self.realm.deleteAll()}}
                catch {print(error)}
                (self.tabBarController as? MenuViewController)?.dismissMenu()
            }
        }
    }
    
    // MARK: - Saving Data to Databases
    
    func saveMessagestoPersistentDatabase() {
        self.client.messages = promptArray
    }
    
    func saveMessagestoDatabase() {
        let db = Database.database().reference().child("Clients")
        db.child(client.id).updateChildValues([
            "messages" : self.client.messages.joined(separator: ","),
            "wantsDrink" : self.client.wantsDrink,
            "drink" : self.client.drink
        ]) { (error, reference) in
            if let error = error {print(error)}
            else {
                self.configureTableView()
                self.promptTableView.reloadData()
            }
        }
    }
    
    // MARK: - Setting up Table View
    
    func loadData(_ disappear : Bool = false) {
        self.promptTableView.isHidden = false
        self.buttonView.isHidden = disappear
        if self.client.visitedLocs.range(of: "elevator") == nil || self.promptArray.count == 0
            || self.promptArray[0] == "" {
            if let tbc = tabBarController as? MenuViewController {
                tbc.tabBar.items![1].badgeValue = " "
            }
            self.promptArray.removeAll(keepingCapacity: false)
            self.promptArray = ["Would you like something to drink?"]
            self.leftButton.setTitle("Yes", for: .normal)
            self.rightButton.setTitle("No", for: .normal)
        }
        if self.promptArray.index(of: "Okay! We will have it ready for you!") != nil {
            self.buttonView.isHidden = true
        } else if self.promptArray.index(of: "Okay! See you soon!") != nil {
            self.buttonView.isHidden = true
        }
        saveMessagestoPersistentDatabase()
        saveMessagestoDatabase() // reloads data in callback
    }
    
    func configureTableView() {
        // promptTableView.rowHeight = UITableViewAutomaticDimension
        promptTableView.rowHeight = 86
        promptTableView.estimatedRowHeight = 80.0
    }
    
    func setUpTableView() {
        promptTableView.delegate = self
        promptTableView.dataSource = self
        promptTableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        promptTableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return promptArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.CustomCellText.text = promptArray[indexPath.row]
        cell.CustomCellText.font = UIFont.init(name: "HelveticaNeue-Medium", size: 20.0)
        cell.TextBackground.layer.cornerRadius = 8.0
        cell.TextBackground.clipsToBounds = true
        cell.CustomCellText.textColor = UIColor.flatWhite()
        
        // let green = UIColor.init(hexString: "91DC5A")
        // let blue = UIColor.init(hexString: "006DF0")
        
        if (indexPath.row % 2 != 0) {
            cell.TextBackground.backgroundColor = UIColor.init(hexString: "006DF0")
            cell.CustomCellImg.image = UIImage(named: "hurricane_blue")
        } else {
            cell.TextBackground.backgroundColor = UIColor.init(hexString: "91DC5A")
            cell.CustomCellImg.image = UIImage(named: "hurricane_green")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - UI Functions
    
    @IBAction func pressedLeftButton(_ sender: UIButton) {
        let tbc = tabBarController as! MenuViewController
        tbc.tabBar.items![1].badgeValue = nil
        if sender.title(for: .normal) == "Yes" {
            self.promptArray.append("Yes")
            self.promptArray.append("What would you like to drink?")
            self.client.wantsDrink = "true"
            self.leftButton.setTitle("Water", for: .normal)
            self.rightButton.setTitle("Coffee", for: .normal)
            self.loadData()
        } else if sender.title(for: .normal) == "Water" {
            self.promptArray.append("Water")
            self.promptArray.append("Okay! We will have it ready for you!")
            self.client.drink = "Water"
            self.loadData(true)
        }
    }
    
    @IBAction func pressedRightButton(_ sender: UIButton) {
        let tbc = tabBarController as! MenuViewController
        tbc.tabBar.items![1].badgeValue = nil
        if sender.title(for: .normal) == "No" {
            self.promptArray.append("No")
            self.promptArray.append("Okay! See you soon!")
            self.client.wantsDrink = "false"
        } else if sender.title(for: .normal) == "Coffee" {
            self.promptArray.append("Coffee")
            self.promptArray.append("Okay! We will have it ready for you!")
            self.client.drink = "Coffee"
        }
        self.loadData(true)
    }
}
