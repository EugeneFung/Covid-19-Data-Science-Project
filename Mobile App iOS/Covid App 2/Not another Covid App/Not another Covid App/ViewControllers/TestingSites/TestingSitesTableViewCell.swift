//
//  TestingSitesTableViewCell.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 25/8/21.
//

import UIKit

class TestingSitesTableViewCell: UITableViewCell {

    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ageLimitLabel: UILabel!
    @IBOutlet weak var serviceFormatLabel: UILabel!
    @IBOutlet weak var appointmentLabel: UILabel!
    @IBOutlet weak var wheelchairLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
