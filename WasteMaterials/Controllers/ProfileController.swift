//
//  ProfileController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 15.06.2020.
//

import UIKit
import Firebase

protocol UserUpdateDelegate {
    func updateUser(_ user: WUser?)
}

class ProfileController: UIViewController {

    let defaults = UserDefaults.standard
    var dbInstance: DatabaseInstance?

    private var userListener: ListenerRegistration?
    var delegate: UserUpdateDelegate?
    var user: WUser?

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var selectCountryButton: UIButton!
    @IBOutlet weak var selectRegionButton: UIButton!
    
    @IBAction func userNameChange(_ sender: Any) {
        self.user?.name = userName.text
        self.delegate?.updateUser(user)
    }
    @IBAction func emailChange(_ sender: Any) {
        self.user?.email = email.text
        self.delegate?.updateUser(user)
    }
    @IBAction func phoneChange(_ sender: Any) {
        self.user?.phone = phone.text
        self.delegate?.updateUser(user)
    }

    @IBAction func clearCountry(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "CountryID")
        defaults.removeObject(forKey: "CountryName")
        defaults.removeObject(forKey: "CountryCode")
        defaults.removeObject(forKey: "CountryFullName")
        selectCountryButton.setTitle("Select Country", for: .normal)
        clearRegionData()
        showCountry()
    }

    @IBAction func clearRegion(_ sender: Any) {
        clearRegionData()
        showRegion()
    }
    
    func clearRegionData() {
        defaults.removeObject(forKey: "RegionID")
        defaults.removeObject(forKey: "CityID")
        defaults.removeObject(forKey: "RegionCityName")
        defaults.removeObject(forKey: "RegionName")
        selectRegionButton.setTitle("Select Region / City", for: .normal)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectCountryButton.setRoundedCorners()
        selectRegionButton.setRoundedCorners()
        
        let vc = self.navigationController?.viewControllers[0]
        self.delegate = vc as? UserUpdateDelegate
        self.dbInstance = (vc as? MenuViewController)?.dbInstance

        userListener = dbInstance?.userReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleUserChange(change)
            }
        }
        
        (vc as? MenuViewController)?.defineCountry {
            self.showCountry()
        }
    }

    private func handleUserChange(_ change: DocumentChange) {
        guard let user = WUser(document: change.document),
            user.id == Auth.auth().currentUser!.uid
            else { return }
        
        self.user = user
        self.userName.text = user.name
        self.email.text = user.email
        self.phone.text = user.phone
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showCountry()
    }

    func showRegion() {
        let rcn = defaults.string(forKey: "RegionCityName")
        if rcn != "" && rcn != nil {
            selectRegionButton.setTitle(rcn, for: .normal)
        }
    }
    
    func showCountry() {
        let cfn = defaults.string(forKey: "CountryFullName")
        if cfn != "" && cfn != nil {
            if cfn != selectCountryButton.titleLabel?.text && selectCountryButton.titleLabel?.text != "Select Country" {
                clearRegionData()
            }
            selectCountryButton.setTitle(cfn, for: .normal)
            selectRegionButton.isEnabled = true
        } else {
            selectRegionButton.isEnabled = false
        }
        showRegion()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseRegion" {
            let controller = segue.destination as! GeoController
            controller.countryID = defaults.integer(forKey: "CountryID")
        }
        if segue.identifier == "chooseCountry" {
            let controller = segue.destination as! GeoController
            controller.countryID = 0
        }

    }
    
}
