//
//  DetailsViewController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 30.03.2020.
//

import UIKit

protocol DetailsUpdateDelegate {
    func updateOffer(_ offer: Offer)
}

extension DetailsViewController: DetailsUpdateDelegate {
    func updateOffer(_ offer: Offer) {
        labelName.text = offer.name
        picImageView.image = offer.image
        self.offer = offer
        self.delegate?.updateOffer(offer)
    }
}

class DetailsViewController: UIViewController {

    public var offer: Offer?
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var picImageView: UIImageView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var delegate: DocumentsEditDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        labelName.text = offer?.name
        labelID.text = offer?.id
        picImageView.image = offer?.image
        
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
