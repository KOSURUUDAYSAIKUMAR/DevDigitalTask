//
//  Persitance.swift
//  DevDigitalTask
//
//  Created by KOSURU UDAY SAIKUMAR on 12/05/23.
//

import UIKit
import CoreData

class Persitance: NSObject {
    var shared = Persitance()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Dev.CoreData.modelName)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
