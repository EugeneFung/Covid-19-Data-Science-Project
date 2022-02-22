//
//  UserJournalTableViewCell.swift
//  Not another Covid App
//
//  Created by adam luqman on 19/08/2021.
//

import UIKit

class UserJournalTableViewCell: UITableViewCell {

    @IBOutlet weak var dateTimeLbl: UILabel!
    
    @IBOutlet weak var addressLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
