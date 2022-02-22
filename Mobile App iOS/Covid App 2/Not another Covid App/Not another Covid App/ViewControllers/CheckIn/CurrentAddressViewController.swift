//
//  CurrentAddressViewController.swift
//  Not another Covid App
//
//  Created by adam luqman on 16/08/2021.
//

import UIKit
import FirebaseAuth
import Firebase

class CurrentAddressViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    var currentAddress: String = " "
    
    //Get User ID
    var currentUser = Auth.auth().currentUser?.uid
    
    var lattitude: Double = 0.0
    var longitude: Double = 0.0
    var postcode: String = ""

    @IBOutlet weak var userAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(currentAddress)
        userAddress.text = currentAddress
        // Do any additional setup after loading the view.
    }
    
    @IBAction func checkInBtn(_ sender: Any) {
        /*
        // Gets current date and time
        let currentDateTime = Date()
        
        // Init the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        
        // Gets the date and time String from the date object
        let dateTimeString = formatter.string(from: currentDateTime)
        
        //Get reference to firebase
        let db = Firestore.firestore()
        
        //Create a new document for locations
        let newDocument = db.collection("users").document(currentUser!).collection("locations").document()
        
        //Set the new location data
        newDocument.setData(["ID": newDocument.documentID, "location": userAddress.text!, "DateTime": dateTimeString])
        
        let _ = databaseController?.addLocations(id: newDocument.documentID, locationName: userAddress.text!, time: dateTimeString)
        */
        
        //New Code
        let date = Date()
        
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let current_day = date_formatter.string(from: date)
        
        let time_formatter = DateFormatter()
        time_formatter.timeStyle = .short
        let current_time = time_formatter.string(from: date)
        
        let db = Firestore.firestore()
        
        //create new document for locations
        let newDocument = db.collection("users").document(currentUser!).collection("locations").document()
        
        //set the new location data
        newDocument.setData(["ID": newDocument.documentID, "location": userAddress.text!, "postcode": postcode, "date": current_day, "time": current_time, "lattitude": lattitude, "longitude": longitude])
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
