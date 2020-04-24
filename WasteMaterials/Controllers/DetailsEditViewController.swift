//
//  DetailsEditViewController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 02.04.2020.
//

import UIKit

class DetailsEditViewController: UIViewController, UINavigationControllerDelegate {
    public var offer: Offer?
    var delegate: DetailsUpdateDelegate?
    var imagePicker: UIImagePickerController!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var picImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if offer != nil {
            nameTextField.text = offer?.name
            picImageView.image = offer?.image
        } else {
            offer = Offer(name: "", date: String(Int(Date().timeIntervalSince1970 * 1000)))
//            offer?.isNew = true
        }
        
    }

    @IBAction func nameEditAction(_ sender: Any) {
        offer?.name = nameTextField.text!
    }

    @IBAction func saveAction(_ sender: Any) {
        self.delegate?.updateOffer(offer!)
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func photoAction(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        //imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

}

extension DetailsEditViewController:  UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            picImageView.image = image
            offer?.image = image
        }
    }
    
}
