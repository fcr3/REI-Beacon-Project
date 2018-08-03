//
//  employee.swift
//  REI Employee App
//
//  Created by Flaviano Reyes on 6/16/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import Foundation
import RealmSwift

class employee : Object {
    @objc dynamic var email : String = ""
    @objc dynamic var name : String = ""
    @objc dynamic var token : String = ""
    var clients : [client] = [client]()
    var clientIds : [String] = [String]()
    @objc dynamic var password : String = ""
    
    func employeeDictionary() -> [String : String]{
        var clientString = ""
        var index = 0
        for client in self.clientIds {
            if (index + 1 != self.clientIds.count) {
                clientString = clientString + client + ","
            } else {
                clientString = clientString + client
            }
            index = index + 1
        }
        return ["clientIds" : clientString, "name" : name, "token" : token, "current" : (UIDevice.current.identifierForVendor?.uuidString)!]
    }
}
