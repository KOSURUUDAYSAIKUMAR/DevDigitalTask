//
//  TabBarControllerViewController.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 12/05/23.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
      
        // Tab 1
        let tab = TempViewController(nibName: "Main", bundle: nil)
        let navigationController = UINavigationController(rootViewController: tab)
        let tabBar = UITabBarItem(title: "Home", image: UIImage(named: "homeTab"), tag: 0)
        tab.tabBarItem = tabBar
        
        // Tab 2
        let cityTab = CityViewController(nibName: "Main", bundle: nil)
        let cityTabBar = UITabBarItem(title: "City", image: UIImage(named: "citytab"), tag: 1)
        cityTab.tabBarItem = cityTabBar
        
        // Tab 3
        let helpTab = HelpViewController(nibName: "Main", bundle: nil)
        let helpTabBar = UITabBarItem(title: "Help", image: UIImage(named: "helptab"), tag: 2)
        helpTab.tabBarItem = helpTabBar
        let controllers = [tab, cityTab, helpTab]
        self.viewControllers =  controllers //.map { UINavigationController(rootViewController: $0)}
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected \(viewController.title!)")
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
