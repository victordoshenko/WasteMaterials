//
//  MenuViewController.swift
//  SimpleSideMenu
//
//  Created by Victor Doshchenko on 20.04.2020.
//  Copyright © 2020 Victor Doshchenko. All rights reserved.
//

import UIKit
import SideMenu
import Alamofire

let apiPath = "https://mcrain.pythonanywhere.com/api"

extension MenuViewController: DetailsUpdateDelegate {
    func updateOffer(_ offer: Offer) {
        dbInstance?.updateOrNewOffer(offer)
    }
}

extension MenuViewController: UserUpdateDelegate {
    func updateUser(_ user: WUser?) {
        dbInstance?.updateUser(user)
    }
}

class MenuViewController: UITabBarController {

    let defaults = UserDefaults.standard

    var dbInstance: DatabaseInstance?

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbInstance = DatabaseInstance()
        hideSearch()

        self.navigationController?.navigationBar.isTranslucent = false
        let Menu = storyboard?.instantiateViewController(withIdentifier: "SideMenuNavigation") as? SideMenuNavigationController
        Menu?.leftSide = true
        Menu?.settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController = Menu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)

    }

    func defineCountry(_ completion: @escaping () -> Void) {
        guard defaults.integer(forKey: "CountryID") == 0 else { completion(); return }
        AF.request(apiPath).responseJSON {
            response in
            if let data = response.data {
                do {
                    let regionCode = Locale.current.regionCode
                    let geoitems = try JSONDecoder().decode(GeoItems.self, from: data)
                    if let index = geoitems.firstIndex(where: { $0.ccod == regionCode?.lowercased()}) {
                        self.defaults.set(geoitems[index].cid, forKey: "CountryID")
                        self.defaults.set(geoitems[index].cnam, forKey: "CountryName")
                        self.defaults.set(geoitems[index].ccod, forKey: "CountryCode")
                        self.defaults.set(getFlag(from: geoitems[index].ccod ?? "") + " " + geoitems[index].cnam!, forKey: "CountryFullName")
                        completion()
                        let ac = UIAlertController(title: nil, message: "Your country defined automatically as \(geoitems[index].cnam ?? "").", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .default , handler: nil))
                        self.present(ac, animated: true, completion: nil)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsNew" {
            let controller = segue.destination as! DetailsEditViewController
            controller.delegate = self
        }

        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.leftSide = true
        sideMenuNavigationController.settings = makeSettings()
    }
    
    private func makeSettings() -> SideMenuSettings {
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        presentationStyle.backgroundColor = .gray
        presentationStyle.presentingEndAlpha = 0.5
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        return settings
    }
    
    public func hideSearch() {
        searchTextField.isHidden = true
        addButton.isEnabled = false
        addButton.tintColor = .clear
    }

    public func showSearch() {
        searchTextField.isHidden = false
        addButton.isEnabled = true
        addButton.tintColor = UIButton(type: .system).tintColor
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == (self.tabBar.items!)[0] {
            showSearch()
        } else {
            hideSearch()
        }
    }

}
