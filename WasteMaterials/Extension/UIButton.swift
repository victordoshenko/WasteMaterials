//
//  UIButton.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 20.06.2020.
//

import UIKit

extension UIButton {

    var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    func setRoundedCorners() {
        borderWidth = 0.5
        borderColor = .gray
        cornerRadius = 5
    }
}
