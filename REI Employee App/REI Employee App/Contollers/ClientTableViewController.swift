//
//  ClientTableViewController.swift
//  REI Employee App
//
//  Created by Flaviano Reyes on 6/16/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.

import UIKit
import ChameleonFramework
import SVProgressHUD
import RealmSwift
import Firebase
import FirebaseMessaging
import FirebaseDatabase
import FirebaseAuth

class ClientTableViewController: UITableViewController, tableViewUpdater {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var emp : employee! {
        didSet {
            loadData()
        }
    }
    var clientArr : [client]!
    var goingForwards : Bool = false
    var canDelete : Bool = false
    var selectedClient : client!
    var searchBarText : String!
    let realm = try! Realm()
    var db : DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        db = Database.database().reference().child("Clients")
        tableView.rowHeight = 70
        searchBar.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ClientInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "ClientInfoTableViewCell")
        setUpObservers()
        if emp != nil && emp.name == "" {
            setName()
        }
    }
    
    // MARK: - Protocol Functions
    
    func callToReloadData() {
        loadData()
        setUpObservers()
        tableView.reloadData()
        tableView.isUserInteractionEnabled = true
    }
    
    func accessToDb() -> DatabaseReference {
        return db
    }
    
    func nilSelectedClient() {
        selectedClient = nil
        goingForwards = false
    }
    
    // MARK: - UI Element Functions
    
    func setName() {
        let alert = UIAlertController(title: "Set Name", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let addNameAction = UIAlertAction(title: "Set Now", style: .default) { (action) in
            // what will happen when user clicks button
            if textField.text != "" {
                // Save to Persistent Database
                do {
                    try self.realm.write{
                        self.emp.name = textField.text!
                    }
                } catch { print(error)}
                
                // Save to Database
                let newdb = Database.database().reference().child("Employees")
                newdb.child(self.emp.email.split(separator: ".")[0] + "").setValue(self.emp.employeeDictionary()) { (error, reference) in
                    if let err = error {
                        print(err)
                    } else {
                        self.toggleEverything(to: true)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Set Later", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter your name"
            textField = alertTextField
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addNameAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func pressedAddButton(_ sender: Any) {
        let alert = UIAlertController(title: "Add New Client", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            // what will happen when user clicks button
            if textField.text != "" {
                let newClient = client()
                newClient.person = textField.text!
                newClient.emp = self.emp.email
                newClient.empName = self.emp.name
                self.selectedClient = newClient
                self.goingForwards = true
                self.performSegue(withIdentifier: "goToMakeNewClientView", sender: self)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Client"
            textField = alertTextField
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pressedSettings(_ sender: UIBarButtonItem) {
        self.goingForwards = true;
        self.performSegue(withIdentifier: "goToSettingsView", sender: self)
    }
    
    
    // MARK: - Setting up Observers
    
    func setUpObservers() {
        db.removeAllObservers()
        for cl in self.emp.clients {
            let observer = db.child(cl.id).observe(.value) { (snapshot) in
                if snapshot.value != nil, let snapVal = snapshot.value as? Dictionary<String,String> {
                    if !cl.drink.elementsEqual(snapVal["drink"]!) {
                        cl.drink = snapVal["drink"]!
                        cl.checked = self.selectedClient != nil ? cl.id.elementsEqual(self.selectedClient.id) : false
                    }
                    if !cl.loc.elementsEqual(snapVal["loc"]!) {
                        cl.loc = snapVal["loc"]!
                        cl.checked = self.selectedClient != nil ? cl.id.elementsEqual(self.selectedClient.id) : false
                    }
                    if !cl.checkedIn.elementsEqual(snapVal["checkedIn"]!) {
                        cl.checkedIn = snapVal["checkedIn"]!
                        cl.checked = self.selectedClient != nil ? cl.id.elementsEqual(self.selectedClient.id) : false
                    }
                    cl.visitedLocs = snapVal["visitedLocs"]!
                    cl.wantsDrink = snapVal["wantsDrink"]!
                    cl.time = snapVal["time"]!
                    cl.date = snapVal["date"]!
                    self.loadData()
                    self.tableView.reloadData()
                } else {
                    self.beginDeletion(for: cl)
                }
            }
            do {
                try self.realm.write {
                    cl.tableObserver = Int(observer)
                    print("made observer in table View")
                }
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Disabling/Enabling UI so API can catch up
    
    func toggleEverything(to bool : Bool) {
        searchBar.isUserInteractionEnabled = bool
        tableView.isUserInteractionEnabled = bool
        for cells in tableView.visibleCells {
            cells.isUserInteractionEnabled = bool
        }
        addButton.isEnabled = bool
        navBar.backBarButtonItem?.isEnabled = bool
    }
    
    // MARK: - Deleting Clients
    
    func beginDeletion(for cl : client) {
        self.deleteClientFromMemory(who: cl)
        let newdb = Database.database().reference().child("Employees")
        newdb.child(self.emp.email.split(separator: ".")[0] + "").setValue(self.emp.employeeDictionary()) { (error, reference) in
            if let err = error {
                print(err)
            } else {
                self.toggleEverything(to: true)
            }
        }
    }

    func deleteClientFromDatabase(who id : String) {
        db.child(id).removeValue() { (error, reference) in
            if let err = error {
                print(err)
            } else {
                let newdb = Database.database().reference().child("Employees")
                newdb.child(self.emp.email.split(separator: ".")[0] + "").setValue(self.emp.employeeDictionary()) { (error, reference) in
                    if let err = error {
                        print(err)
                    } else {
                        self.toggleEverything(to: true)
                    }
                }
            }
        }
    }
    
    func deleteClientFromMemory(who cl : client) {
        self.db.removeObserver(withHandle: DatabaseHandle(cl.tableObserver))
        var index = 0
        for clientIds in self.emp.clientIds {
            if cl.id.elementsEqual(clientIds) {
                self.emp.clientIds.remove(at: index)
                break
            }
            index = index + 1
        }
        index = 0
        for client in self.emp.clients {
            if cl.id.elementsEqual(client.id) {
                self.emp.clients.remove(at: index)
                break
            }
            index = index + 1
        }
    }
    
    // MARK: - Load and Organize Data
    
    func loadData() {
        if !self.emp.clients.isEmpty {
            if searchBar != nil  && searchBarText != nil && searchBarText != "" {
                searchBarLoadData()
                return
            }
            
            canDelete = true
            clientArr = self.emp.clients.sorted(by: { (client1, client2) -> Bool in
                let client1Arr = organizationArray(for: client1)
                let client2Arr = organizationArray(for: client2)
                if client1Arr["date"]! > client2Arr["date"]! {
                    return true
                } else if client1Arr["date"]! < client2Arr["date"]! {
                    return false
                } else {
                    if client1Arr["time"]! > client2Arr["time"]! {
                        return false
                    } else if client1Arr["time"]! < client2Arr["time"]! {
                        return true
                    }
                }
                return client1.id < client2.id
            })
            
        } else {
            canDelete = false
            clientArr = [client]()
        }
    }
    
    func organizationArray(for cl : client) -> [String : Int] {
        let dateArray = cl.date.split(separator: "-")
        let timeArray = cl.time.split(separator: "-")
        var militaryTime = 0
        if (timeArray[2] == "AM") {
            militaryTime = militaryTime + Int(timeArray[0])!*100 + Int(timeArray[1])!
        } else {
            militaryTime = militaryTime + (Int(timeArray[0])!+12)*100 + Int(timeArray[1])!
        }
        return ["date" : Int(dateArray[0])!*10000 + Int(dateArray[1])!*100 + Int(dateArray[2])!,
                "time" : militaryTime]
    }
    
    // MARK: - Custom Table Swipe Functions
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)

        return UISwipeActionsConfiguration(actions: [delete])
    }

    func deleteAction(at indexPath : IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            if self.canDelete {
                self.tableView.isUserInteractionEnabled = false
                for cells in self.tableView.visibleCells {
                    cells.isUserInteractionEnabled = false
                }
                let clientId = self.clientArr[indexPath.row].id
                self.toggleEverything(to: false)
                self.deleteClientFromMemory(who: self.clientArr[indexPath.row])
                self.deleteClientFromDatabase(who: clientId)
                self.loadData()
                //self.tableView.deleteRows(at: [indexPath], with: .automatic)

                completion(true)
                self.tableView.isUserInteractionEnabled = true
                for cells in self.tableView.visibleCells {
                    cells.isUserInteractionEnabled = true
                }
            }
        }
        action.backgroundColor = UIColor.red
        return action
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
    }
    */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.emp.clients.isEmpty ? 0 : clientArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ClientInfoTableViewCell", for: indexPath) as! ClientInfoTableViewCell
        let checked = clientArr[indexPath.row].checked
        let green = UIColor.init(hexString: "91DC5A")
        let blue = UIColor.init(hexString: "006DF0")
        
        cell.clientIdLabel.text = clientArr[indexPath.row].person.split(separator: " ")[0] + ""
        cell.clientIdLabel.textColor = checked ? blue : UIColor.white
        cell.backgroundImgView.layer.cornerRadius = 20.0
        cell.backgroundImgView.backgroundColor = checked ? green : UIColor.flatPowderBlue()
        cell.clientIdLabel.font =  checked ? UIFont(name: "HelveticaNeue-Bold", size: 20.0) : UIFont(name: "HelveticaNeue-Bold", size: 20.0)
        let dateArray = clientArr[indexPath.row].date.split(separator: "-")
        let timeArray = clientArr[indexPath.row].time.split(separator: "-")
        let dateString = "\(dateArray[1])-\(dateArray[2])-\(dateArray[0])"
        let timeString = "\(timeArray[0]):\(timeArray[1]) \(timeArray[2])"
        cell.clientDateAndTime.text = dateString + " " + timeString
        cell.clientDateAndTime.textColor = checked ? blue : UIColor.flatWhite()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.emp.clients.isEmpty {
            selectedClient = clientArr[indexPath.row]
            goingForwards = true
            performSegue(withIdentifier: "goToClientInfoView", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToClientInfoView" {
            let destinationVC = segue.destination as! ClientInfoViewController
            destinationVC.cl = self.selectedClient
            self.selectedClient.checked = true
            destinationVC.emp = self.emp
            destinationVC.protocolDelegate = self
        }
        if segue.identifier == "goToMakeNewClientView" {
            let destinationVC = segue.destination as! MakeNewClientViewController
            destinationVC.cl = self.selectedClient
            destinationVC.emp = self.emp
            destinationVC.someDelegate = self
        }
        if segue.identifier == "goToSettingsView" {
            let destinationVC = segue.destination as! SettingViewController
            destinationVC.emp = self.emp
            destinationVC.protocolDelegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if !goingForwards {
            self.emp.clientIds.removeAll()
            self.emp.clients.removeAll()
            do {
                try Auth.auth().signOut()
                try self.realm.write {
                    self.realm.delete(realm.objects(employee.self))
                    self.realm.delete(realm.objects(client.self))
                    self.realm.deleteAll()
                }
            } catch {
                print(error)
            }
            // Messaging.messaging().unsubscribe(fromTopic: emp.email.split(separator: ".")[0] + "")
            InstanceID.instanceID().deleteID { (error) in
                if let error = error {print(error)}
            }
            db.removeAllObservers()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
        tableView.reloadData()
        goingForwards = false
        tableView.isUserInteractionEnabled = true
    }

}

extension ClientTableViewController : UISearchBarDelegate {
    
    // MARK: - Search Bar Functions
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBarText = searchBar.text
            searchBarLoadData()
        }
    
    func searchBarLoadData() {
        clientArr = self.emp.clients.filter({ (client) -> Bool in
            return client.person.range(of: searchBar.text!) != nil || client.person.lowercased().range(of: searchBar.text!) != nil
        })
        clientArr = clientArr.sorted(by: { (client1, client2) -> Bool in
            let client1Arr = organizationArray(for: client1)
            let client2Arr = organizationArray(for: client2)
            if client1Arr["date"]! > client2Arr["date"]! {
                return true
            } else if client1Arr["date"]! < client2Arr["date"]! {
                return false
            } else {
                if client1Arr["time"]! > client2Arr["time"]! {
                    return false
                } else if client1Arr["time"]! < client2Arr["time"]! {
                    return true
                }
            }
            return client1.id < client2.id
        })
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.count == 0) {
            searchBarText = ""
            loadData()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
