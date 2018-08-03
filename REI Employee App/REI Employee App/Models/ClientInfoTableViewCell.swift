//
//  ClientInfoTableViewCell.swift
//  REI Employee App
//
//  Created by Flaviano Reyes on 6/16/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit

class ClientInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var clientIcon: UIImageView!
    @IBOutlet weak var clientIdLabel: UILabel!
    @IBOutlet weak var clientDateAndTime: UILabel!
    @IBOutlet weak var backgroundImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
