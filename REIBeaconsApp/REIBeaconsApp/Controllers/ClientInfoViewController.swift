//
//  ClientInfoViewController.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 6/14/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import SVProgressHUD

protocol tableUpdaterDelegate {
    func callToReloadData()
}

class ClientInfoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var minuteTextField: UITextField!
    @IBOutlet weak var amPmTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editCancelButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var client : clientREI!
    var textFieldArray : [UITextField]!
    var infoArray : [String] = [String]()
    var previousInfoArray : [String]!
    let realm = try! Realm()
    var clientTableView : tableUpdaterDelegate!
    
    /*
     @objc dynamic var id : String = ""
     @objc dynamic var date : String = "n/a" // yyyy-mm-dd
     @objc dynamic var loc : String = "n/a"
     @objc dynamic var person : String = "n/a"
     @objc dynamic var room : String = "n/a"
     @objc dynamic var time : String = "n/a" // hh-mm-am/pm
     @objc dynamic var wantsDrink : String = "false"
     @objc dynamic var drink : String = "n/a"
     @objc dynamic var completedPrompt2 : String = "n/a"
     @objc dynamic var visitedLocs : String = "n/a"
     */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Settting up delegate permissions and reference array
        textFieldArray.append(nameTextField)
        textFieldArray.append(roomTextField)
        textFieldArray.append(locationTextField)
        textFieldArray.append(monthTextField)
        textFieldArray.append(dayTextField)
        textFieldArray.append(yearTextField)
        textFieldArray.append(hourTextField)
        textFieldArray.append(minuteTextField)
        textFieldArray.append(amPmTextField)
        for textField in textFieldArray {
            textField.delegate = self
        }
        
        // Editing Texts
        idLabel.text = client.id
        nameTextField.text = client.person
        infoArray.append(nameTextField.text!)
        
        roomTextField.text = client.room
        infoArray.append(roomTextField.text!)
        
        locationTextField.text = client.loc
        infoArray.append(locationTextField.text!)
        
        let dateArray = client.date.split(separator: "-")
        monthTextField.text = dateArray[1] + ""
        infoArray.append(monthTextField.text!)
        dayTextField.text = dateArray[2] + ""
        infoArray.append(dayTextField.text!)
        yearTextField.text = dateArray[0] + ""
        infoArray.append(yearTextField.text!)
        
        let timeArray = client.time.split(separator: "-")
        hourTextField.text = timeArray[0] + ""
        infoArray.append(hourTextField.text!)
        minuteTextField.text = timeArray[1] + ""
        infoArray.append(minuteTextField.text!)
        amPmTextField.text = timeArray[2] + ""
        infoArray.append(amPmTextField.text!)
        
        // Editing and Hiding Buttons
        saveButton.isHidden = true
        saveButton.isEnabled = false
        editCancelButton.setTitle("Edit", for: .normal)
        toggleEnabling(setTo: false)
    }
    
    // MARK: - TextField Functions
    func textFieldDidEndEditing(_ textField: UITextField) {
        var hasError = false
        if textField.tag == 3 || textField.tag == 4
            || textField.tag == 6 || textField.tag == 7  || textField.tag == 8{
            if textField.text!.count > 2 {
                SVProgressHUD.showError(withStatus: "Max Length of 2")
                hasError = true
            }
        }
        if textField.tag == 5 && textField.text!.count > 4 {
            SVProgressHUD.showError(withStatus: "Max Length of 4")
            hasError = true
        }
        if hasError || textField.text! == "" {
            textField.text = infoArray[textField.tag]
        }
        if !hasError && textField.text != infoArray[textField.tag] {
            saveButton.isEnabled = true
            saveButton.isHidden = false
            infoArray[textField.tag] = textField.text ?? ""
        }
    }
    
    func toggleEnabling(setTo bool : Bool) {
        for textField in textFieldArray {
            textField.isEnabled = bool
        }
    }
    
    func revertToPreviousInfo() {
        infoArray.removeAll()
        for info in previousInfoArray {
            infoArray.append(info)
        }
        for textField in textFieldArray {
            textField.text = infoArray[textField.tag]
        }
    }
    
    // MARK: - Button Functions
    @IBAction func enableEditing(_ sender: UIButton) {
        if sender.titleLabel?.text == "Edit" {
            sender.setTitle("Cancel", for: .normal)
            previousInfoArray.removeAll()
            for info in infoArray {
                previousInfoArray.append(info)
            }
            toggleEnabling(setTo: true)
        } else {
            sender.setTitle("Edit", for: .normal)
            toggleEnabling(setTo: false)
            revertToPreviousInfo()
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveButton.isEnabled = false
        backButton.isEnabled = false
        editCancelButton.isEnabled = false
        do {
            try self.realm.write {
                client.editId(self.idLabel.text!)
                client.editPerson(self.infoArray[0])
                client.editRoom(self.infoArray[1])
                client.editLoc(self.infoArray[2])
                client.editDate(self.infoArray[3] + "-" + self.infoArray[4] + "-" + self.infoArray[5])
                client.editTime(self.infoArray[6] + "-" + self.infoArray[7] + "-" + self.infoArray[8])
            }
        } catch {
            SVProgressHUD.showError(withStatus: "Error writing to persistent database")
            saveButton.isEnabled = true
            backButton.isEnabled = true
            editCancelButton.isEnabled = true
            print(error)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if saveButton.isEnabled {
            let alert = UIAlertController(title: "Unsaved Changes Made", message: "Would you like to disregard your most recently made changes?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                // what will happen when user clicks button
                self.clientTableView.callToReloadData()
                self.dismiss(animated: true, completion: nil)
            }
            let noAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                // what will happen when user clicks button
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        } else {
            self.clientTableView.callToReloadData()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - API Call Function
    func saveData(_ id : String) {
        let db = Database.database().reference().child("Clients")
        let post = self.client.clientREIDictionary()
        db.child(id).setValue(post) {
            (error, reference) in
            if let err = error {
                SVProgressHUD.showError(withStatus: "Error writing to database")
                self.saveButton.isEnabled = true
                self.backButton.isEnabled = true
                self.editCancelButton.isEnabled = true
                print(err)
            } else {
                self.saveButton.isHidden = true
                self.editCancelButton.isEnabled = true
                self.editCancelButton.setTitle("Edit", for: .normal)
            }
        }
    }

}
