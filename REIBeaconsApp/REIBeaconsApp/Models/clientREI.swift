//
//  clientREI.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 6/11/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import Foundation
import RealmSwift

class clientREI : Object {
    
    //TODO: Messages need a messageBody and a sender variable
    var id : String = ""
    
    var date : String = "---" // yyyy-mm-dd
    var emp : String = ""
    var loc : String = ""
    var person : String = ""
    var room : String = ""
    var time : String = "---"
    var wantsDrink : String = "false"
    var drink : String = ""
    var visitedLocs : String = ""
    var checkedIn : String = ""
    var empName : String = ""
    
    var messages = [""]
    
    func clientREIDictionary() -> [String : String] {
        return ["id" : id,
                "date" : date, // 1
                "emp" : emp, // 2
                "empName" : empName,
                "loc" : loc, // 3
                "checkedIn" : checkedIn,
                "person" : person, // 4
                "room" : room, // 5
                "time" : time, // 6
                "drink" : drink, // 7
                "visitedLocs" : visitedLocs, // 8
                "wantsDrink" : wantsDrink,
                "messages" : messages.joined(separator: ",")] // 10
    }
    
}
