//
//  employeeREI.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 6/14/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import Foundation
import RealmSwift

class employeeREI : Object {
    
    @objc dynamic var email : String = ""
    @objc dynamic var name : String = ""
    let clients = List<clientREI>()
    let clientIds = List<String>()
    @objc dynamic var password : String = ""
    
}
