//
//  ProfileController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 15.06.2020.
//

import UIKit
import Firebase

protocol UserUpdateDelegate {
    func updateUser(_ name: String?)
}

class ProfileController: UIViewController {

    var delegate: UserUpdateDelegate?
    var vc: MenuViewController?

    @IBOutlet weak var userName: UITextField!

    @IBAction func userNameChange(_ sender: Any) {
        self.delegate?.updateUser(userName.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vc = self.parent as? MenuViewController
        self.delegate = vc
        
        userName.text = vc?.dbInstance?.user.name
    }
}

