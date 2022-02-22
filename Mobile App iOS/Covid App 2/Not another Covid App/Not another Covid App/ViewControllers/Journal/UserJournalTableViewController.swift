//
//  UserJournalTableViewController.swift
//  Not another Covid App
//
//  Created by adam luqman on 19/08/2021.
//

import UIKit
import Firebase

class UserJournalTableViewController: UITableViewController, DatabaseListener {
    
    func onLocationChange(change: DatabaseChange, locations: [Locations]) {
        allLocations = locations
        tableView.reloadData()
    }
    
    @IBAction func exportBtn(_ sender: Any) {
        pdfDataWithTableView(tableView: self.tableView)
        print("pdf clicked")
    }
    
    let SECTION_LOCATIONS = 0
    let CELL_LOCATIONS = "locationCell"
    var listenerType: ListenerType = .Locations
    weak var databaseController: DatabaseProtocol?
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var usersRef = Firestore.firestore().collection("users")
    var locationsRef: CollectionReference?
    var snapShotListener: ListenerRegistration?
    var userID = Auth.auth().currentUser?.uid
    
    var allLocations = [Locations]()
//    var allLocations: [Locations] = []


    override func viewDidLoad() {
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        //Get reference to locations collection
        locationsRef = usersRef.document(userID!).collection("locations")
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        //Get snapshot of all user's scanned location
        //Each location is then stored to allLocations list
        snapShotListener = locationsRef?.addSnapshotListener() {
            (querySnapshot, error) in
            
            if let error = error {
                print(error)
                return
            }
            self.allLocations.removeAll()
            querySnapshot?.documents.forEach() { snapshot in
                let locationID = snapshot["ID"] as! String
                let locationName = snapshot["location"] as! String
                let postcode = snapshot["postcode"] as! String
                let date = snapshot["date"] as! String
                let time = snapshot["time"] as! String
                let lattitude = snapshot["lattitude"] as! Double
                let longitude = snapshot["longitude"] as! Double
                
                let newLocation = Locations()
                newLocation.id = locationID
                newLocation.location = locationName
                newLocation.date = date
                newLocation.time = time
                newLocation.lattitude = lattitude
                newLocation.longitude = longitude
                newLocation.postcode = postcode
                
                //Delete the scanned locations where the dates exceeds the 16 day period.
                let maxDay = 16
                let current_date = Date()
                let date_formatter = DateFormatter()
                date_formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                let current_day = date_formatter.string(from: current_date)
                
                let calendar = Calendar.current
                
                // Replace the hour (time) of both dates with 00:00
                let date1 = calendar.startOfDay(for: date_formatter.date(from: current_day)!)
                
                let date2 = calendar.startOfDay(for: date_formatter.date(from: newLocation.date!)!)
                
                let components = calendar.dateComponents([.day], from: date1, to: date2)
                let day_diff = abs(components.day!)
                print(day_diff)
                
                if day_diff > maxDay {
                    //delete
                    self.locationsRef?.document(newLocation.id!).delete()
                }else{
                    self.allLocations.append(newLocation)
                }
            }
            //sort array by date here use the inbuild sorting func array.sort(comparison func)
//            allLocations.sorted(by: {$0.time > $1.time})
            
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        snapShotListener?.remove()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allLocations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATIONS, for: indexPath) as! UserJournalTableViewCell
        
        let location = allLocations[indexPath.row]
        print(location)
        
        let locationName = location.location
        let date = self.getDate(date: location.date!) as! String
        let time = location.time!
        
        cell.addressLbl.text = locationName
        cell.dateTimeLbl.text = date + " at " + time
        
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

    
    func getDate(date: String) -> Any{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let newDateFormatter = DateFormatter()
        newDateFormatter.timeZone = TimeZone.current
        newDateFormatter.dateFormat = "dd-MM-yyyy"
        
        var reVal = ""
        
        if let d = dateFormatter.date(from: date) {
            reVal = newDateFormatter.string(from: d)
        }
//        else {
//            reVal = "There was an error decoding the date"
//         }
//        return newDateFormatter.date(from: reVal)!
        return reVal
    }
    
    func pdfDataWithTableView(tableView: UITableView) {
            let priorBounds = tableView.bounds
            let fittedSize = tableView.sizeThatFits(CGSize(width:priorBounds.size.width, height:tableView.contentSize.height))
            tableView.bounds = CGRect(x:0, y:0, width:fittedSize.width, height:fittedSize.height)
            let pdfPageBounds = CGRect(x:0, y:0, width:tableView.frame.width, height:self.view.frame.height)
            let pdfData = NSMutableData()
            UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds,nil)
            var pageOriginY: CGFloat = 0
            while pageOriginY < fittedSize.height {
                UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
                UIGraphicsGetCurrentContext()!.saveGState()
                UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
                tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
                UIGraphicsGetCurrentContext()!.restoreGState()
                pageOriginY += pdfPageBounds.size.height
            }
            UIGraphicsEndPDFContext()
            tableView.bounds = priorBounds
            var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            docURL = docURL.appendingPathComponent("myDocument.pdf")
            pdfData.write(to: docURL as URL, atomically: true)
        }
}

