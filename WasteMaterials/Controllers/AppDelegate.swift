import UIKit

import Firebase
import FirebaseUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
    
  override init() {
    super.init()
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions
      launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }

    if Auth.auth().currentUser == nil {
      self.window?.rootViewController = SignInViewController()
    }
    return true
  }

  @available(iOS 9.0, *)
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String else {
      return false
    }
    return self.handleOpenUrl(url, sourceApplication: sourceApplication)
  }

  @available(iOS 8.0, *)
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return self.handleOpenUrl(url, sourceApplication: sourceApplication)
  }

  func handleOpenUrl(_ url: URL, sourceApplication: String?) -> Bool {
    return FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false
  }

}
