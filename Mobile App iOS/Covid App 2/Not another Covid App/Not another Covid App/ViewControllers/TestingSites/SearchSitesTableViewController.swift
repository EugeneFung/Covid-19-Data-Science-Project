//
//  SearchSitesTableViewController.swift
//  Not another Covid App
//
//  Created by Eugene Fung on 24/8/21.
//

import UIKit

class SearchSitesTableViewController: UITableViewController, UISearchBarDelegate{
    
    let CELL_SITE = "siteCell"
    let REQUEST_STRING = "https://discover.data.vic.gov.au/api/3/action/datastore_search?resource_id=638931c5-605d-442a-80f9-e1e1ee70ad26&q="
    var newSites = [TestingSiteData]()  //array to display sites
    var indicator = UIActivityIndicatorView()   //for loading indicator

    override func viewDidLoad() {
        
//        search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search suburb, walk in, wheelchair..."
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        super.viewDidLoad()

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
        return newSites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SITE, for: indexPath) as! TestingSitesTableViewCell

        // Configure the cell here...
        let site = newSites[indexPath.row]
        cell.siteNameLabel?.text = site.siteName
        cell.addressLabel?.text = site.address + ", " + site.suburb + " " + site.state + " " + site.postcode
        
        if (site.ageLimit == "All ages"){
            cell.ageLimitLabel.text = "All Ages"
            cell.ageLimitLabel.textColor = UIColor(red: 44.0/255, green: 71.0/255, blue: 118.0/255, alpha: 1.0)
            cell.ageLimitLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        } else{
            cell.ageLimitLabel.text = "All Ages"
            cell.ageLimitLabel.textColor = UIColor.lightGray
            cell.ageLimitLabel.font = UIFont.systemFont(ofSize: 13.0)
        }
        
        if (site.serviceFormat == "Walk-in"){
            cell.serviceFormatLabel.text = "Walk-in"
            cell.serviceFormatLabel.textColor = UIColor(red: 44.0/255, green: 71.0/255, blue: 118.0/255, alpha: 1.0)
            cell.serviceFormatLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        } else{
            cell.serviceFormatLabel.text = "Drive-Through"
            cell.serviceFormatLabel.textColor = UIColor(red: 44.0/255, green: 71.0/255, blue: 118.0/255, alpha: 1.0)
            cell.serviceFormatLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        }
        
        if (site.requirements == "Appointment required."){
            cell.appointmentLabel.text = "Appointment"
            cell.appointmentLabel.textColor = UIColor(red: 44.0/255, green: 71.0/255, blue: 118.0/255, alpha: 1.0)
            cell.appointmentLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        } else{
            cell.appointmentLabel.text = "Appointment"
            cell.appointmentLabel.textColor = UIColor.lightGray
            cell.appointmentLabel.font = UIFont.systemFont(ofSize: 13.0)
        }
        
        if (site.siteFacilities == nil ){
            cell.wheelchairLabel.text = "Wheelchair Access"
            cell.wheelchairLabel.textColor = UIColor.lightGray
            cell.wheelchairLabel.font = UIFont.systemFont(ofSize: 13.0)
        } else{
            cell.wheelchairLabel.text = "Wheelchair Access"
            cell.wheelchairLabel.textColor = UIColor(red: 44.0/255, green: 71.0/255, blue: 118.0/255, alpha: 1.0)
            cell.wheelchairLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        }
        

        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SiteViewController
        
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell){
            let siteData = newSites[indexPath.row]
            destination.site = siteData
        }
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
    
    //    This is the method where we will call the API to request site information.
    func requestSite(_ query: String) {
        
        guard let queryString = query.addingPercentEncoding(withAllowedCharacters:
                                                                .urlQueryAllowed) else {
            print("Query string can't be encoded.")
            return
        }
        guard let requestURL = URL(string: REQUEST_STRING + queryString) else {
            print("Invalid URL.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: requestURL) {
            (data, response, error) in
            // This closure is executed on a different thread at a later point in
            // time!
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            if let error = error {
                print(error)
                return
            }
            do {
                let decoder = JSONDecoder()
                let siteResultData = try decoder.decode(SiteResultData.self, from: data!)
                if let sites = siteResultData.result?.testingSite {
//                let siteRecordData = try decoder.decode(SiteRecordData.self, from: data!)
//                if let sites = siteRecordData.testingSite {
                    self.newSites.append(contentsOf: sites)
//                    print(self.newSites.count)
//                    print(self.newSites)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch let err {
                print(err)
            }
        }
        task.resume()
        
    }
    
    //    This is called if the user hits enter or taps the search button after typing in the search field. It is also called when the user taps cancel.
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        newSites.removeAll()
        tableView.reloadData()
        guard let searchText = searchBar.text?.lowercased() else {
            return
        }
        indicator.startAnimating()
        requestSite(searchText)
    }

}
