//
//  GeoItem.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 19.06.2020.
//

import Foundation

struct GeoItem: Decodable {
    let cid: Int?   // country id
    let cnam: String?  // country name
    let ccod: String?  // country code
    let nam: String?   // city or region name
    let rnam: String?  // region name
    let rid: Int?   // region id
    let cyid: Int?  // city id
    let rcod: String?  // region code
    let lat: String?   // latitude
    let lon: String?   // longitude
    enum CodingKeys: String, CodingKey {
        case cid = "CID"
        case cnam = "CNAM"
        case ccod = "CCOD"
        case nam = "NAM"
        case rnam = "RNAM"
        case rid = "RID"
        case cyid = "CYID"
        case rcod = "RCOD"
        case lat = "LAT"
        case lon = "LON"
    }
}

typealias GeoItems = [GeoItem]
