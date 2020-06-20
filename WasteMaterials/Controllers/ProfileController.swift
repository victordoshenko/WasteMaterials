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

    var delegate: UserUpdateDelegate?
    var vc: MenuViewController?
    var user: WUser?

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
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
    
    @IBAction func selectRegionAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SelectRegion") as! GeoController
        show(vc, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectRegionButton.borderWidth = 0.5
        selectRegionButton.borderColor = .gray
        selectRegionButton.cornerRadius = 5
        
        vc = self.parent as? MenuViewController
        self.delegate = vc
        
        self.user = vc?.dbInstance?.user
        
        userName.text = self.user?.name
        email.text = self.user?.email
        phone.text = self.user?.phone
                
    }
}
