//
//  AppController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 12.03.2020.
//

import UIKit
import Firebase

final class AppController {
  
  static let shared = AppController()
  
  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userStateDidChange),
      name: Notification.Name.AuthStateDidChange,
      object: nil
    )
  }
  
  private var window: UIWindow!
  private var rootViewController: UIViewController? {
    didSet {
      if let vc = rootViewController {
        window.rootViewController = vc
      }
    }
  }
  
  func show(in window: UIWindow?) {
    guard let window = window else {
      fatalError("Cannot layout app with a nil window.")
    }
    
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }

    self.window = window
    //window.tintColor = UIColor.black
    window.backgroundColor = .white
    
    handleAppState()
    
    window.makeKeyAndVisible()
  }
  
    private func handleAppState() {
        guard rootViewController == nil else { return }
        if let _ = Auth.auth().currentUser {
            //let vc = MainViewController(currentUser: user)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyCollectionViewController") as! MyCollectionViewController
            rootViewController = UINavigationController(rootViewController: vc)
        } else {
            rootViewController = SignInViewController()
        }
    }
  
  @objc internal func userStateDidChange() {
    DispatchQueue.main.async {
      self.handleAppState()
    }
  }
  
}
