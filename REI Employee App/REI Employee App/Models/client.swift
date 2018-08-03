//
//  client.swift
//  REI Employee App
//
//  Created by Flaviano Reyes on 6/16/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import Foundation
import RealmSwift

class client : Object {
    var id : String = "" // 1
    
    var date : String = "---" // yyyy-mm-dd // 2
    var emp : String = "" // 3
    var empName : String = ""
    
    var checkedIn : String = "false";
    
    var loc : String = "" // 5
    var person : String = "" // 6
    var room : String = "" // 7
    var time : String = "---" // 8 HH-MM-AM/PM
    var wantsDrink : String = "" // 9
    var drink : String = "" // 10
    var visitedLocs : String = "" // 12
    var messages : String = ""
    
    var checked : Bool = true // for flagging users
    var tableObserver : Int = 0 // for firebase observer
    var appDelegateObserver : Int = 0 // for firebase observer
    
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
                "messages" : messages] // 10
    }
    
    func copyClient() -> client{
        let cl = client()
        cl.id = self.id
        cl.date = self.date
        cl.empName = self.empName
        cl.emp = self.emp
        cl.loc = self.loc
        cl.person = self.person
        cl.room = self.room
        cl.time = self.time
        cl.checkedIn = self.checkedIn
        cl.wantsDrink = self.wantsDrink
        cl.drink = self.drink
        cl.visitedLocs = self.visitedLocs
        cl.checked = self.checked
        cl.messages = self.messages
        return cl
    }
}
