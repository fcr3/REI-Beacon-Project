//
//  ClientInfoViewController.swift
//  REI Employee App
//
//  Created by Flaviano Reyes on 6/16/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

protocol tableViewUpdater {
    func callToReloadData()
    func accessToDb() -> DatabaseReference
    func nilSelectedClient()
}

class ClientInfoViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var meetRmTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editCancelButton: UIBarButtonItem!
    @IBOutlet weak var drinkTextField: UITextField!
    @IBOutlet weak var checkInTextField: UITextField!
    @IBOutlet weak var idButton: UIButton!
    
    var prevClient : client!
    var emp : employee!
    var protocolDelegate : tableViewUpdater!
    let realm = try! Realm()
    var cl : client!
    var db : DatabaseReference!
    var observer : DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if cl != nil {
            loadData()
            setUpSelfObserver()
        }
    }
    
    // MARK: - Fill In Text Fields
    
    func loadData() {
        locationTextField.isEnabled = false
        drinkTextField.isEnabled = false
        if cl.drink != "" {
            drinkTextField.isHidden = false
            drinkTextField.text = cl.drink
        } else {
            drinkTextField.isHidden = true
        }
        
        if cl.checkedIn == "false" {
            checkInTextField.isHidden = true
        } else {
            checkInTextField.text = "Checked In: " + cl.checkedIn
            checkInTextField.isEnabled = false
        }
        
        toggleEnable(to: false)
        
        navBar.title = cl.person
        idButton.setTitle("Copy ID: " + cl.id, for: .normal)
        nameTextField.text = cl.person
        meetRmTextField.text = cl.room
        locationTextField.text = cl.loc
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h-mm-a"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        let someDateTime = formatter.date(from: "\(cl.date) \(cl.time)")
        datePicker.setDate(someDateTime!, animated: true)
    }
    
    // MARK: - Fill in Self Observer
    
    func setUpSelfObserver() {
        db = Database.database().reference().child("Clients")
        observer = db.child(cl.id).observe(.value) { (snapshot) in
            if let snapVal = snapshot.value as? Dictionary<String,String> {
                if !self.cl.drink.elementsEqual(snapVal["drink"]!) {
                    self.cl.drink = snapVal["drink"]!
                }
                if !self.cl.loc.elementsEqual(snapVal["loc"]!) {
                    self.cl.loc = snapVal["loc"]!
                }
                self.cl.checkedIn = snapVal["checkedIn"]!
                self.cl.visitedLocs = snapVal["visitedLocs"]!
                self.cl.wantsDrink = snapVal["wantsDrink"]!
                self.loadData()
            }
        }
    }
    
    // MARK: - Toggle Enabling and Editing
    
    func toggleEnable(to bool : Bool) {
        nameTextField.isEnabled = bool
        nameTextField.allowsEditingTextAttributes = bool
        meetRmTextField.isEnabled = bool
        meetRmTextField.allowsEditingTextAttributes = bool
        datePicker.isEnabled = bool
        saveButton.isEnabled = bool
    }
    
    func toggleEditCancelButton() {
        if editCancelButton.title == "Edit" {
            editCancelButton.title = "Cancel"
        } else {
            editCancelButton.title = "Edit"
        }
    }
    
    // MARK: - UI Element Functions
    
    @IBAction func idButtonPressed(_ sender: UIButton) {
        let pasteItem = sender.title(for: .normal)!.split(separator: " ")[2]
        UIPasteboard.general.string = pasteItem + ""
        SVProgressHUD.showSuccess(withStatus: "Copied to Clipboard")
    }
    
    @IBAction func editCancelButtonPressed(_ sender: UIButton) {
        toggleEditCancelButton()
        if editCancelButton.title == "Edit" {
            toggleEnable(to: false)
            cl = prevClient
            loadData()
        } else {
            toggleEnable(to: true)
            prevClient = cl
            cl = cl.copyClient()
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if checkTextFields() {
            toggleEnable(to: false)
            editCancelButton.isEnabled = false
            SVProgressHUD.show()
            transferDataToClient()
            saveClientToMemory()
            saveClientToDatabase()
            prevClient = nil
        } else {
            SVProgressHUD.showError(withStatus: "Textfields Incorrectly Filled")
        }
    }
    
    func checkTextFields() -> Bool {
        return nameTextField.text != nil && meetRmTextField.text != nil &&
            nameTextField.text != "" && meetRmTextField.text != ""
    }
    
    func transferDataToClient() {
        // cl.id = navBar.title!
        cl.person = nameTextField.text!
        cl.room = meetRmTextField.text!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h-mm-a"
        let dateTimeArr = dateFormatter.string(from: datePicker.date).split(separator: " ")
        cl.date = dateTimeArr[0] + ""
        cl.time = dateTimeArr[1] + ""
    }
    
    // MARK: - Database Functions
    
    func saveClientToMemory() {
        self.prevClient.id = cl.id
        self.prevClient.person = cl.person
        self.prevClient.room = cl.room
        self.prevClient.date = cl.date
    }
    
    func saveClientToDatabase() {
        let db = Database.database().reference().child("Clients")
        db.child(self.prevClient.id).setValue(cl.clientREIDictionary()) { (error, reference) in
            if let err = error {
                SVProgressHUD.showError(withStatus: "Error writing to database")
                print(err)
                self.toggleEnable(to: true)
                self.editCancelButton.isEnabled = true
            } else {
                SVProgressHUD.showSuccess(withStatus: "Saved")
                SVProgressHUD.dismiss()
                self.toggleEnable(to: false)
                self.toggleEditCancelButton()
                self.editCancelButton.isEnabled = true
                self.protocolDelegate.callToReloadData()
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        self.protocolDelegate.callToReloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.realm.refresh()
        self.db.removeObserver(withHandle: observer)
        self.db.removeAllObservers()
        self.protocolDelegate.nilSelectedClient()
        self.protocolDelegate.callToReloadData()
    }

}
