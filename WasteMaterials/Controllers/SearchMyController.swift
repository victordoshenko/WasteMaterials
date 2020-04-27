//
//  SearchMyController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 27.04.2020.
//

import Foundation
import UIKit
import Firebase

class SearchMyController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var dbInstance: DatabaseInstance?
    var reuseIdentifier = "OfferCellMy"

    var offerMyQuery: Query {
        return (dbInstance?.offerReference.whereField("userId", isEqualTo: Auth.auth().currentUser!.uid))!
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

extension SearchMyController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (dbInstance?.offersMyQuery.count)!
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OfferPhotoCell
        cell.prepareForView(dbInstance?.offersMyQuery, indexPath.row)
        cell.favoriteButton.isHidden = true
        return cell
    }
}
