import UIKit
import FirebaseUI
import Firebase

class MainViewController: UIViewController {

    @IBAction func logoutButtonAction(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                _ = appDelegate?.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
}
