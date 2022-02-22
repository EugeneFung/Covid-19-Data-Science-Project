//
//  SignInViewController.swift
//  Not another Covid App
//
//  Created by adam luqman on 03/10/2021.
//

import UIKit
import FirebaseAuth
import Firebase
import CoreLocation

class SignInViewController: UIViewController, DatabaseListener {

    @IBOutlet weak var enterBtn: UIButton!

    func onLocationChange(change: DatabaseChange, locations: [Locations]) {
        journalLocations = locations
    }

    let REQUEST_STRING = "https://script.googleusercontent.com/macros/echo?user_content_key=PhTmYv5my8m2R7pMktxIwmHTVRrUyO6fts1HLhUbO4HhUgKqI8eJQmxUm9Fw1dtZvrFXOxQ5uzsKVFmbQJCXpXK_N3bMQumMOJmA1Yb3SEsKFZqtv3DaNYcMrmhZHmUMWojr9NvTBuBLhyHCd5hHa1GhPSVukpSQTydEwAEXFXgt_wltjJcH3XHUaaPC1fv5o9XyvOto09QuWI89K6KjOu0SP2F-BdwUGJi-JZxRIG_g6jhV0fgOJRjfYkfaVy7AmOdnk0ghk2dk1iMi49vjBT5dtDQyTqxM5y7FLqOV0Tk27B8Rh4QJTQ&lib=MnrE7b2I2PjfH799VodkCPiQjIVyBAxva"
    var rawExposureSitesList = [ExposureSiteData]()    //raw exposure site array
    var exposureSitesList = [ExposureSiteData]()        //exposure site array without nulls in lat/long
    
    var listenerType: ListenerType = .Locations
    weak var databaseController: DatabaseProtocol?
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var usersRef = Firestore.firestore().collection("users")
    var locationsRef: CollectionReference?
    var snapShotListener: ListenerRegistration?
    var userID = Auth.auth().currentUser?.uid
    
    var journalLocations = [Locations]()
    
    var matchExposedSitesList: [(ExposureSiteData, Locations)] = []
    
    var ready: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterBtn.layer.cornerRadius = 15.0
        // Do any additional setup after loading the view.
        
        //Sign in anonymously if not already signed in
        let auth = Auth.auth()
        
        if (auth.currentUser == nil) {
            
            auth.signInAnonymously{ (result, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                print("User has signed in.")
                let currentUserUid = auth.currentUser?.uid
                let db = Firestore.firestore()
                
                db.collection("users").document(result!.user.uid).setData(["uid": result!.user.uid])
            }
            
        } else {
            print("User already signed in.")
            print(auth.currentUser?.uid)
            
            //test sign out
            /*
            do {
                //Sign out user
                try auth.signOut()
                print("User has sign out")
            } catch {
                print("Log out error: \(error.localizedDescription)")
            }
            */
        }
        //enterBtn.isHidden = true
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        if userID != nil{
            locationsRef = usersRef.document(userID!).collection("locations")

        }
//        locationsRef = usersRef.document(userID!).collection("locations")
        
        // Do any additional setup after loading the view.
        
        //get matching exposure sites
        requestSite()
        
    }
    
    
    //Get data of user's journal from firebase
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
            self.journalLocations.removeAll()
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
                
