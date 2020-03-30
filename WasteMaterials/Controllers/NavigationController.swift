//
//  NavigationController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 12.03.2020.
//

import UIKit

class NavigationController: UINavigationController {
  
  init(_ rootVC: UIViewController) {
    super.init(nibName: nil, bundle: nil)
    pushViewController(rootVC, animated: false)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBar.tintColor = UIColor.black
    //navigationBar.prefersLargeTitles = true
    //navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    //navigationBar.largeTitleTextAttributes = navigationBar.titleTextAttributes
    
    toolbar.tintColor = UIColor.black
  }
  
  override var shouldAutorotate: Bool {
    return true //false
  }
  
//  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//    return .portrait
//  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle ?? .default
  }
  
}
