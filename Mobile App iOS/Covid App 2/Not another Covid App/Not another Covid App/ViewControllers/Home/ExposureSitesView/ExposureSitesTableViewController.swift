//
//  ExposureSitesTableViewController.swift
//  Not another Covid App
//
//  Created by adam luqman on 03/10/2021.
//

import UIKit

class ExposureSitesTableViewController: UITableViewController {
    
    
    var exposureSitesList: [(ExposureSiteData, Locations)] = []
    
    let SECTION_LOCATIONS = 0
    let CELL_LOCATIONS = "locationCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(exposureSitesList.count)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return exposureSitesList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATIONS, for: indexPath) as! ExposureSiteTableViewCell

        // Configure the cell...
        let location = exposureSitesList[indexPath.row]
        let journalLocation = location.1
        let exposedLocation = location.0
        
        cell.dateLbl.text = self.getDate(date: journalLocation.date!)
        cell.journalAddressLbl.text = journalLocation.location
        cell.journalTimeLbl.text = journalLocation.time
        
        cell.exposedAddressLbl.text = exposedLocation.siteTitle
        cell.exposedTimeLbl.text = exposedLocation.exposureTime
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //function below converts iso date to date string format
    func getDate(date: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let newDateFormatter = DateFormatter()
        newDateFormatter.timeZone = TimeZone.current
        newDateFormatter.dateFormat = "MM/dd/yyyy"
        
        var reVal = ""
        
        if let d = dateFormatter.date(from: date) {
            reVal = newDateFormatter.string(from: d)
        }

        return reVal
    }
    
    //function below converts time to iso format
    func getTime(date: String) -> Any{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        var reVal = ""
        
        if let d = dateFormatter.date(from: date) {
            //reVal = newDateFormatter.string(from: d)
            reVal = timeFormatter.string(from: d)
        }

        return reVal
    }
    
    //function below converts a date to iso format
    func getISO(date: String) -> Any{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let newDateFormatter = DateFormatter()
        newDateFormatter.timeZone = TimeZone.current
        newDateFormatter.dateFormat = "MM/dd/yyyy"
        
        var reVal = ""
        
        if let d = newDateFormatter.date(from: date) {
            reVal = dateFormatter.string(from: d)
        }

        return reVal
    }
    
    //function below converts string time to iso format
    func getISOTime(date: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone.current
        timeFormatter.timeStyle = .short
        
        var reVal = ""
        
        if let d = timeFormatter.date(from: date) {
            reVal = dateFormatter.string(from: d)
        }

        return reVal
    }

}
