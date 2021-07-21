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
        return (dbInstance ?? DatabaseInstance()).favoritesReference as Query
    }

    private let sectionInsets = UIEdgeInsets(top: 20.0,
                                             left: 20.0,
                                             bottom: 20.0,
                                             right: 20.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad: " + self.description)

        let vc = self.navigationController?.viewControllers[0]
        self.dbInstance = (vc as? MenuViewController)?.dbInstance
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
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (dbInstance?.offersFavoritesQuery.count) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? OfferPhotoCell
        cell?.delegate = self
        cell?.prepareForView(dbInstance?.offersFavoritesQuery, indexPath.row)
        cell?.setHeart(true)
        return cell ?? OfferPhotoCell()
    }
}
