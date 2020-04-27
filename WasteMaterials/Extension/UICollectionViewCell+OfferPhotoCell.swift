//
//  UICollectionViewCell+OfferPhotoCell.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 27.04.2020.
//

import UIKit

extension UICollectionViewCell {
    func setNiceLook() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 2
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }
}

extension OfferPhotoCell {
    func prepareForView(_ arr: [Offer]?, _ index: Int) {
        self.setNiceLook()
        self.goodsNameLabel.text = arr?[index].name
        self.id = arr?[index].id

        self.imageView.image = nil
        self.goodsNameLabel.textColor = .systemBlue
        self.favoriteButton.setTitleColor(.systemBlue, for: .normal)
        
        if let url = arr?[index].imageurl {
            self.imageView.sd_setImage(with: URL(string: url)) { (img, err, c, u) in
                if let err = err {
                    print("There's an error:\(err.localizedDescription)")
                } else {
                    self.imageView.image = img
                    self.goodsNameLabel.textColor = .white
                    self.favoriteButton.setTitleColor(.white, for: .normal)
                }
            }
        }

    }
}
