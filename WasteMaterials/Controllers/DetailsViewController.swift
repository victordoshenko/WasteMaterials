//
//  DetailsViewController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 30.03.2020.
//

import UIKit

class DetailsViewController: UIViewController {

    public var offer: Offer?
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelID: UILabel!
    var delegate: DocumentsEdit?
    override func viewDidLoad() {
        super.viewDidLoad()
        labelName.text = offer?.name
        labelID.text = offer?.id
        // Do any additional setup after loading the view.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
