//
//  ShoppingListTableViewCell.swift
//  Roomy
//
//  Created by Darius on 2015. 05. 19..
//  Copyright (c) 2015. Darius. All rights reserved.
//

import UIKit

class ShoppingListTableViewCell: UITableViewCell {

    @IBOutlet weak var ShoppingItemTitle: UILabel!
    @IBOutlet weak var ShoppingItemButton: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
