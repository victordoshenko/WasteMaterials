//
//  GeoController.swift
//  19/06/2020
//  Copyright © 2020 Victor Doshenko. All rights reserved.
//

import UIKit
import Alamofire

class GeoController: UITableViewController {
    
    let defaults = UserDefaults.standard
    var geoitems: GeoItems = []
    var countryID = 0

    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        if countryID > 0 {
            searchController.searchBar.text = defaults.string(forKey: "RegionName")
        }
        loadData(countryID, searchController.searchBar.text ?? "")
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return geoitems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let geoitem = geoitems[indexPath.row]
        if countryID == 0 {
            cell.textLabel?.text = getFlag(from: geoitem.ccod ?? "") + " " + (geoitem.cnam ?? "")
            cell.detailTextLabel?.text = "\(geoitem.ccod ?? "")"
        } else {
            cell.textLabel?.text = geoitem.nam
            cell.detailTextLabel?.text = geoitem.rnam
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let geoitem = geoitems[indexPath.row]
        let defaults = UserDefaults.standard
        if countryID == 0 {
            defaults.set(geoitem.cid, forKey: "CountryID")
            defaults.set(geoitem.cnam, forKey: "CountryName")
            defaults.set(geoitem.ccod, forKey: "CountryCode")
            defaults.set(getFlag(from: geoitem.ccod ?? "") + " " + (geoitem.cnam ?? ""), forKey: "CountryFullName")
        } else {
            defaults.set(geoitem.rid , forKey: "RegionID")
            defaults.set(geoitem.cyid , forKey: "CityID")
            defaults.set(geoitem.nam ?? "" , forKey: "RegionName")
            defaults.set(geoitem.nam ?? "" + (geoitem.rnam ?? "" == "" ? "" : " (\(geoitem.rnam ?? ""))"), forKey: "RegionCityName")
        }

        self.navigationController?.popViewController(animated: true)
    }

    func loadData(_ countryid: Int, _ string: String) {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        self.view.addSubview(activityIndicator)
        activityIndicator.frame = UIScreen.main.bounds
        activityIndicator.startAnimating()
        
        AF.request(apiPath, headers: ["name":string, "countryid":String(countryid)]).responseJSON {
            response in
            if let data = response.data {
                do {
                    self.geoitems = try JSONDecoder().decode(GeoItems.self, from: data)
                    self.tableView.reloadData()
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            activityIndicator.removeFromSuperview()
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension GeoController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if (searchController.searchBar.text ?? "").count > 2 {
            filterContentForSearchText(searchController.searchBar.text ?? "")
        }
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        loadData(countryID, searchText)
    }
}
