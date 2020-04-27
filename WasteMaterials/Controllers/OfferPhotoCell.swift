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
        //setHeart(sender.titleLabel?.text != "♥︎")
        delegate?.changeFavoriteStatus(id!) { isFavorite in
            self.setHeart(isFavorite)
        }
    }

    func setHeart(_ isFavorite: Bool) {
        favoriteButton.setTitle(isFavorite ? "♥︎" : "♡", for: .normal)
        print("Set favorite = \(isFavorite) !  \(self.description)")
    }
}
