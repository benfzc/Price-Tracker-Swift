//
//  CommodityListTableViewCell.swift
//  PriceTracker
//
//  Created by ben on 2018/7/3.
//  Copyright © 2018年 ben. All rights reserved.
//

import UIKit

class CommodityListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
