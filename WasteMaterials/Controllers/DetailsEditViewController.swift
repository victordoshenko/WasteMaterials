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
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var hiddenSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.delegate = self
        descriptionTextView.layer.borderWidth = 1.0;
        descriptionTextView.layer.cornerRadius = 5.0;
        descriptionTextView.text = ""

        if offer != nil {
            nameTextField.text = offer?.name
            picImageView.image = offer?.image
            priceTextField.text = offer?.price
            descriptionTextView.text = offer?.description
            if descriptionTextView.text == "" || descriptionTextView.text == "Description" {
                descriptionTextView.text = "Description"
            }
            hiddenSwitch.isOn = offer?.hidden == "1"
        } else {
            offer = Offer(name: "", date: String(Int(Date().timeIntervalSince1970 * 1000)))
        }
    }

    @IBAction func priceEditAction(_ sender: Any) {
        offer?.price = priceTextField.text ?? ""
    }
    
    @IBAction func nameEditAction(_ sender: Any) {
        offer?.name = nameTextField.text ?? ""
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let offer = offer {
            self.delegate?.updateOffer(offer)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func hiddenAction(_ sender: Any) {
        offer?.hidden = hiddenSwitch.isOn ? "1" : "0"
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

extension DetailsEditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Description" && textView.textColor == .lightGray)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
    }

    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Description"
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" || textView.text == "Description" {
            offer?.description = nil
        } else {
            offer?.description = textView.text
        }
    }
}
