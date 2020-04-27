//
//  SearchFavoritesController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 25.04.2020.
//

import Foundation
import UIKit
import Firebase

class SearchFavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var dbInstance: DatabaseInstance?
    var reuseIdentifier = "OfferCellFavorites"

    var offerFavoritesQuery: Query {
        return dbInstance!.favoritesReference as Query
    }

    @IBAction func test(_ sender: Any) {
        print("Count: \((self.dbInstance?.offersQuery.count)!)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad: " + self.description)

        let vc = self.parent as! MenuViewController
        self.dbInstance = vc.dbInstance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.reloadData()
    }

}

extension SearchFavoritesController: FavoritesDelegate {
    func changeFavoriteStatus(_ id: String, _ completion: @escaping (Bool) -> Void) {
        dbInstance?.changeFavoriteStatus(id) { isFavorite in
            completion(isFavorite)
        }
    }
}

extension SearchFavoritesController {

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return (dbInstance?.offersFavoritesQuery.count)!
  }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! OfferPhotoCell
        cell.delegate = self
        //let flickrPhoto = photo(for: indexPath)
        cell.backgroundColor = .white
        //cell.imageView.image = flickrPhoto.thumbnail
        
        cell.layer.cornerRadius = 2
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        
        cell.goodsNameLabel.text = dbInstance?.offersFavoritesQuery[indexPath.row].name
        cell.id = dbInstance?.offersFavoritesQuery[indexPath.row].id
        cell.setHeart(true)
        
        cell.imageView.image = nil
        cell.goodsNameLabel.textColor = .systemBlue
        cell.favoriteButton.setTitleColor(.systemBlue, for: .normal)
        
        if let url = dbInstance?.offersFavoritesQuery[indexPath.row].imageurl {
            cell.imageView.sd_setImage(with: URL(string: url)) { (img, err, c, u) in
                if let err = err {
                    print("There's an error:\(err.localizedDescription)")
                } else {
                    cell.imageView.image = img
                    //self.dbInstance?.offersQuery[indexPath.row].image = img
                    cell.goodsNameLabel.textColor = .white
                    cell.favoriteButton.setTitleColor(.white, for: .normal)
                }
            }
        }
        return cell
    }
}
