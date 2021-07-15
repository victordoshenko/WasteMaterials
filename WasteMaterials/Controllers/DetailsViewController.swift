//
//  DetailsViewController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 30.03.2020.
//

import UIKit
import Firebase

protocol DetailsUpdateDelegate {
    func updateOffer(_ offer: Offer)
}

extension DetailsViewController: DetailsUpdateDelegate {
    func updateOffer(_ offer: Offer) {
        labelName.text = offer.name
        priceLabel.text = offer.price
        picImageView.image = offer.image
        descriptionTextView.text = offer.description
        hiddenSwitch.isOn = offer.hidden == "1"
        self.offer = offer
        self.delegate?.updateOffer(offer)
    }
}

class DetailsViewController: UIViewController {

    let defaults = UserDefaults.standard
    var dbInstance: DatabaseInstance?
    var user: WUser?

    public var offer: Offer?
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var picImageView: UIImageView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hiddenSwitch: UISwitch!
    @IBOutlet weak var hiddenLabel: UILabel!
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var sellerPhone: UILabel!
    @IBOutlet weak var sellerEmail: UILabel!
    @IBOutlet weak var contactsView: UIView!
    
    var delegate: DocumentsEditDelegate?

    @IBAction func showContacts(_ sender: UIButton) {
        contactsView.isHidden = false
        sender.isHidden = true
    }
    
    override func viewDidLoad() {
        guard self.parent != nil else { return }
        super.viewDidLoad()
        labelName.text = offer?.name
        priceLabel.text = offer?.price
        descriptionTextView.text = offer?.description
        hiddenSwitch.isOn = offer?.hidden == "1"
        picImageView.image = offer?.image

        let vc = self.navigationController?.viewControllers[0]
        
        self.dbInstance = (vc as? MenuViewController)?.dbInstance

        self.dbInstance?.getUser(offer?.userId, { (wuser) in
            self.sellerName.text = wuser.name
            self.sellerPhone.text = wuser.phone
            self.sellerEmail.text = wuser.email
        })

        if offer?.userId == Auth.auth().currentUser!.uid {
            self.navigationItem.rightBarButtonItems = [editButton, deleteButton]
        } else {
            self.navigationItem.rightBarButtonItems = nil
            hiddenSwitch.isHidden = true
            hiddenLabel.isHidden = true
        }
        
        if picImageView.image == nil {
            if let url = offer?.imageurl {
                picImageView.sd_setImage(with: URL(string: url)) { (img, err, c, u) in
                    if let err = err {
                        print("There's an error:\(err)")
                    } else {
                        self.picImageView.image = img
                        self.offer?.image = img
                    }
                }
            }
        }
        
        editButton.image = UIImage(named: "square.and.pencil")
        
        if let date = offer?.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss.SSS"
            labelDate.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(Int(date)!) / 1000 ))
        } else {
            labelDate.text = ""
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsEdit" {
            let controller = segue.destination as! DetailsEditViewController
            controller.offer = self.offer
            controller.delegate = self
        }
    }

    @IBAction func deleteAction(_ sender: Any) {
        let ac = UIAlertController(title: nil, message: "Are you sure you want to delete offer?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.delegate?.removeOfferFromTable(self.offer!)
            _ = self.navigationController?.popViewController(animated: true)
        }))
        present(ac, animated: true, completion: nil)
    }

}
