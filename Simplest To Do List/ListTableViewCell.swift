//
//  ListTableViewCell.swift
//  Simplest To Do List
//
//  Created by 蓉蓉 邓 on 7/31/16.
//  Copyright © 2016 Fancy boy. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var aList: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
