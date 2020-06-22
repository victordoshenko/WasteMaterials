//
//  ProfileController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 15.06.2020.
//

import UIKit
import Firebase
import Alamofire

protocol UserUpdateDelegate {
    func updateUser(_ user: WUser?)
}

class ProfileController: UIViewController {

    let defaults = UserDefaults.standard
    let apiPath = "https://mcrain.pythonanywhere.com/api"

    var delegate: UserUpdateDelegate?
    var vc: MenuViewController?
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
        selectRegionButton.setTitle("Select Region / City", for: .normal)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectCountryButton.setRoundedCorners()
        selectRegionButton.setRoundedCorners()
        
        vc = self.parent as? MenuViewController
        self.delegate = vc
        
        self.user = vc?.dbInstance?.user
        
        userName.text = self.user?.name
        email.text = self.user?.email
        phone.text = self.user?.phone
        
        defineCountry()
    }
    
    func defineCountry() {
        guard defaults.integer(forKey: "CountryID") == 0 else { return }
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
                        self.showCountry()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
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
            selectCountryButton.setTitle(cfn, for: .normal)
            selectRegionButton.isEnabled = true
        } else {
            selectRegionButton.isEnabled = false
        }
        showRegion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showCountry()
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
