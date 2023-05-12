//
//  CityViewController.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit
import CoreData

class CityViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        let appComponents = AppComponents(UserDefaultsManager.ColorTheme.getCurrentColorTheme())
        
        let rootViewController = MainMenuViewController(appComponents: appComponents)
        rootViewController.dataStorage = WeatherCoreDataManager(managedContext: persistentContainer.newBackgroundContext())
        present(rootViewController, animated: true)
        // Do any additional setup after loading the view.
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Dev.CoreData.modelName)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
