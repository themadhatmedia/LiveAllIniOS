//
//  LibraryTableViewCell.swift
//  LiveAllIn
//
//  Created by madhatmedia on 25/11/2019.
//  Copyright © 2019 madhatmedia. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {

    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var getButton: UIButton!
    
    @IBOutlet weak var getButtonStyle: UIButton!
    
    @IBOutlet weak var getLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
