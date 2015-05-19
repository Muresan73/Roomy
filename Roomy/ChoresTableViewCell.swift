//
//  ChoresTableViewCell.swift
//  Roomy
//
//  Created by Darius on 2015. 04. 10..
//  Copyright (c) 2015. Darius. All rights reserved.
//

import UIKit

class ChoresTableViewCell: UITableViewCell {

    @IBOutlet weak var choreTitle: UILabel!
    @IBOutlet weak var choreButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
