//
//  ReaderTableViewCell.swift
//  Scoops
//
//  Created by JJLZ on 4/9/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit

class ReaderTableViewCell: UITableViewCell {
    
    // MARK: IBOutlet's
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    
    // MARK: ViewController Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
