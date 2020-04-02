//
//  Offer.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 12.03.2020.
//

import FirebaseFirestore

struct Offer {
    
    let id: String?
    var name: String
    let date: String?
    
    init(name: String, id: String? = nil, date: String? = nil) {
        self.id = id
        self.name = name
        self.date = date
    }
    
//    init(name: String) {
//        self.init(name: name, id: nil)
//    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        id = document.documentID
        self.name = name

        self.date = data["date"] as? String
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

        return rep
    }
    
}

extension Offer: Comparable {
    
    static func == (lhs: Offer, rhs: Offer) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Offer, rhs: Offer) -> Bool {
        //return Int(lhs.date!)! > Int(rhs.date!)!
        return lhs.date! > rhs.date!
    }
    
}
