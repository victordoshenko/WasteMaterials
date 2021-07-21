//
//  NavigationController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 12.03.2020.
//

import Firebase
import FirebaseUI

private let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")

@objc(SignInViewController)
class SignInViewController: UIViewController, FUIAuthDelegate {

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if Auth.auth().currentUser != nil {
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
      appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
      dismiss(animated: true, completion: nil)
      return
    }
    if let authUI = FUIAuth.defaultAuthUI() {
        authUI.delegate = self
        authUI.tosurl = kFirebaseTermsOfService
        authUI.providers = [FUIEmailAuth(), FUIGoogleAuth(), FUIFacebookAuth(), FUIOAuth.appleAuthProvider()]
        let authViewController = authUI.authViewController()
        authViewController.navigationBar.isHidden = true
        authViewController.modalPresentationStyle = .fullScreen
        self.present(authViewController, animated: true)
    }
  }

  func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
    switch error {
    case .some(let error as NSError) where UInt(error.code) == FUIAuthErrorCode.userCancelledSignIn.rawValue:
      print("User cancelled sign-in")
    case .some(let error as NSError) where error.userInfo[NSUnderlyingErrorKey] != nil:
        print("Login error: \(String(describing: error.userInfo[NSUnderlyingErrorKey]))")
    case .some(let error):
      print("Login error: \(error.localizedDescription)")
    case .none:
      if let user = authDataResult?.user {
        print("Signed as \(user.uid). E-mail: \(user.email ?? "")")
        signed(in: user)
      }
    }
  }

  func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
    return FAuthPickerViewController(nibName: "FAuthPickerViewController", bundle: Bundle.main, authUI: authUI)
  }

  func signed(in user: User) {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
    dismiss(animated: true, completion: nil)
  }

}
