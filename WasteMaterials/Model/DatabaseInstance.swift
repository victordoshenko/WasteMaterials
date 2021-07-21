//
//  DatabaseInstance.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 22.04.2020.
//

import Firebase

protocol DocumentsEditDelegate {
    func addOfferToTable(_ offer: Offer)
    func updateOfferInTable(_ offer: Offer)
    func removeOfferFromTable(_ offer: Offer)
    func updateOffer(_ offer: Offer)
    var imageReference: StorageReference { get }
}

class DatabaseInstance {
    
    let defaults = UserDefaults.standard

    var offersQuery = [Offer]()
    var offersFavoritesQuery = [Offer]()
    var offersMyQuery = [Offer]()
    var offersSearchIDsQuery = [EmptyOffer]()
    public var user = WUser(id: Auth.auth().currentUser?.uid)

    let db = Firestore.firestore()

    var offerReference: CollectionReference {
        return db.collection("offers")
    }

    var favoritesReference: CollectionReference {
        return db.collection("favorites/\(String(describing: Auth.auth().currentUser?.uid))/ids")
    }
    
    var userReference: CollectionReference {
        return db.collection("users")
    }
    
    init() {
        initUser()
    }

    func getOffer(_ id: String, _ completion: @escaping (Offer) -> Void) -> Void {
        offerReference.document(id).getDocument { (document, error) in
            if let offer = Offer(document: document as! QueryDocumentSnapshot) {
                completion(offer)
            }
        }
    }

    func checkIsFavorite(_ id: String, _ completion: @escaping (Bool) -> Void) -> Bool {
        var result = false
        favoritesReference.document(id).getDocument { (document, error) in
            if let document = document {
                result = document.exists
            }
            completion(result)
        }
        return result
    }
    
    func changeFavoriteStatus(_ id: String, _ completion: @escaping (Bool) -> Void) {

        var isFavorite = false

        if offersFavoritesQuery.firstIndex(where: {$0.id == id}) != nil {
            isFavorite = true
        }
        
        if isFavorite {
            self.favoritesReference.document(id).delete()
        } else {
            self.favoritesReference.document(id).setData([:])
        }
        isFavorite = !isFavorite

        completion(isFavorite)
    }

    var imageReference: StorageReference {
        if let user = Auth.auth().currentUser {
            return Storage.storage().reference().child("images").child(user.uid)
        } else {
            return StorageReference()
        }
    }

    func addOferToDB(_ offer: Offer) {
        offerReference.addDocument(data: offer.representation) { error in
            if let e = error {
                print("Error saving channel: \(e.localizedDescription)")
            }
        }
    }
    
