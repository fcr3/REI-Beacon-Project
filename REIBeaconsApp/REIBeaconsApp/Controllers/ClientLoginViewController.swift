//
//  ClientLoginViewController.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 6/12/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import FirebaseDatabase
import RealmSwift

class ClientLoginViewController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    var client : clientREI!
    let realm = try! Realm()
    
    //MARK: - Necessary Functions to Configure Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Button Functions
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logInButton(_ sender: UIButton) {
        SVProgressHUD.show()
        backButton.isEnabled = false
        logInButton.isEnabled = false
        idTextField.isEnabled = false
        
        if idTextField.text != "", let someId = idTextField.text {
            do {try self.realm.write {
                self.realm.deleteAll()
                let idPh = idPlaceholder()
                idPh.id = someId
                self.realm.add(idPh)
            }}
            catch {
                SVProgressHUD.showError(withStatus: "Error writing to persistent database")
                self.backButton.isEnabled = true
                self.logInButton.isEnabled = true
                self.idTextField.isEnabled = true
                return
            }
            retrieveClient(id: someId)
        }
    }
    
    //MARK: - Backend API Requests and Segue Functions
    func retrieveClient(id : String) {
        let db = Database.database().reference().child("Clients")
        db.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String, String> {
                self.client = clientREI()
                self.client.id = id
                
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
                SVProgressHUD.dismiss(withDelay: 1.0)
                self.performSegue(withIdentifier: "goToMenu", sender: self)
            } else {
                SVProgressHUD.showError(withStatus: "Could Not Find Id")
                SVProgressHUD.dismiss(withDelay: 1.0)
                do {try self.realm.write {self.realm.deleteAll()}}
                catch {print(error)}
            }
            self.backButton.isEnabled = true
            self.logInButton.isEnabled = true
            self.idTextField.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMenu" {
            let destinationVC = segue.destination as! MenuViewController
            destinationVC.client = self.client
            destinationVC.id = self.client.id
        }
    }
    
}
