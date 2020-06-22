//
//  WUser.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 15.06.2020.
//

import FirebaseFirestore
import Firebase

struct WUser {
    
    var id: String?
    var name: String?
    var email: String?
    var phone: String?
    var countryid: String?
    var regionid: String?
    var cityid: String?
    let date: String?
    
    init(id: String? = Auth.auth().currentUser?.uid, name: String? = nil, email: String? = nil, phone: String? = nil, countryid: String? = nil, regionid: String? = nil, cityid: String? = nil, date: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.countryid = countryid
        self.regionid = regionid
        self.cityid = cityid
        self.date = date
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        id = document.documentID
        self.name = data["name"] as? String
        self.email = data["email"] as? String
        self.phone = data["phone"] as? String
        self.regionid = data["regionid"] as? String
        self.date = data["date"] as? String
    }
    
}

extension WUser: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep = ["id": id]

        if let name = name {
            rep["name"] = name
        }

        if let email = email {
            rep["email"] = email
        }

        if let phone = phone {
            rep["phone"] = phone
        }

        if let regionid = regionid {
            rep["regionid"] = regionid
        }

        if let date = date {
            rep["date"] = date
        }

        return rep as [String : Any]
    }
    
}
