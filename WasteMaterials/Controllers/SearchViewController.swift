//
//  ViewController.swift
//  HomeWork10
//
//  Created by Victor Doshchenko on 03.02.2020.
//  Copyright © 2020 Victor Doshchenko. All rights reserved.
//

import UIKit

struct Cat {
    let catImage: UIImage
    let oldPrice, newPrice: Double
    let name: String
}

class CatFabric {
    static func cats() -> [Cat] {
        return [
            Cat(catImage: UIImage(named: "c1")!, oldPrice: 200, newPrice: 100, name: "Cat1"),
            Cat(catImage: UIImage(named: "c2")!, oldPrice: 300, newPrice: 120, name: "Cat2"),
            Cat(catImage: UIImage(named: "c3")!, oldPrice: 250, newPrice: 150, name: "Cat3"),
            Cat(catImage: UIImage(named: "c4")!, oldPrice: 400, newPrice: 50, name: "Cat4"),
            Cat(catImage: UIImage(named: "c3")!, oldPrice: 250, newPrice: 150, name: "Cat31"),
            Cat(catImage: UIImage(named: "c4")!, oldPrice: 400, newPrice: 50, name: "Cat41"),
            Cat(catImage: UIImage(named: "c5")!, oldPrice: 2000, newPrice: 1200, name: "Cat5"),
            Cat(catImage: UIImage(named: "c5")!, oldPrice: 2000, newPrice: 1200, name: "Cat51"),
            Cat(catImage: UIImage(named: "c5")!, oldPrice: 2000, newPrice: 1200, name: "Cat52"),
            Cat(catImage: UIImage(named: "c6")!, oldPrice: 8000, newPrice: 5000, name: "Cat6 with very very very very very very very long name")
        ]
    }
}

class SearchViewController: UIViewController {
    var cats = CatFabric.cats()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

extension SearchViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCollectionViewCell
        //cell.layer.borderColor = UIColor.gray.cgColor
        //cell.layer.borderWidth = 1
        cell.shadowDecorate()

        /*
        cell.myContentView.layer.shadowColor = UIColor.black.cgColor
        cell.myContentView.layer.shadowOpacity = 1
        cell.myContentView.layer.shadowOffset = .zero
        cell.myContentView.layer.shadowRadius = 10
 */
//        cell.layer.shouldRasterize = true
//        cell.layer.rasterizationScale = UIScreen.main.scale
        
        cell.nameLabel.text = cats[indexPath.row].name
        cell.newPriceLabel.text = String(Int(cats[indexPath.row].newPrice)) + " руб."
        cell.oldPriceLabel.attributedText = (String(Int(cats[indexPath.row].oldPrice)) + " руб").strikeThrough()
        cell.discountLabel.text = String(Int((1 - cats[indexPath.row].newPrice / cats[indexPath.row].oldPrice) * 100)) + "%"
        cell.catImageView.image = cats[indexPath.row].catImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = UIScreen.main.bounds.size.width / 2
        return CGSize(width: w, height: w * 1.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cats.count
    }
}

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: 1,
            range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
}
