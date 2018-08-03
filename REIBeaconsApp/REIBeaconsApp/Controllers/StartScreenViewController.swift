//
//  StartScreenViewController.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 6/12/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD
import Firebase
import FirebaseDatabase
import ChameleonFramework

class StartScreenViewController: UIViewController, CBCentralManagerDelegate {

    @IBOutlet weak var clientButton: UIButton!
    let realm = try! Realm()
    var client : clientREI!
    var id : String!
    var manager : CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager()
        manager.delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Do any additional setup after loading the view.
        // let green = UIColor.init(hexString: "91DC5A")
        // let blue = UIColor.init(hexString: "006DF0")
        clientButton.backgroundColor = UIColor.init(hexString: "91DC5A")
        clientButton.setTitleColor(UIColor.white, for: .normal)
        clientButton.titleLabel?.font = UIFont.init(name: "HelveticaNeue-Bold", size: 22.0)
        
        // Checking previous history of client logins
        let idArray : Results<idPlaceholder>? = realm.objects(idPlaceholder.self)
        if idArray != nil && !idArray!.isEmpty && Auth.auth().currentUser != nil {
            if !idArray![0].isInvalidated && idArray![0].id != "" {
                clientButton.isEnabled = false
                SVProgressHUD.show()
                self.id = idArray![0].id
                retrieveClient()
            } else {
                do { try self.realm.write{self.realm.deleteAll()}}
                catch {print(error)}
            }
        } else {
            if Auth.auth().currentUser != nil {return}
            Auth.auth().signIn(withEmail: "app@client.com", password: "NUB9JAMJGbkwqBroilwd6sYy") { (result, error) in
                if let error = error {print(error)}
            }
        }
    }
    
    // MARK: - Bluetooth Status Tracking
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            break
        case .poweredOff:
            print("Bluetooth is Off.")
            break
        default:
            break
        }
    }
    
    func logInFailedAlert() {
        let alert = UIAlertController(title: "Turn On Bluetooth", message: "Cannot Use App Without Bluetooth On", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // what will happen when user clicks button
            SVProgressHUD.dismiss(withDelay: 1)
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Client Retrieval Function
    
    func retrieveClient() {
        let db = Database.database().reference().child("Clients")
        db.child(self.id).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String, String> {
                self.client = clientREI()
                self.client.id = self.id
                
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
                
                SVProgressHUD.showSuccess(withStatus: "Logged In")
                SVProgressHUD.dismiss()
                self.clientButton.isEnabled = true
                if self.manager.state == .poweredOn {
                    self.performSegue(withIdentifier: "goToMenuFromStart", sender: self)
                }
            } else {
                SVProgressHUD.showError(withStatus: "Could Not Find Id")
                SVProgressHUD.dismiss(withDelay: 1.0)
                do { try self.realm.write{self.realm.deleteAll()}}
                catch {print(error)}
                self.clientButton.isEnabled = true
            }
        }
    }
    
    // MARK: - Navigation

    @IBAction func clientButton(_ sender: UIButton) {
        if self.manager.state != .poweredOn {logInFailedAlert(); return;}
        self.performSegue(withIdentifier: "goToClientLogin", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMenuFromStart" {
            let destinationVC = segue.destination as! MenuViewController
            destinationVC.client = self.client
            destinationVC.id = self.client.id
        }
    }
}
