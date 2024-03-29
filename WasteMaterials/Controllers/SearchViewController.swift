//
//  SearchViewController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 20.03.2020.
//

import UIKit
import FirebaseUI
import Firebase
import SDWebImage

class SearchViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let defaults = UserDefaults.standard

    var dbInstance: DatabaseInstance?
    var reuseIdentifier = "OfferCell"
    var refreshed = false

    private var searchTextField = UITextField()
    private var searchButton = UIBarButtonItem()

    private let sectionInsets = UIEdgeInsets(top: 20.0,
                                             left: 20.0,
                                             bottom: 20.0,
                                             right: 20.0)
    private var currentOfferAlertController: UIAlertController?
    private var offerListener: ListenerRegistration?
    private var favoriteListener: ListenerRegistration?

    private var itemsPerRow: CGFloat = 2
    
    deinit {
        offerListener?.remove()
        favoriteListener?.remove()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("***** viewWillTransition Landscape")
            itemsPerRow = 3
        } else {
            print("***** viewWillTransition Portrait")
            itemsPerRow = 2
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let controller = segue.destination as? DetailsViewController
            if let cell = sender as? UICollectionViewCell, let indexPath = self.collectionView?.indexPath(for: cell) {
                controller?.offer = dbInstance?.offersQuery[indexPath.row]
                controller?.delegate = self
            }
        }
    }

    @objc func searchButtonClick(_ sender: UIButton) {
        refreshTable(searchTextField.text?.lowercased() ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !refreshed {
            refreshed = true
        } else {
            self.refreshTable(self.searchTextField.text?.lowercased() ?? "")
        }
    }
    
    override func viewDidLoad() {
        guard self.parent != nil else { return }
        super.viewDidLoad()

        if UIDevice.current.orientation.isLandscape {
            itemsPerRow = 3
        } else {
            itemsPerRow = 2
        }
        
        if let vc = self.parent as? MenuViewController {
            vc.showSearch()
            self.searchTextField = vc.searchTextField
            self.searchTextField.delegate = self
            self.dbInstance = vc.dbInstance
            self.searchButton = vc.searchButton
            self.searchButton.target = self
            self.searchButton.action = #selector(searchButtonClick)
            vc.defineCountry{
                self.refreshTable()
            }
        }

        clearsSelectionOnViewWillAppear = true

        favoriteListener = dbInstance?.favoritesReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentFavoriteChange(change)
            }
        }
                

        offerListener = dbInstance?.offerReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
        
        refreshTable("")
    }
    
    func refreshTable(_ string: String = "") {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        self.view.addSubview(activityIndicator)
        activityIndicator.frame = self.view.bounds
        activityIndicator.startAnimating()

        dbInstance?.readAllFromDB(string) {
            self.collectionView?.reloadData()
            activityIndicator.removeFromSuperview()
        }
    }

    private func handleDocumentFavoriteChange(_ change: DocumentChange) {
        guard let favorite = EmptyOffer(document: change.document) else {
            return
        }
        
        var offer: Offer?

        if let index = self.dbInstance?.offersQuery.firstIndex(where: {$0.id == favorite.id}) {
            offer = self.dbInstance?.offersQuery[index]
        } else {
            offer = Offer(id: favorite.id)
        }
        
        switch change.type {
        case .added:
            if let offer = offer {
                dbInstance?.offersFavoritesQuery.insert(offer, at: 0)
            }
            
        case .removed:
            if let index = self.dbInstance?.offersFavoritesQuery.firstIndex(where: {$0.id == favorite.id}) {
                dbInstance?.offersFavoritesQuery.remove(at: index)
            }
        case .modified: break
        }

        if let index = self.dbInstance?.offersFavoritesQuery.firstIndex(where: {$0.id == favorite.id}) {
            if dbInstance?.offersQuery.count ?? 0 > 0 {
                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
        
    }

    @objc private func signOut() {
        let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                _ = appDelegate?.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        present(ac, animated: true, completion: nil)
    }

    @objc private func addButtonPressed() {
        let ac = UIAlertController(title: "Create a new Offer", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addTextField { field in
            field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            field.enablesReturnKeyAutomatically = true
            field.autocapitalizationType = .words
            field.clearButtonMode = .whileEditing
            field.placeholder = "Offer name"
            field.returnKeyType = .done
            field.tintColor = UIColor.black
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { _ in
            self.createOffer()
        })
        createAction.isEnabled = false
        ac.addAction(createAction)
        ac.preferredAction = createAction
        
        present(ac, animated: true) {
            ac.textFields?.first?.becomeFirstResponder()
        }
        currentOfferAlertController = ac
    }

    @objc private func textFieldDidChange(_ field: UITextField) {
        guard let ac = currentOfferAlertController else {
            return
        }
        ac.preferredAction?.isEnabled = field.hasText
    }

    private func createOffer() {
        guard let ac = currentOfferAlertController else {
            return
        }
        
        guard let offerName = ac.textFields?.first?.text else {
            return
        }
        
        let offer = Offer(name: offerName, date: String(Int(Date().timeIntervalSince1970 * 1000)))
        dbInstance?.addOferToDB(offer)
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        guard let offer = Offer(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            addOfferToTable(offer)
            
        case .modified:
            updateOfferInTable(offer)
            
        case .removed:
            removeOfferFromTable(offer)
        }
        
        if let index = self.dbInstance?.offersFavoritesQuery.firstIndex(where: {$0.id == offer.id}) {
            dbInstance?.offersFavoritesQuery[index] = offer
        }
        if let index = self.dbInstance?.offersMyQuery.firstIndex(where: {$0.id == offer.id}) {
            dbInstance?.offersMyQuery[index] = offer
        }
    }

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

}

// MARK: - Text Field Delegate
extension SearchViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        refreshTable(searchTextField.text?.lowercased() ?? "")
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (dbInstance?.offersQuery.count) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as? OfferPhotoCell
        cell?.delegate = self
        cell?.prepareForView(dbInstance?.offersQuery, indexPath.row)
        cell?.setHeart(dbInstance?.offersFavoritesQuery.firstIndex(where: {$0.id == cell?.id}) != nil)
        return cell ?? OfferPhotoCell()
    }
}

protocol FavoritesDelegate {
    func changeFavoriteStatus(_ id: String, _ completion: @escaping (Bool) -> Void)
}

extension SearchViewController: FavoritesDelegate {
    func changeFavoriteStatus(_ id: String, _ completion: @escaping (Bool) -> Void) {
        dbInstance?.changeFavoriteStatus(id) { isFavorite in
            completion(isFavorite)
        }
    }
}

extension SearchViewController: DocumentsEditDelegate {
    func updateOffer(_ offer: Offer) {
        dbInstance?.updateOrNewOffer(offer)
    }
    
    var imageReference: StorageReference {
        if let instance = dbInstance {
            return instance.imageReference
        } else {
            return StorageReference()
        }
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
        //offersQuery.sort()
    }
    
    func updateOfferInTable(_ offer: Offer) {
        guard let index = dbInstance?.offersQuery.firstIndex(of: offer) else {
            return
        }
        
        guard offer.hidden != "1" else {
            dbInstance?.offersQuery.remove(at: index)
            collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
            return
        }
        
        dbInstance?.offersQuery[index] = offer

        if let index = dbInstance?.offersMyQuery.firstIndex(where: {$0.id == offer.id}),
           offer.userId == Auth.auth().currentUser?.uid {
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
           offer.userId == Auth.auth().currentUser?.uid {
            dbInstance?.offersMyQuery.remove(at: index)
        }

        collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }

}