                self.journalLocations.append(newLocation)
            }
        }
    }
    
    func requestSite() {
        guard let requestURL = URL(string: REQUEST_STRING) else {
            print("Invalid URL.")
            return
        }
        let task = URLSession.shared.dataTask(with: requestURL) { [self]
            (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let exposureResultData = try decoder.decode(ExposureResultData.self, from: data!)
                if let exposureSites = exposureResultData.exposureSite {
                    self.rawExposureSitesList.append(contentsOf: exposureSites)
                    
                    //access exposureSiteList here
//                    print(self.rawExposureSitesList.count)
                    for i in self.rawExposureSitesList{
                        if(i.longitude != nil){
                            self.exposureSitesList.append(i)
                            
                            
                        }
                    }
                    
                    
                    //binary search to match exposure sites with user's journal
                    self.matchExposedSitesList = self.binarySearch(exposureList: self.exposureSitesList, journalList: self.journalLocations)
                    print("ready")
                    ready = true
                    
                    
                }
            } catch let err {
                print(err)
            }
        }
        
        task.resume()
    }
    
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
    
    func binarySearch(exposureList: [ExposureSiteData], journalList: [Locations]) -> [(ExposureSiteData, Locations)] {
        //Complexity: O(k(logn + occurences))
        //k = journalList
        //n = exposureList
        //occurences = duplicates
        
        var resList: [(ExposureSiteData, Locations)] = []
        
        for i in journalList {
            
            //get start index of duplicates
            var start = 0
            var end = exposureList.count - 1
            var startIndex = -1
            while start <= end {
                let middle = (end - start) / 2 + start
                let midPoint = exposureList[middle]
                
                if (midPoint.sitePostcode! > Int(i.postcode!)!) {
                    end = middle - 1
                } else if (midPoint.sitePostcode! == Int(i.postcode!)! ) {
                    startIndex = middle
                    end = middle - 1
                } else {
                    start = middle + 1
                }
            }
            print(startIndex)
            // get end index of duplicates
            var low = 0
            var high = exposureList.count - 1
            var endIndex = -1
            while low <= high {
                let middle = (high - low) / 2 + low
                let midPoint = exposureList[middle]
                
                if (midPoint.sitePostcode! > Int(i.postcode!)!) {
                    high = middle - 1
                } else if (midPoint.sitePostcode! == Int(i.postcode!)! ){
                    endIndex = middle
                    low = middle + 1
                } else {
                    low = middle + 1
                }
            }
            print(endIndex)
            if (startIndex != -1 && endIndex != -1) {
                for j in startIndex...endIndex{
                    //comparing date, time and distance
                    
                    //get exposre date, time and lat and long
                    let exposureDate = exposureList[j].exposureDate
                    print("wefrf",exposureDate)
                    let newExposureDate = self.getDate(date: exposureDate)
                    let exposureDateISO = self.getISO(date: newExposureDate) as! String
                    let exposureTime = self.getTime(date: exposureList[j].exposureTimeStart) as! String
                    let exposureLat = exposureList[j].latitude
                    let exposureLong = exposureList[j].longitude
                    print(exposureList[j].siteTitle)
                    
                    //format exposure time
                    let newExposureTime = self.getTime(date: exposureTime) as! String
                    //print(newExposureTime)
                    let newExposureTimeISO = self.getISOTime(date: newExposureTime)
                    //print(newExposureTimeISO)
                    
                    //get journal date, time and lat and long
                    let journalDate = self.getISO(date: self.getDate(date: i.date!)) as! String
                    let journalTime = i.time
                    let journalLat = i.lattitude
                    let journalLong = i.longitude
                    
                    //format journal time
                    let newTimeISO = self.getISOTime(date: journalTime!)
                    
                    //calculate distance between exposure site and journal location using lattitude and longitude.
                    let exposureCoordinate = CLLocation(latitude: exposureLat!, longitude: exposureLong!)
                    let journalCoordinate = CLLocation(latitude: journalLat!, longitude: journalLong!)
                    
                    let distanceInMeters = exposureCoordinate.distance(from: journalCoordinate)
                    print(exposureDateISO, journalDate)
                    print(distanceInMeters)
                    if (exposureDateISO == journalDate && distanceInMeters <= 100) {
                        print("io")
                        resList.append((exposureList[j], i))
                        
                    }
                }
            }
        }
        return resList
    }
    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let barViewControllers = segue.destination as! UITabBarController
        let destinationVC = barViewControllers.viewControllers![0] as! UINavigationController
        let vc = destinationVC.topViewController as! HomeViewController
        vc.matchExposedSitesList = self.matchExposedSitesList
        vc.exposureSitesList = self.exposureSitesList
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "tabBarSegue" {
            
            if ready == false {
                print("Not Ready")
                //toast
                self.showToast(message: "Loading...Please wait")
                return false
            } else {
                print("ready")
                return true
            }
        }
        return false
    }
    

}
