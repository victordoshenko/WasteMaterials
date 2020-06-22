//
//  Flag.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 21.06.2020.
//

internal func getFlag(from countryCode: String) -> String {

    return countryCode
        .uppercased()
        .unicodeScalars
        .map({ 127397 + $0.value })
        .compactMap(UnicodeScalar.init)
        .map(String.init)
        .joined()
}
