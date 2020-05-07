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
    var name: String?
    var description: String?
    let date: String?
    var imageurl: String?
    var image: UIImage? = nil
    var userId: String?
    
    init(name: String? = nil, description: String? = nil, id: String? = nil, date: String? = nil, imageurl: String? = nil, image: UIImage? = nil, userId: String? = Auth.auth().currentUser?.uid) {
        self.id = id
        self.name = name
        self.description = description
        self.date = date
        self.imageurl = imageurl
        self.image = image
        self.userId = userId
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        id = document.documentID
        self.name = data["name"] as? String
        self.description = data["description"] as? String
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

        if let description = description {
            rep["description"] = description
        }

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

        return rep as [String : Any]
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


class Favorite {

    var id: String?

    init(id: String? = nil) {
        self.id = id
    }

    init?(document: QueryDocumentSnapshot) {
        id = document.documentID
    }

}
