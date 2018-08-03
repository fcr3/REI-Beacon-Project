//
//  EmpScreenTableViewController.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 6/14/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class EmpScreenTableViewController: UITableViewController, UINavigationBarDelegate, tableUpdaterDelegate {

    var emp : employeeREI!
    var clientArray : List<clientREI>?
    var selectedClient : clientREI!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if clientArray?.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "placeholderCell", for: indexPath)
            cell.textLabel?.text = "No Categories Added Yet"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "empClientCell", for: indexPath) as! empClientCell
        cell.idLabel.text = clientArray?[indexPath.row].id
        cell.cellImage.image = UIImage(named: "hurricane_green")
        cell.date.text = clientArray?[indexPath.row].date
        cell.time.text = clientArray?[indexPath.row].time
        return cell
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCl = clientArray?[indexPath.row] {
            selectedClient = selectedCl
            performSegue(withIdentifier: "goToClientInfo", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Button Functions
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToClientInfo" {
            let destinationVC = segue.destination as! ClientInfoViewController
            destinationVC.client = selectedClient
            destinationVC.clientTableView = self
        }
    }
    
    // MARK: - tableUpdaterDelegate Functions
    
    func callToReloadData() {
        tableView.reloadData()
    }

}
