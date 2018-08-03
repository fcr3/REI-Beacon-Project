//
//  CustomCell.swift
//  REIBeaconsApp
//
//  Created by Flaviano Reyes on 6/11/18.
//  Copyright © 2018 Christian Reyes. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var CustomCellImg: UIImageView!
    @IBOutlet weak var TextBackground: UIImageView!
    @IBOutlet weak var CustomCellText: UILabel!
    
//    @IBOutlet weak var CustomCellText: UILabel!
//    @IBOutlet weak var background: NSLayoutConstraint!
//    @IBOutlet weak var TextBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
