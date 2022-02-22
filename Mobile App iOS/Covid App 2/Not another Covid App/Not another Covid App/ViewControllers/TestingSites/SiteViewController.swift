//
//  SiteViewController.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 26/8/21.
//

import UIKit

class SiteViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var facilitiyTypeLabel: UILabel!
    @IBOutlet weak var adressLabel: UITextView!
    @IBOutlet weak var websiteLabel: UITextView!
    @IBOutlet weak var phoneLabel: UITextView!
    @IBOutlet weak var siteFacilitiesLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var requirementsLabel: UILabel!
    @IBOutlet weak var trackerLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var serviceFormatLabel: UILabel!
    @IBOutlet weak var otherInfoLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var site: TestingSiteData?

    override func viewDidLoad() {
        super.viewDidLoad()
//        scrollView.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height+100)

        // Do any additional setup after loading the view.
        guard let site = site else {
         return
        }
        
        nameLabel.text = site.siteName
        facilitiyTypeLabel.text = site.facility
        adressLabel.text = site.address + ", " + site.suburb + " " + site.state + " " + site.postcode
        
        if (site.website == nil){
            websiteLabel.text = "Website not found"
        } else{
            websiteLabel.text = site.website
        }
        
        if (site.phone == nil){
            phoneLabel.text = "Phone number not found"
        } else{
            phoneLabel.text = site.phone
        }
        
        if (site.siteFacilities == nil){
            siteFacilitiesLabel.text = "No information."
        } else{
            siteFacilitiesLabel.text = site.siteFacilities
        }
        
        if (site.openingHours == nil){
            hoursLabel.text = "No information."
        } else{
            hoursLabel.text = site.openingHours
        }
        
        if (site.requirements == nil){
            requirementsLabel.text = "No requirements."
        } else{
            requirementsLabel.text = site.requirements
        }
        
        trackerLabel.text = site.testTracker
        
        if (site.ageLimit == nil){
            ageLabel.text = "No infomation."
        } else{
            ageLabel.text = site.ageLimit
        }
    
        serviceFormatLabel.text = site.serviceFormat
        
        if (site.addressOther == nil){
            otherInfoLabel.text = "No infomation."
        } else{
            otherInfoLabel.text = site.addressOther
        }
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
