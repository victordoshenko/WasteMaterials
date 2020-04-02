//
//  DetailsViewController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 30.03.2020.
//

import UIKit

protocol DetailsUpdateDelegate {
    func setName(_ name: String)
}

extension DetailsViewController: DetailsUpdateDelegate {
    func setName(_ name: String) {
        labelName.text = name
    }
}

class DetailsViewController: UIViewController {

    public var offer: Offer?
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    var delegate: DocumentsEditDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        labelName.text = offer?.name
        labelID.text = offer?.id
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
            controller.delegate = self.delegate
            controller.delegateDetails = self
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
