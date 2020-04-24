//
//  NavigationController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 12.03.2020.
//

import UIKit

class OfferPhotoCell: UICollectionViewCell {
    var id: String?
    var delegate: FavoritesDelegate?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var goodsNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func favoriteButtonAction(_ sender: UIButton) {
        delegate?.updateFavorite(id, sender.titleLabel?.text == "♡")
        setHeart()
        
        if sender.titleLabel?.text != "♡" {
            sender.setTitle("♡", for: .normal)
        } else {
            sender.setTitle("♥︎", for: .normal)
        }
    }
    
    func setHeart(_ isFavorite: Bool) {
        sender.setTitle(isFavorite ? "♥︎" : "♡", for: .normal)
    }
}
