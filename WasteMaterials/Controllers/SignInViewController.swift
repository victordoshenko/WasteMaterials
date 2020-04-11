//
//  NavigationController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 12.03.2020.
//

import Firebase
import FirebaseUI

private let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")!

class SignInViewController: UIViewController, FUIAuthDelegate {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            dismiss(animated: true, completion: nil)
            return
        }
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        authUI?.tosurl = kFirebaseTermsOfService
        authUI?.providers = [FUIEmailAuth(), FUIGoogleAuth(), FUIFacebookAuth()]
        let authViewController: UINavigationController? = authUI?.authViewController()
        authViewController?.navigationBar.isHidden = true
        authViewController?.modalPresentationStyle = .fullScreen
        present(authViewController!, animated: true, completion: nil)
    }

    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        switch error {
        case .some(let error as NSError) where UInt(error.code) == FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in")
        case .some(let error as NSError) where error.userInfo[NSUnderlyingErrorKey] != nil:
            print("Login error: \(error.userInfo[NSUnderlyingErrorKey]!)")
        case .some(let error):
            print("Login error: \(error.localizedDescription)")
        case .none:
            if let user = authDataResult?.user {
                signed(in: user)
            }
        }
    }

    func signed(in user: User) {
        dismiss(animated: true, completion: nil)
    }
}
