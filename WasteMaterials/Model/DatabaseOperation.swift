//
//  DatabaseOperation.swift
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

    var offersQuery = [Offer]()
    let db = Firestore.firestore()

    var offerReference: CollectionReference {
        return db.collection("offers")
    }
    
    func addOferToDB(_ offer: Offer) {
        offerReference.addDocument(data: offer.representation) { error in
            if let e = error {
                print("Error saving channel: \(e.localizedDescription)")
            }
        }
    }
    
    func readAllFromDB(_ query: Query, _ completion: @escaping () -> Void) {
        query.getDocuments(completion: { (snapshot, error) in
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
                    completion()
                }
            }
        })
    }

    var imageReference: StorageReference {
        return Storage.storage().reference().child("images")
    }

    func updateOffer(_ offer: Offer) {
        var ref: DocumentReference? = nil
        if offer.isNew {
            ref = offerReference.addDocument(data: offer.representation) { error in
                if let e = error {
                    print("Error saving channel: \(e.localizedDescription)")
                }
            }
        }
        if let image = offer.image,
            let imageData = image.jpegData(compressionQuality: 0.5) {
            let uploadImageRef = imageReference.child(offer.id ?? ref!.documentID + ".JPG") //(offer.id! + ".JPG")
            let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
                uploadImageRef.downloadURL { (url, error) in
                  guard let downloadURL = url else { return }
                  var offer2 = offer
                  offer2.imageurl = downloadURL.absoluteString
                  self.offerReference.document(offer.id ?? ref!.documentID).setData(offer2.representation)
                }
            }
            uploadTask.resume()
        } else {
          offerReference.document(offer.id ?? ref!.documentID).setData(offer.representation)
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
