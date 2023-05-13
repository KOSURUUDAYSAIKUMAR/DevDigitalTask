//
//  HelpViewController.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 11/05/23.
//

import UIKit
import WebKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var helpWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            guard let filePath = Bundle.main.path(forResource: "help", ofType: "html")
            else {
                // File Error
                print ("File reading error")
                return
            }
            
            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            helpWebView.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
        // Do any additional setup after loading the view.
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
