//
//  ExposureSiteTableViewCell.swift
//  Not another Covid App
//
//  Created by adam luqman on 03/10/2021.
//

import UIKit

class ExposureSiteTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var journalAddressLbl: UILabel!
    @IBOutlet weak var journalTimeLbl: UILabel!
    @IBOutlet weak var exposedAddressLbl: UILabel!
    @IBOutlet weak var exposedTimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
