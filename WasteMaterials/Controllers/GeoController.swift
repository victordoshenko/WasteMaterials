//
//  GeoController.swift
//  19/06/2020
//  Copyright © 2020 Victor Doshenko. All rights reserved.
//

import UIKit
import Alamofire

class GeoController: UITableViewController {
    
    var geoitems: GeoItems = []

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
        loadData()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return geoitems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let geoitem = geoitems[indexPath.row]
        cell.textLabel?.text = geoitem.cnam   //.nam
        cell.detailTextLabel?.text = "\(geoitem.cid ?? 0)" //.rnam

        return cell
    }

    func loadData() {
        AF.request("https://mcrain.pythonanywhere.com/api").responseJSON {
            response in
            if let data = response.data {
                do {
                    self.geoitems = try JSONDecoder().decode(GeoItems.self, from: data)
                    self.tableView.reloadData()
                    print(self.geoitems)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension GeoController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        print("Reload!")
        loadData()
    }
}

