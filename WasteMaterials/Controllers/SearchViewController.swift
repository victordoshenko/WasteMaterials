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

final class SearchViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var dbInstance: DatabaseInstance?

    private var searchTextField = UITextField()
    private let reuseIdentifier = "OfferCell"
    private let sectionInsets = UIEdgeInsets(top: 20.0,
                                             left: 20.0,
                                             bottom: 20.0,
                                             right: 20.0)
    private var currentOfferAlertController: UIAlertController?
    private var offerListener: ListenerRegistration?
    
    private var offerReferenceQuery: Query {
        return (dbInstance?.offerReference.whereField("name", isGreaterThanOrEqualTo: searchTextField.text!))!
    }

    private var itemsPerRow: CGFloat = 2
        
    deinit {
        offerListener?.remove()
    }

    func updateUI(_ firstTime: Bool = false) {
        if !firstTime { return }
        let paddingSpace = sectionInsets.left * (itemsPerRow + (firstTime ? 1 : -1))
        let availableWidth = (firstTime ? view.frame.width : view.frame.height) - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let cellSize = CGSize(width: widthPerItem , height: widthPerItem)
        
        searchTextField.frame =  CGRect(x: searchTextField.frame.origin.x , y: searchTextField.frame.origin.y, width: availableWidth
            //- filterButton.width //- menuButton.width
            , height: searchTextField.frame.height)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("***** viewWillTransition Landscape")
            itemsPerRow = 3
        } else {
            print("***** viewWillTransition Portrait")
            itemsPerRow = 2
        }
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let controller = segue.destination as! DetailsViewController
            let cell = sender as! UICollectionViewCell
            if let indexPath = self.collectionView!.indexPath(for: cell) {
                controller.offer = dbInstance?.offersQuery[indexPath.row]
                controller.delegate = self
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\n**************************")
        if UIDevice.current.orientation.isLandscape {
            print("***** viewDidLoad Landscape")
            itemsPerRow = 3
        } else {
            print("***** viewDidLoad Portrait")
            itemsPerRow = 2
        }
        print("**************************\n")
        updateUI()
        
        let vc = self.parent as! MenuViewController
        vc.showSearch()
        self.searchTextField = vc.searchTextField
        self.searchTextField.delegate = self
        self.dbInstance = vc.dbInstance

        clearsSelectionOnViewWillAppear = true

        offerListener = dbInstance?.offerReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
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
        // 1
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        dbInstance?.readAllFromDB(offerReferenceQuery) {
            self.collectionView?.reloadData()
            activityIndicator.removeFromSuperview()
        }

        //textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController {

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
        
        dbInstance?.favoritesReference.document(cell.id!).getDocument { (document, error) in
            if let document = document {
                if document.exists {
                    cell.favoriteButton.setTitle("♥︎", for: .normal)
                } else {
                    cell.favoriteButton.setTitle("♡", for: .normal)
                }
            }
        }

        cell.imageView.image = nil
        cell.goodsNameLabel.textColor = .systemBlue
        cell.favoriteButton.setTitleColor(.systemBlue, for: .normal)
        if let url = dbInstance?.offersQuery[indexPath.row].imageurl {
            cell.imageView.sd_setImage(with: URL(string: url)) { (img, err, c, u) in
                if let err = err {
                    print("There's an error:\(err)")
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

protocol FavoritesDelegate {
    func updateFavorite(_ id: String?, _ isFavorite: Bool)
}

extension SearchViewController: FavoritesDelegate {
    func updateFavorite(_ id: String?) -> Bool{
//        print("Update favorite! id = \(id ?? "") isFavorite = \(isFavorite)")
        return dbInstance?.addOrRemoveFavorites(id)
    }
}

extension SearchViewController: DocumentsEditDelegate {
    func updateOffer(_ offer: Offer) {
        dbInstance?.updateOrNewOffer(offer)
    }
    
    var imageReference: StorageReference {
        return dbInstance!.imageReference
    }

    func addOfferToTable(_ offer: Offer) {
        guard !(dbInstance?.offersQuery.contains(offer))! else {
            return
        }
        
        dbInstance?.offersQuery.insert(offer, at: 0)
        //offersQuery.sort()
        
        guard let index = dbInstance?.offersQuery.firstIndex(of: offer) else {
            return
        }

        if offer.name >= (searchTextField.text ?? "") || searchTextField.text == "" {
            collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
            collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func updateOfferInTable(_ offer: Offer) {
        guard let index = dbInstance?.offersQuery.firstIndex(of: offer) else {
            return
        }
        
        dbInstance?.offersQuery[index] = offer
        collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
    
    func removeOfferFromTable(_ offer: Offer) {
        guard let index = dbInstance?.offersQuery.firstIndex(of: offer) else {
            return
        }
        dbInstance?.offersQuery.remove(at: index)
        dbInstance?.deleteOffer(offer)

        collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }

}
