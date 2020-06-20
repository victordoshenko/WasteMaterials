//
//  MenuViewController.swift
//  SimpleSideMenu
//
//  Created by Victor Doshchenko on 20.04.2020.
//  Copyright © 2020 Victor Doshchenko. All rights reserved.
//

import UIKit
import SideMenu

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
