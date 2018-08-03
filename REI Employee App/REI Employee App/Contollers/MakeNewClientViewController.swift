//
//  MakeNewClientViewController.swift
//  REI Employee App
//
//  Created by Flaviano Reyes on 6/16/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import RealmSwift
import SVProgressHUD

class MakeNewClientViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var meetRmTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addNewClientButton: UIButton!
    @IBOutlet weak var navBAr: UINavigationBar!
    
    var cl : client!
    var emp : employee!
    var someDelegate : tableViewUpdater!
    let realm = try! Realm()
    var createdClient : Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createdClient = false
        if cl != nil {
            nameTextField.text = cl.person
        }
    }
    
    // MARK: - UI Element Functions
    
    @IBAction func pressedAddNewClient(_ sender: Any) {
        nameTextField.resignFirstResponder()
        meetRmTextField.resignFirstResponder()
        datePicker.resignFirstResponder()
        addNewClientButton.isEnabled = false
        if checkTextFields() {
            SVProgressHUD.show()
            saveDataToDatabase()
        } else {
            SVProgressHUD.showError(withStatus: "Textfields incorrectly Filled")
            SVProgressHUD.dismiss(withDelay: 1)
            addNewClientButton.isEnabled = true
        }
    }
    
    func pasteAlert() {
        let alert = UIAlertController(title: "ID Copied to Clipboard", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // what will happen when user clicks button
            UIPasteboard.general.string = self.cl.id
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Save Client Helper Functions
    
    func transferDataToClient(id autoId : String) {
        cl.id = autoId
        cl.person = nameTextField.text!
        cl.room = meetRmTextField.text!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h-mm-a"
        let dateTimeArr = dateFormatter.string(from: datePicker.date).split(separator: " ")
        cl.date = dateTimeArr[0] + ""
        cl.time = dateTimeArr[1] + ""
    }
    
    func checkTextFields() -> Bool {
        return nameTextField.text != nil && meetRmTextField.text != nil &&
            nameTextField.text != "" && meetRmTextField.text != ""
    }
    
    // MARK: - API and Persistent Database Functions
    
    func saveDataToDatabase() {
        let ref = Database.database().reference().child("Clients").childByAutoId()
        self.transferDataToClient(id: ref.key)
        self.emp.clientIds.append(self.cl.id)
        self.emp.clients.append(self.cl)
        ref.setValue(cl.clientREIDictionary()) { (error, reference) in
            if let err = error {
                SVProgressHUD.showError(withStatus: "Error writing to database")
                SVProgressHUD.dismiss(withDelay: 1)
                print(err)
                self.addNewClientButton.isEnabled = true
            }else {
                let newdb = Database.database().reference().child("Employees")
                newdb.child(self.emp.email.split(separator: ".")[0] + "").setValue(self.emp.employeeDictionary()) { (error, reference) in
                    if let err = error {
                        SVProgressHUD.showError(withStatus: "Error writing to database")
                        SVProgressHUD.dismiss(withDelay: 1)
                        print(err)
                        self.addNewClientButton.isEnabled = true
                    } else {
                        self.addNewClientButton.isEnabled = true
                        self.createdClient = true
                        SVProgressHUD.dismiss()
                        self.pasteAlert()
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.realm.refresh()
        someDelegate.callToReloadData()
        someDelegate.nilSelectedClient()
        if createdClient {
            SVProgressHUD.showSuccess(withStatus: "Client Created")
            SVProgressHUD.dismiss(withDelay: 1)
        }
    }

}
