//
//  Offer.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 12.03.2020.
//

import FirebaseFirestore
import Firebase

struct Offer {
    
    var id: String?
    var name: String
    let date: String?
    var imageurl: String?
    var image: UIImage? = nil
    var userId: String?
    var isFavorite: Bool = false
    
    init(name: String, id: String? = nil, date: String? = nil, imageurl: String? = nil, image: UIImage? = nil, userId: String? = Auth.auth().currentUser?.uid) {
        self.id = id
        self.name = name
        self.date = date
        self.imageurl = imageurl
        self.image = image
        self.userId = userId
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        id = document.documentID
        self.name = name

        self.date = data["date"] as? String
        self.imageurl = data["imageurl"] as? String
        self.userId = data["userId"] as? String
    }
    
    mutating func setImageURL(_ url: String?) {
        self.imageurl = url
    }

}

extension Offer: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep = ["name": name]
        
        if let id = id {
            rep["id"] = id
        }

        if let date = date {
            rep["date"] = date
        }

        if let imageurl = imageurl {
            rep["imageurl"] = imageurl
        }

        if let userId = userId {
            rep["userId"] = userId
        }

        return rep
    }
    
}

extension Offer: Comparable {
    
    static func == (lhs: Offer, rhs: Offer) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Offer, rhs: Offer) -> Bool {
        return lhs.date! < rhs.date!
    }
    
}
