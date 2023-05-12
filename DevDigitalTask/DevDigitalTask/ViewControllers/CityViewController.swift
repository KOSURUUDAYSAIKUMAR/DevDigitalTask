//
//  CityViewController.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit
import CoreData

class CityViewController: UIViewController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigateList()
//        performSegue(withIdentifier: "list", sender: nil)
        
//        let appComponents = AppComponents(UserDefaultsManager.ColorTheme.getCurrentColorTheme())
//        let rootViewController = CityListViewController(appComponents: appComponents)
//        rootViewController.dataStorage = WeatherCoreDataManager(managedContext: persistentContainer.newBackgroundContext())
//        present(rootViewController, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = CityListViewController()
//        rootViewController.dataStorage = WeatherCoreDataManager(managedContext: persistentContainer.newBackgroundContext())
        present(rootViewController, animated: true)
        
        // Do any additional setup after loading the view.
    }
    
    func navigateList() {
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       guard let viewController = storyboard.instantiateViewController(
            identifier: "CityListViewController",
            creator: { coder in
                 CityListViewController()
            }
       ) as? CityListViewController else {
           return
       }
        //Then you do what you want with the view controller.
        present(viewController, animated: true)
        
        
//        let rootViewController = CityListViewController(appComponents: appComponents)
//        rootViewController.dataStorage = WeatherCoreDataManager(managedContext: persistentContainer.newBackgroundContext())
//        let navigationController = UINavigationController(rootViewController: rootViewController)
//        navigationController.navigationBar.barStyle = .black
//        let window = UIWindow(frame: UIScreen.main.bounds)
//       window.rootViewController = navigationController
//       window.makeKeyAndVisible()
//       self.window = window
    }
    
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
