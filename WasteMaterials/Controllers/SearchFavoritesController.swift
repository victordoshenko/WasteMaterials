//
//  SearchFavoritesController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 25.04.2020.
//

import Foundation
import UIKit
import Firebase

class SearchFavoritesController: SearchViewController {

    @IBAction func test(_ sender: Any) {
        print("Count: \((self.dbInstance?.offersQuery.count)!)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dbInstance?.isFavoriteList = true
        self.reuseIdentifier = "OfferCellFavorites"
        navigationController?.isToolbarHidden = false
        print("viewDidLoad: " + self.description)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear: " + self.description)
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        self.collectionView.addSubview(activityIndicator)
        activityIndicator.frame = self.collectionView.bounds
        activityIndicator.startAnimating()
        
        dbInstance?.readAllFavoritesFromDB {
            self.collectionView?.reloadData()
            activityIndicator.removeFromSuperview()
            print("Count: \((self.dbInstance?.offersQuery.count)!)")
        }
    }

}

extension SearchFavoritesController {

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return (dbInstance?.offersQuery.count)!
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
        
        cell.goodsNameLabel.text = dbInstance?.offersQuery[indexPath.row].name
        cell.id = dbInstance?.offersQuery[indexPath.row].id
        
        let _ = dbInstance?.checkIsFavorite(cell.id!) { isFavorite in
            cell.setHeart(isFavorite)
        }

        cell.imageView.image = nil
        cell.goodsNameLabel.textColor = .systemBlue
        cell.favoriteButton.setTitleColor(.systemBlue, for: .normal)
        
        if let url = dbInstance?.offersQuery[indexPath.row].imageurl {
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
