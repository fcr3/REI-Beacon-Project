//
//  ViewController.swift
//  REI Employee App
//
//  Created by Flaviano Reyes on 6/16/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

// TODO: Set Up Employee Names

import UIKit
import RealmSwift
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD

class LogInViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    var emp : employee!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UNCOMMENT FOR DEBUGGING PURPOSES
        // wipePersistentDatabase()
        
        // Do any additional setup after loading the view, typically from a nib.
        if Auth.auth().currentUser != nil && !realm.objects(employee.self).isEmpty {
            SVProgressHUD.show()
            let employeeArray : Results<employee>? = realm.objects(employee.self)
            self.emp = employeeArray?[0]
            let db = Database.database().reference().child("Employees").child(self.emp.email.split(separator: ".")[0] + "")
            db.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String, String> {
                    if snapVal["current"]! == UIDevice.current.identifierForVendor?.uuidString {
                        self.setUpNewPersistentEmp(em: self.emp.email, pass: self.emp.password, token: self.emp.token)
                    } else {
                        self.wipePersistentDatabase()
                        SVProgressHUD.dismiss(withDelay: 1)
                    }
                }
            }
        }
    }
    
    func wipePersistentDatabase() {
        do {
            try Auth.auth().signOut()
            try self.realm.write {
                realm.deleteAll()
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - UI Functions
    
    @IBAction func pressedLogIn(_ sender: UIButton) {
        logInButton.isEnabled = false
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
        SVProgressHUD.show()
        if passwordTextField.text! != "" && emailTextField.text! != "" {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                if let err = error {
                    self.errorMessage(message: "User Does Not Exist")
                    SVProgressHUD.dismiss(withDelay: 1)
                    print(err)
                } else {
                    self.retrieveToken(em: self.emailTextField.text!, pass : self.passwordTextField.text!)
                }
            }
        } else {
            self.errorMessage(message: "Textfields not Filled")
            SVProgressHUD.dismiss(withDelay: 1)
        }
    }
    
    func errorMessage(message : String) {
        SVProgressHUD.showError(withStatus: message)
        logInButton.isEnabled = true
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
    }
    
    // MARK: - Retrieve Token and Topic Posting
    
    func retrieveToken(em email: String, pass password: String) {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let err = error {
                print(err)
            } else {
                self.setUpNewPersistentEmp(em: email, pass: password, token: result!.token)
            }
        })
    }

    
    // MARK: - Persistent Database Functions
    
    func setUpNewPersistentEmp(em: String, pass: String, token: String) {
        let newEmp = employee()
        do {
            try self.realm.write {
                self.realm.deleteAll()
                self.realm.add(newEmp)
                newEmp.email = em
                newEmp.password = pass
                newEmp.token = token
            }
            // Messaging.messaging().subscribe(toTopic: newEmp.email.split(separator: ".")[0] + "")
            self.checkExistingData(who: newEmp)
        } catch {
            self.errorMessage(message: "Error writing to persistent database")
            SVProgressHUD.dismiss(withDelay: 1)
        }
    }
    
    // MARK: - API Functions
    
    func checkExistingData(who emp: employee) {
        let db = Database.database().reference().child("Employees")
        db.child(emp.email.split(separator: ".")[0] + "").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String, String> {
                emp.clientIds.removeAll()
                for id in snapVal["clientIds"]!.split(separator: ",") {
                    emp.clientIds.append(id + "")
                }
                do {try self.realm.write {emp.name = snapVal["name"] != nil ? snapVal["name"]! : ""}}
                catch {print(error)}
            }
            self.populateClientArray(who: emp)
        }
    }
    
    func sendNewEmpToDatabase(who emp : employee) {
        let db = Database.database().reference().child("Employees")
        db.child(emp.email.split(separator: ".")[0] + "").setValue(emp.employeeDictionary()) { (error, reference) in
            if let err = error {
                self.errorMessage(message: "Error writing to persistent database")
                print(err)
            } else {
                SVProgressHUD.showSuccess(withStatus: "Logged In")
                SVProgressHUD.dismiss()
                self.logInButton.isEnabled = true
                self.emp = emp
                self.performSegue(withIdentifier: "goToClientTableView", sender: self)
            }
        }
    }
    
    func populateClientArray(who emp : employee) {
        let db = Database.database().reference().child("Clients")
        var index = 0
        emp.clients.removeAll()
        
        if emp.clientIds.isEmpty {
            sendNewEmpToDatabase(who: emp)
        }
        
        for clientIds in emp.clientIds {
            db.child(clientIds).observeSingleEvent(of: .value) { (snapshot) in
                if let snapVal = snapshot.value as? Dictionary<String, String> {
                    let someClient = client()
                    someClient.date = snapVal["date"]!
                    someClient.drink = snapVal["drink"]!
                    someClient.emp = snapVal["emp"]!
                    someClient.empName = snapVal["empName"]!
                    someClient.id = clientIds
                    someClient.wantsDrink = snapVal["wantsDrink"]!
                    someClient.loc = snapVal["loc"]!
                    someClient.person = snapVal["person"]!
                    someClient.room = snapVal["room"]!
                    someClient.time = snapVal["time"]!
                    someClient.visitedLocs = snapVal["visitedLocs"]!
                    someClient.checkedIn = snapVal["checkedIn"]!
                    someClient.messages = snapVal["messages"]!
                    emp.clients.append(someClient)
                }
                if (index + 1 == emp.clientIds.count) {
                    if !emp.clients.isEmpty {
                        if emp.clients.count != emp.clientIds.count {
                            self.cleanUpClientArray(who: emp)
                        }
                        self.updateAndSegue(who: emp)
                    } else {
                        self.cleanUpDatabase(who: emp)
                    }
                }
                index = index + 1
            }
        }
    }
    
    func cleanUpClientArray(who emp : employee) {
        cleanUpArrayInMemory(who: emp)
        cleanUpArrayInDatabase(who: emp)
    }
    
    func cleanUpArrayInMemory(who emp : employee) {
        var newList = [String]()
        for clientIds in emp.clientIds {
            for client in emp.clients{
                if client.id.elementsEqual(clientIds) {
                    newList.append(clientIds)
                }
            }
        }
        emp.clientIds.removeAll()
        emp.clientIds.append(contentsOf: newList)
    }
    
    func updateAndSegue(who emp: employee) {
        let db = Database.database().reference().child("Employees")
        db.child(emp.email.split(separator: ".")[0] + "").setValue(emp.employeeDictionary()) { (error, reference) in
            if let err = error {
                self.errorMessage(message: "Error writing to persistent database")
                SVProgressHUD.dismiss(withDelay: 1)
                print(err)
            } else {
                SVProgressHUD.showSuccess(withStatus: "Logged In")
                SVProgressHUD.dismiss(withDelay: 1)
                self.logInButton.isEnabled = true
                self.emailTextField.isEnabled = true
                self.passwordTextField.isEnabled = true
                self.emp = emp
                self.performSegue(withIdentifier: "goToClientTableView", sender: self)
            }
        }
    }
    
    func cleanUpArrayInDatabase(who emp : employee) {
        let db = Database.database().reference().child("Employees")
        db.child(emp.email.split(separator: ".")[0] + "").setValue(emp.employeeDictionary()) { (error, reference) in
            if let err = error {
                self.errorMessage(message: "Error writing to persistent database")
                SVProgressHUD.dismiss(withDelay: 1)
                print(err)
            }
        }
    }
    
    func cleanUpDatabase(who emp : employee) {
        emp.clientIds.removeAll()
        emp.clients.removeAll()
        self.sendNewEmpToDatabase(who: emp)
    }
    
    // MARK: - Navigation Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToClientTableView" {
            emailTextField.text = ""
            passwordTextField.text = ""
            emailTextField.isEnabled = true
            passwordTextField.isEnabled = true
            let destinationVC = segue.destination as! ClientTableViewController
            destinationVC.emp = self.emp
        }
    }
}

