//
//  InfoViewController.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 7/30/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import RealmSwift

class InfoViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var empLabel: UILabel!
    
    let realm = try! Realm()
    var client : clientREI!
    let db : DatabaseReference = Database.database().reference().child("Clients")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tbc = tabBarController as! MenuViewController
        self.client = tbc.client
        print(client)
        if self.client == nil {logOut(); return}
        
        updateUI()
        setUpListenerForInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tbc = tabBarController as! MenuViewController
        self.client = tbc.client
    }
    
    func updateUI() {
        nameLabel.text = "Name: " + (client?.person)!
        let timeArr = (client?.time)!.split(separator: "-")
        let dateArr = (client?.date)!.split(separator: "-")
        let time = timeArr[0] + ":" + timeArr[1] + " " + timeArr[2]
        let date = dateArr[1] + "/" + dateArr[2] + "/" + dateArr[0]
        timeLabel.text = "Meeting Time: " + time
        dateLabel.text = "Meeting Date: " + date
        roomLabel.text = "Meeting Room: " + (client?.room)!
        empLabel.text = "Meeting with: " + (client?.empName)!
    }
    
    @IBAction func pressedLogOut(_ sender: Any) {
        logOut()
    }
    
    func logOut() {
        if let tbc = tabBarController as? MenuViewController {tbc.pressedLogOut = true}
        do { try self.realm.write {self.realm.deleteAll()}}
        catch { print(error)}
        (self.tabBarController as! MenuViewController).dismissMenu()
    }
    
    func setUpListenerForInfo() {
        if client == nil {logOut()}

        if client != nil {
            db.child(client.id).observe(.value) { (snapshot) in
                if self.client == nil {self.logOut()}
                if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String,String> {
                    if self.client == nil {
                        return
                    }
                    self.client.date = snapVal["date"]!
                    self.client.drink = snapVal["drink"]!
                    self.client.emp = snapVal["emp"]!
                    self.client.empName = snapVal["empName"]!
                    self.client.checkedIn = snapVal["checkedIn"]!
                    self.client.wantsDrink = snapVal["wantsDrink"]!
                    self.client.loc = snapVal["loc"]!
                    self.client.messages = (snapVal["messages"]!).split(separator: ",").map({ (string) -> String in
                        return string + ""})
                    self.client.person = snapVal["person"]!
                    self.client.room = snapVal["room"]!
                    self.client.time = snapVal["time"]!
                    self.client.visitedLocs = snapVal["visitedLocs"]!
                }
                self.updateUI()
            }
        }
    }
}