    func fillOffersQuery(_ showAll: Bool, _ completion: @escaping () -> Void) {
        offerReference
            .whereField("hidden", isLessThan: "1")
            .whereField(defaults.integer(forKey: "CountryID") == 0 ? "z" : "countryid", isEqualTo: defaults.integer(forKey: "CountryID") == 0 ? "0" : defaults.string(forKey: "CountryID") ?? "0")
            .whereField(defaults.integer(forKey: "RegionID") == 0 ? "z" : "regionid", isEqualTo: defaults.integer(forKey: "RegionID") == 0 ? "0" : defaults.string(forKey: "RegionID") ?? "0")
            .whereField(defaults.integer(forKey: "CityID") == 0 ? "z" : "cityid", isEqualTo: defaults.integer(forKey: "CityID") == 0 ? "0" : defaults.string(forKey: "CityID") ?? "0")
            
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let snapshot = snapshot {
                        self.offersQuery.removeAll()
                        for document in snapshot.documents {
                            guard showAll ||
                                self.offersSearchIDsQuery.firstIndex(where: { $0.id == document.documentID }) != nil else {
                                    continue
                            }
                            
                            if let offer = Offer(document: document) {
                                self.offersQuery.append(offer)
                            }
                        }
                    }
                }
                completion()
        }
    }
    
    func readAllFromDB(_ searchString: String, _ completion: @escaping () -> Void) {
        self.offersSearchIDsQuery.removeAll()
        guard searchString != "" else {
            self.fillOffersQuery(true, completion)
            return
        }

        db.collection("words/\(searchString)/ids").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err.localizedDescription)")
            } else {
                if let qs = querySnapshot {
                    for document in qs.documents {
                        let empty = EmptyOffer(id: document.documentID)
                        self.offersSearchIDsQuery.append(empty)
                    }
                }
                self.fillOffersQuery(false, completion)
            }
        }
    }

    func updateUser(_ user: WUser?) {
        self.user.name = user?.name
        self.user.email = user?.email
        self.user.phone = user?.phone
        
        if let user = Auth.auth().currentUser {
            userReference.document(user.uid).setData(self.user.representation) { error in
                if let error = error {
                    print("There's an error: \(error.localizedDescription)")
                }
            }
        }
    }

    func getUser(_ userId: String? = Auth.auth().currentUser?.uid, _ completion: @escaping (WUser) -> Void)  {
        userReference.document(userId ?? "").getDocument { (document, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let data = document?.data() {
                    var user = WUser(id: document?.documentID)
                    user.name = data["name"] as? String
                    user.email = data["email"] as? String
                    user.phone = data["phone"] as? String
                    completion(user)
                }
            }
        }
    }

    func initUser() {
        getUser() { (user) in
            self.user = user
        }
    }

    func updateOffer(_ offer: Offer) {
        if let image = offer.image,
            let user = Auth.auth().currentUser,
            user.uid == offer.userId,
            let imageData = image.jpegData(compressionQuality: 0.3) {
            let uploadImageRef = imageReference.child((offer.id ?? "") + ".JPG")
            let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
                uploadImageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else { return }
                    var offer2 = offer
                    offer2.imageurl = downloadURL.absoluteString
                    self.offerReference.document(offer2.id ?? "").setData(offer2.representation) { error in
                        if let error = error {
                            print("There's an error: \(error.localizedDescription)")
                        }
                    }
                }
            }
            uploadTask.resume()
        } else {
            offerReference.document(offer.id ?? "").setData(offer.representation)
        }
    }

    func updateOrNewOffer(_ offer: Offer) {
        var ref: DocumentReference? = nil
        if offer.id == nil {  // New
            var words = offer.description?.components(separatedBy: " ").removingDuplicates() ?? []
            let n_words = offer.name?.components(separatedBy: " ").removingDuplicates() ?? []
            for n_word in n_words where n_word.count > 2 {
                words.append(n_word)
            }

            words = words.removingDuplicates()

            ref = offerReference.addDocument(data: offer.representation) { error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    var offer2 = offer
                    offer2.id = ref?.documentID
                    self.updateOffer(offer2)
                    for word in words where word.count > 2 {
                        self.db.collection("words/\(word.lowercased())/ids").document(offer2.id ?? "").setData([:])
                    }
                }
            }
        } else {
            offerReference.document(offer.id ?? "").getDocument { (document, error) in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    if let data = document?.data(),
                        let description = data["description"] as? String
                    {
                        var words = description.components(separatedBy: " ").removingDuplicates()
                        words.append(offer.name ?? "")
                        for word in words where word.count > 2 {
                            self.db.collection("words/\(word)/ids").document(offer.id ?? "").delete() { error in
                                if let e = error {
                                    print(e.localizedDescription)
                                } else {
                                    print("Document successfully removed!")
                                }
                            }
                        }
                    }
                    var words = offer.description?.components(separatedBy: " ").removingDuplicates() ?? []
                    words.append(offer.name ?? "")
                    for word in words where word.count > 2 {
                        self.db.collection("words/\(word.lowercased())/ids").document(offer.id ?? "").setData([:])
                    }
                    self.updateOffer(offer)
                }
            }
        }
    }

    func deleteOffer(_ offer: Offer) {
        offerReference.document(offer.id ?? "").delete() { error in
            if let error = error {
                print("There's an error: \(error.localizedDescription)")
            } else {
                var words = offer.description?.components(separatedBy: " ").removingDuplicates() ?? []
                words.append(offer.name ?? "")
                for word in words where word.count > 2 {
                    self.db.collection("words/\(word.lowercased())/ids").document(offer.id ?? "").delete() { error in
                        if let e = error {
                            print(e.localizedDescription)
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                }
                self.imageReference.child((offer.id ?? "") + ".JPG").delete() { error in
                    if let error = error {
                        print("There's an error: \(error.localizedDescription)")
                    }
                }
                self.favoritesReference.document(offer.id ?? "").delete() { error in
                    if let error = error {
                        print("There's an error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

}
