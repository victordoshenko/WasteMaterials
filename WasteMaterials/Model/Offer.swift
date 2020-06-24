//
//  Offer.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 12.03.2020.
//

import FirebaseFirestore
import Firebase

struct Offer {

    let defaults = UserDefaults.standard

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

        rep["z"] = "0"

        if defaults.integer(forKey: "CountryID") > 0 {
            rep["countryid"] = defaults.string(forKey: "CountryID")
        }

        if defaults.integer(forKey: "RegionID") > 0 {
            rep["regionid"] = defaults.string(forKey: "RegionID")
        }

        if defaults.integer(forKey: "CityID") > 0 {
            rep["cityid"] = defaults.string(forKey: "CityID")
        }

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

class EmptyOffer {

    var id: String?

    init(id: String? = nil) {
        self.id = id
    }

    init?(document: QueryDocumentSnapshot) {
        id = document.documentID
    }

}

extension EmptyOffer: DatabaseRepresentation {
    
    var representation: [String : Any] {
        let rep = ["id": id]
        return rep as [String : Any]
    }
    
}
