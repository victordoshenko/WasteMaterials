//
//  DetailsEditViewController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 02.04.2020.
//

import UIKit

class DetailsEditViewController: UIViewController {
    public var offer: Offer?
    var delegate: DocumentsEditDelegate?
    var delegateDetails: DetailsUpdateDelegate?
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = offer?.name
    }

    @IBAction func nameEditAction(_ sender: Any) {
        offer?.name = nameTextField.text!
    }

    @IBAction func saveAction(_ sender: Any) {
        self.delegate?.updateOffer(offer!)
        self.delegateDetails?.setName(offer!.name)
        _ = self.navigationController?.popViewController(animated: true)
    }

}
