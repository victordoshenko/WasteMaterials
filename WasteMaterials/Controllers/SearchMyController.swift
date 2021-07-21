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
    
    let defaults = UserDefaults.standard

    var dbInstance: DatabaseInstance?
    var reuseIdentifier = "OfferCellMy"
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsMy" {
            if let controller = segue.destination as? DetailsViewController,
               let cell = sender as? UICollectionViewCell,
               let indexPath = self.collectionView?.indexPath(for: cell) {
                    controller.offer = dbInstance?.offersMyQuery[indexPath.row]
                    controller.delegate = self
                }
        }
    }

}

extension SearchMyController {
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
        return (dbInstance?.offersMyQuery.count) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? OfferPhotoCell
        cell?.prepareForView(dbInstance?.offersMyQuery, indexPath.row)
        cell?.favoriteButton.isHidden = true
        return cell ?? OfferPhotoCell()
    }
}

extension SearchMyController: DocumentsEditDelegate {
    func updateOffer(_ offer: Offer) {
        dbInstance?.updateOrNewOffer(offer)
    }
    
    var imageReference: StorageReference {
        return (dbInstance ?? DatabaseInstance()).imageReference
    }
    
    func addOfferToTable(_ offer: Offer) {
        guard (dbInstance?.offersQuery.contains(offer) ?? false) == false else {
            return
        }

        if let user = Auth.auth().currentUser {
            if dbInstance?.offersMyQuery.firstIndex(where: {$0.id == offer.id}) == nil &&
               offer.userId == user.uid {
                dbInstance?.offersMyQuery.insert(offer, at: 0)
            }
        }

        guard (offer.hidden != "1") &&
              (offer.countryid == String(defaults.integer(forKey: "CountryID")) || defaults.integer(forKey: "CountryID") == 0) &&
              (offer.regionid == String(defaults.integer(forKey: "RegionID")) || defaults.integer(forKey: "RegionID") == 0) &&
              (offer.cityid == String(defaults.integer(forKey: "CityID")) || defaults.integer(forKey: "CityID") == 0)
        else {
            return
        }

        dbInstance?.offersQuery.insert(offer, at: 0)
        
    }
    
    func updateOfferInTable(_ offer: Offer) {
        guard let index = dbInstance?.offersQuery.firstIndex(of: offer) else {
            return
        }
        
        dbInstance?.offersQuery[index] = offer

        if let index = dbInstance?.offersMyQuery.firstIndex(where: {$0.id == offer.id}),
           let user = Auth.auth().currentUser,
           offer.userId == user.uid {
            dbInstance?.offersMyQuery[index] = offer
        }

        collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
    
    func removeOfferFromTable(_ offer: Offer) {
        guard let index = dbInstance?.offersQuery.firstIndex(of: offer) else {
            return
        }
        dbInstance?.offersQuery.remove(at: index)
        dbInstance?.deleteOffer(offer)

        if let index = dbInstance?.offersMyQuery.firstIndex(where: {$0.id == offer.id}),
           let user = Auth.auth().currentUser,
           offer.userId == user.uid {
            dbInstance?.offersMyQuery.remove(at: index)
        }

        collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }

}
