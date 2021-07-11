//
//  SideViewController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 22.04.2020.
//

import UIKit
import Firebase

class SideViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logOut(_ sender: Any) {
        let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                _ = appDelegate?.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        present(ac, animated: true, completion: nil)
    }
    
    @IBAction func goProfile(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileController") as? ProfileController else { return }
        self.navigationController?.pushViewController(vc, animated: true)

    }
    @IBAction func goFavorites(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SearchFavorites") as? SearchFavoritesController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func goBookmarks(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "Bookmarks") as? SearchMyController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
