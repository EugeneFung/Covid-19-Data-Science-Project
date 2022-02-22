//
//  HomeViewController.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 12/8/21.
//

import UIKit
import FirebaseAuth
import Firebase
import CoreLocation

class HomeViewController: UIViewController {
    
    @IBOutlet weak var exposedSitesLbl: UILabel!
    
    var exposureSitesList: [ExposureSiteData] = []
    
    var journalLocations = [Locations]()
    
    var matchExposedSitesList: [(ExposureSiteData, Locations)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(matchExposedSitesList.count)
        if matchExposedSitesList.count == 0{
            exposedSitesLbl.textColor = UIColor(red: 144.0/255, green: 238.0/255, blue: 144.0/255, alpha: 1.0)
        } else {
            exposedSitesLbl.textColor = UIColor.red
        }
        exposedSitesLbl.text = String(matchExposedSitesList.count)
        print(matchExposedSitesList.count)
        //if self.matchExposedSitesList.count == []{}
        //print(matchExposedSitesList[0].0.sitePostcode!)
        //print(matchExposedSitesList[0].1.postcode!)
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "exposureSitesSegue" {
            let destination = segue.destination as! ExposureSitesTableViewController
            print(matchExposedSitesList.count)
            destination.exposureSitesList = self.matchExposedSitesList
        }
    }
    
    
    
    
}
