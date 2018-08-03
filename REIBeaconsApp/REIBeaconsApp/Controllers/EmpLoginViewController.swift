//
//  EmpLoginViewController.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 6/12/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import RealmSwift

class EmpLoginViewController: UIViewController {
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let realm = try! Realm()
    var emp : employeeREI!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation

    @IBAction func pressedLogInButton(_ sender: UIButton) {
        logInButton.isEnabled = false
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
        SVProgressHUD.show()
        if let email = emailTextField.text, let pass = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
                if let err = error {
                    SVProgressHUD.showError(withStatus: "Could Not Find User")
                    SVProgressHUD.dismiss()
                    print(err)
                    self.logInButton.isEnabled = true
                    self.emailTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                } else {
                    self.createNewPersistentUser(em: email, p: pass)
                    self.retrieveClientArray()
                    SVProgressHUD.showSuccess(withStatus: "Logged In")
                    SVProgressHUD.dismiss()
                    self.logInButton.isEnabled = true
                    self.emailTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                    self.performSegue(withIdentifier: "goToEmpScreen", sender: self)
                }
            }
        }
    }
    
    func createNewPersistentUser(em : String, p : String) {
        emp = employeeREI()
        emp.email = em
        emp.password = p
        
        do {
            try self.realm.write {
                let empArray : Results<employeeREI>? = realm.objects(employeeREI.self)
                if empArray != nil && empArray?.count != 0 {
                    realm.delete(empArray!)
                }
                self.realm.add(self.emp)
            }
        } catch {
            print("Error writing to persistent database: \(error)")
            SVProgressHUD.showError(withStatus: "Error writing to memory")
            SVProgressHUD.dismiss()
            self.logInButton.isEnabled = true
            self.emailTextField.isEnabled = true
            self.passwordTextField.isEnabled = true
        }
    }
    
    func retrieveClientArray() {
        let db = Database.database().reference().child("Employees")
        db.child((Auth.auth().currentUser?.email)!).observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.value != nil) {
                let snapVal = snapshot.value as! Dictionary<String, String>
                let clientIds = snapVal["client"]!.split(separator: ",")
                do {
                    try self.realm.write {
                        self.emp.clientIds.removeAll()
                        for client in clientIds {
                            self.emp.clientIds.append(client + "")
                        }
                    }
                } catch {
                    print("Error writing to persistent database: \(error)")
                    SVProgressHUD.showError(withStatus: "Error writing to memory")
                    SVProgressHUD.dismiss()
                    self.logInButton.isEnabled = true
                    self.emailTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                }
                self.populateClientArray()
            }
        }
    }
    
    func populateClientArray() {
        let db = Database.database().reference().child("Clients")
        for clientId in emp.clientIds {
            db.child(clientId).observeSingleEvent(of: .value) { (snapshot) in
                if (snapshot.value != nil) {
                    let snapVal = snapshot.value as! Dictionary<String, String>
                    
                    let client = clientREI()
                    client.editDate(snapVal["date"]!)
                    client.editDrink(snapVal["drink"]!)
                    client.editEmp(snapVal["emp"]!)
                    client.editId(clientId)
                    client.editCompletedPrompt2(snapVal["completedPrompt2"]!)
                    client.editWantsDrink(snapVal["wantsDrink"]!)
                    client.editLoc(snapVal["loc"]!)
                    client.editPerson(snapVal["person"]!)
                    client.editRoom(snapVal["room"]!)
                    client.editTime(snapVal["time"]!)
                    client.editVisitedLocs(snapVal["visitedLocs"]!)
                    do {
                        try self.realm.write {
                            self.emp.clients.append(client)
                        }
                    } catch {
                        print("Error writing to persistent database: \(error)")
                        SVProgressHUD.showError(withStatus: "Error writing to memory")
                        SVProgressHUD.dismiss()
                        self.logInButton.isEnabled = true
                        self.emailTextField.isEnabled = true
                        self.passwordTextField.isEnabled = true
                    }
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEmpScreen" {
            let destinationVC = segue.destination as! EmpScreenTableViewController
            destinationVC.emp = self.emp
            destinationVC.clientArray = self.emp.clients
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
