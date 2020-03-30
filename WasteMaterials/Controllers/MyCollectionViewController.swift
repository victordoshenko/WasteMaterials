/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import FirebaseUI
import Firebase

final class MyCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "FlickrCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    //private var searches: [FlickrSearchResults] = []
    private var currentOfferAlertController: UIAlertController?
    private var offers = [Offer]()
    private var offerListener: ListenerRegistration?
    
    private var currentUser = Auth.auth().currentUser //: User
    private let toolbarLabel: UILabel = {
      let label = UILabel()
      label.textAlignment = .center
      label.font = UIFont.systemFont(ofSize: 15)
      return label
    }()

    private let db = Firestore.firestore()
    
    //private let flickr = Flickr()
    private let itemsPerRow: CGFloat = 2
    
    private var offerReference: CollectionReference {
        return db.collection("offers")
    }
    
    deinit {
        offerListener?.remove()
    }

//    static func myCollectionViewController(currentUser: User) -> MyCollectionViewController {
//        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCollectionViewController") as! MyCollectionViewController
//        newViewController.currentUser = currentUser
//        return newViewController
//    }
    
//    init(collectionView: UICollectionView, frame: CGRect, currentUser: User) {

/*
    init(currentUser: User) {
        let layout = UICollectionViewLayout()
        
        self.currentUser = currentUser
        self.db = Firestore.firestore()
        super.init(collectionViewLayout: layout)
        self.collectionView = collectionView
    }
*/
    
//    init(collectionView: UICollectionView, frame: CGRect, currentUser: User) {
//        self.currentUser = currentUser
//        self.db = Firestore.firestore()
//        self.collectionView = collectionView
//        let layout = UICollectionViewLayout()
//        super.init(nibName: frame, bundle: layout)
//        title = "Offers"
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        //fatalError("init(coder:) has not been implemented")
//        self.currentUser = Auth.auth().currentUser!
//        super.init(coder: aDecoder)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
        //collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        toolbarItems = [
            UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: toolbarLabel),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed)),
        ]
        toolbarLabel.text = "Offers"
        self.navigationController?.isToolbarHidden = false

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
        
        let offer = Offer(name: offerName)
        offerReference.addDocument(data: offer.representation) { error in
            if let e = error {
                print("Error saving channel: \(e.localizedDescription)")
            }
        }
    }

    private func addOfferToTable(_ offer: Offer) {
        guard !offers.contains(offer) else {
            return
        }
        
        offers.append(offer)
        offers.sort()
        
        guard let index = offers.index(of: offer) else {
            return
        }
        collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
        //tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func updateOfferInTable(_ offer: Offer) {
        guard let index = offers.index(of: offer) else {
            return
        }
        
        offers[index] = offer
        collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        //tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeOfferFromTable(_ offer: Offer) {
        guard let index = offers.index(of: offer) else {
            return
        }
        
        offers.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        //tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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

/*
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
/*
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
*/
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

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
/*
    flickr.searchFlickr(for: textField.text!) { searchResults in
      activityIndicator.removeFromSuperview()
      
      switch searchResults {
      case .error(let error) :
        // 2
        print("Error Searching: \(error)")
      case .results(let results):
        // 3
        print("Found \(results.searchResults.count) matching \(results.searchTerm)")
        self.searches.insert(results, at: 0)
        // 4
        self.collectionView?.reloadData()
      }
    }
 */
    textField.text = nil
    textField.resignFirstResponder()
    return true
  }
}

// MARK: - UICollectionViewDataSource
extension MyCollectionViewController {
  //1
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1 //searches.count
  }
  
  //2
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return offers.count //searches[section].searchResults.count
  }
  
  //3
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    //1
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                  for: indexPath) as! FlickrPhotoCell
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
    cell.layer.shadowOffset = CGSize(width: 4.0, height: 8.0)
    cell.layer.shadowRadius = 2.0
    cell.layer.shadowOpacity = 1.0
    cell.layer.masksToBounds = false
    
    cell.goodsNameLabel.text = offers[indexPath.row].name

    return cell
  }
}

// MARK: - Collection View Flow Layout Delegate
extension MyCollectionViewController : UICollectionViewDelegateFlowLayout {
  //1
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    //2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  //3
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  // 4
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}
