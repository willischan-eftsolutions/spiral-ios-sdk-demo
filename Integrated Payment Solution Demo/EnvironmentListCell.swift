//
//  EnvironmentListCell.swift
//  Integrated Payment Solution Demo
//
//  Created by kam on 10/8/2021.
//  Copyright © 2021 EFT Solutions. All rights reserved.
//

import UIKit

class EnvironmentListCell: UITableViewCell {
    @IBOutlet var environmentLabel: UILabel!
    
    func config(name: String) {
        environmentLabel.text = name
    }
}
