//
//  Array.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 11.05.2020.
//

extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}

