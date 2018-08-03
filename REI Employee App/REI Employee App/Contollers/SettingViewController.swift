//
//  SettingViewController.swift
//  REI Employee App
//
//  Created by Flaviano Reyes on 7/23/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD
import RealmSwift

class SettingViewController: UIViewController {


    @IBOutlet weak var nameField: UITextField!
    let realm = try! Realm()
    var emp : employee!
    var protocolDelegate : tableViewUpdater!
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = emp.name.count != 0 ? emp.name : ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
     
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        protocolDelegate.nilSelectedClient()
    }
    
    @IBAction func pressedSave(_ sender: UIButton) {
        if nameField.text! == "" || nameField.text!.count == 0 {
            return
        }
        
        SVProgressHUD.show()
        nameField.isEnabled = false
        saveButton.isEnabled = false
        do {
            try self.realm.write {
                emp.name = nameField.text!
            }
            changeNameInClients()
            saveNameToDatabase()
        } catch {
            print(error)
        }
    }
    
    func changeNameInClients() {
        let db = Database.database().reference().child("Clients")
        print(emp.clientIds)
        for id in emp.clientIds {
            db.child(id).updateChildValues(["empName" : emp.name]) { (error, ref) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: "Error writing to database")
                    SVProgressHUD.dismiss(withDelay: 1)
                    print(error)
                    self.nameField.isEnabled = true
                    self.saveButton.isEnabled = true
                }
            }
        }
    }
    
    func saveNameToDatabase() {
        let db = Database.database().reference().child("Employees")
        db.child(String(emp.email.split(separator: ".")[0])).setValue(emp.employeeDictionary()) { (error, reference) in
            if let err = error {
                SVProgressHUD.showError(withStatus: "Error writing to database")
                SVProgressHUD.dismiss(withDelay: 1)
                print(err)
                self.nameField.isEnabled = true
                self.saveButton.isEnabled = true
            } else {
                SVProgressHUD.showSuccess(withStatus: "Saved Name")
                SVProgressHUD.dismiss(withDelay: 1)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
