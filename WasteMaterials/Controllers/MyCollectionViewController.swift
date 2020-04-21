//
//  MyCollectionViewController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 20.03.2020.
//

import UIKit
import FirebaseUI
import Firebase
import SDWebImage

protocol DocumentsEditDelegate {
    func addOfferToTable(_ offer: Offer)
    func updateOfferInTable(_ offer: Offer)
    func removeOfferFromTable(_ offer: Offer)
    func updateOffer(_ offer: Offer)
    var imageReference: StorageReference { get }
}

final class MyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
//    @IBOutlet weak var filterButton: UIBarButtonItem!    
//    @IBOutlet weak var menuButton: UIBarButtonItem!
//    @IBOutlet weak var searchTextField: UITextField!
    private var searchTextField = UITextField()
    private let reuseIdentifier = "OfferCell"
    private let sectionInsets = UIEdgeInsets(top: 20.0,
                                             left: 20.0,
                                             bottom: 20.0,
                                             right: 20.0)
    private var currentOfferAlertController: UIAlertController?
    private var offersQuery = [Offer]()
    private var offerListener: ListenerRegistration?
    
    private var currentUser = Auth.auth().currentUser
    private let toolbarLabel: UILabel = {
      let label = UILabel()
      label.textAlignment = .center
      label.font = UIFont.systemFont(ofSize: 15)
      return label
    }()

    private let db = Firestore.firestore()
    private var offerReference: CollectionReference {
        return db.collection("offers")
    }
    private var offerReferenceQuery: Query {
        return db.collection("offers").whereField("name", isGreaterThanOrEqualTo: searchTextField.text!)
    }

    private var itemsPerRow: CGFloat = 2
        
    deinit {
        offerListener?.remove()
    }

    func updateUI(_ firstTime: Bool = false) {
        return
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
                controller.offer = offersQuery[indexPath.row]
                controller.delegate = self
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.orientation.isLandscape {
            print("***** viewDidLoad Landscape")
            itemsPerRow = 3
        } else {
            print("***** viewDidLoad Portrait")
            itemsPerRow = 2
        }
        updateUI(true)
        
//        searchTextField.frame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.size.width)!, height: 21.0)
        //searchTextField.placeholder = "Search"
        //self.navigationController!.navigationBar.addSubview(searchTextField)
        let vc = self.parent as! MenuViewController
        vc.hideSearch(false)
        self.searchTextField = vc.searchTextField
        self.searchTextField.delegate = self

        //var search = UISearchController(searchResultsController: nil)
        //self.navigationItem.searchController = search //titleView = searchTextField
        
        //menuButton.image = UIImage(named: "text.justify")
        //filterButton.image = UIImage(named: "slider.horizontal.3")
        
        clearsSelectionOnViewWillAppear = true

//        toolbarItems = [
//            UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)),
//            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//            UIBarButtonItem(customView: toolbarLabel),
//            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed)),
//        ]
//        toolbarLabel.text = "Offers"
        
//        self.navigationController?.isToolbarHidden = true
//        self.navigationController!.navigationBar.isTranslucent = false
        
        offerListener = offerReference.addSnapshotListener { querySnapshot, error in
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
        offerReference.addDocument(data: offer.representation) { error in
            if let e = error {
                print("Error saving channel: \(e.localizedDescription)")
            }
        }
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

// MARK: - Private
private extension MyCollectionViewController {
  /*
  func photo(for indexPath: IndexPath) -> FlickrPhoto {
    return searches[indexPath.section].searchResults[indexPath.row]
  }
 */
}

// MARK: - Text Field Delegate
extension MyCollectionViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 1
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        offerReferenceQuery.getDocuments(completion: { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let snapshot = snapshot {
                    self.offersQuery.removeAll()
                    for document in snapshot.documents {
                        let data = document.data()
                        if let name = data["name"] as? String,
                            let date = data["date"] as? String {
                            let id = document.documentID as String
                            let imageurl = data["imageurl"] as? String
                            let newOffer = Offer(name:name, id:id, date:date, imageurl: imageurl)
                            self.offersQuery.append(newOffer)
                        }
                    }
                    self.collectionView?.reloadData()
                    activityIndicator.removeFromSuperview()
                }
            }
        })
        //textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension MyCollectionViewController {
  //1
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  //2
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return offersQuery.count
  }
  
    //3
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! OfferPhotoCell
        //2
        //let flickrPhoto = photo(for: indexPath)
        cell.backgroundColor = .white
        //3
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
        
        cell.goodsNameLabel.text = offersQuery[indexPath.row].name
        cell.imageView.image = nil
        cell.goodsNameLabel.textColor = .systemBlue
        if let url = offersQuery[indexPath.row].imageurl {
            cell.imageView.sd_setImage(with: URL(string: url)) { (img, err, c, u) in
                if let err = err {
                    print("There's an error:\(err)")
                } else {
                    cell.imageView.image = img
                    self.offersQuery[indexPath.row].image = img
                    cell.goodsNameLabel.textColor = .white
                }
            }
        }
        return cell
    }
}

extension MyCollectionViewController: DocumentsEditDelegate {

    var imageReference: StorageReference {
        return Storage.storage().reference().child("images")
    }

    func addOfferToTable(_ offer: Offer) {
        guard !offersQuery.contains(offer) else {
            return
        }
        
        offersQuery.insert(offer, at: 0)
        //offersQuery.sort()
        
        guard let index = offersQuery.firstIndex(of: offer) else {
            return
        }

        if offer.name >= (searchTextField.text ?? "") || searchTextField.text == "" {
            collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
            collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func updateOfferInTable(_ offer: Offer) {
        guard let index = offersQuery.firstIndex(of: offer) else {
            return
        }
        
        offersQuery[index] = offer
        collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
    
    func removeOfferFromTable(_ offer: Offer) {
        guard let index = offersQuery.firstIndex(of: offer) else {
            return
        }
        offersQuery.remove(at: index)
        deleteOffer(offer)

        collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }

    func updateOffer(_ offer: Offer) {
        if let image = offer.image,
            let imageData = image.jpegData(compressionQuality: 0.5) {
            let uploadImageRef = imageReference.child(offer.id! + ".JPG")
            let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
                uploadImageRef.downloadURL { (url, error) in
                  guard let downloadURL = url else { return }
                  var offer2 = offer
                  offer2.imageurl = downloadURL.absoluteString
                  self.offerReference.document(offer.id ?? "").setData(offer2.representation)
                }
            }
            uploadTask.resume()
        } else {
          offerReference.document(offer.id ?? "").setData(offer.representation)
        }
    }

    func deleteOffer(_ offer: Offer) {
        imageReference.child(offer.id! + ".JPG").delete() { error in
            if let error = error {
                print("There's an error: \(error.localizedDescription)")
            }
        }
        
        offerReference.document(offer.id ?? "").delete()
    }

}
