//
//  Storyboard.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 12/05/23.
//

import UIKit
enum StoryboardIdentifiers : String {
    case cityList  = "CityListViewController"
    var instance: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: Bundle.main)
    }
    
    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T {
        let storyboardID = viewControllerClass.storyboardID
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
}
extension UIStoryboard {
    
    //MARK: STORYBOARD
    class func cityListStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    class func cityListVC() -> CityListViewController {
        return cityListStoryboard().instantiateViewController(withIdentifier: "CityListViewController") as! CityListViewController
     }
}

enum StoryboardSegue: String {
    case startPairToSearchDeviceVc = "StartPairToSearchDeviceVc"
}

extension UIViewController {
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func instantiate(fromStoryboard storyboard: StoryboardIdentifiers) -> Self {
        return storyboard.viewController(viewControllerClass: self)
    }
    
    func showLoginVC() {
        let loginVC = UIStoryboard.cityListVC()
        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.modalTransitionStyle   = .crossDissolve
        self.present(loginVC, animated: true, completion: nil)
    }
}
