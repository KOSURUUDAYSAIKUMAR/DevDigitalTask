//
//  CoreDataTests.swift
//  CoreDataTests
//
//  Created by KOSURU UDAY SAIKUMAR on 15/05/23.
//

import XCTest
import CoreData
@testable import DevDigitalTask

enum StorageType {
  case persistent, inMemory
}

final class CoreDataTests: XCTestCase {

    lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")

//        guard let modelURL = Bundle(for: type(of: self))
//                .url(forResource: Dev.CoreData.modelName, withExtension: "xcdatamodeld") else {
//                fatalError("Error loading model from bundle")
//        }
//        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
//            fatalError("Error initializing mom from: \(modelURL)")
//        }
//        let container = NSPersistentContainer(name: Dev.CoreData.modelName, managedObjectModel: mom)
        
        let container = NSPersistentContainer(name: Dev.CoreData.modelName)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var testCoreManager: WeatherCoreDataManager?
    
    override func setUp() {
        let context = persistentContainer.newBackgroundContext()
        testCoreManager = WeatherCoreDataManager(managedContext: context)
    }

    func testDeleteItem() {
        // arrange
        let cityToDelete = SavedCity(name: "CityToDelete",
                                     latitude: 17.737265482417016,
                                     longitude: 83.28873471540155)
        testCoreManager?.addNewItem(cityToDelete.name,
                        lat: cityToDelete.latitude,
                        long: cityToDelete.longitude)
        // act
        testCoreManager?.deleteItem(at: 0)
        guard let result = testCoreManager?.getSavedItems else {
            XCTFail("testDeleteItem failed")
            return
        }
        // assert
        XCTAssertEqual(result.count, 0)
    }

    func testAddNewItem() {
        // arrange
        testCoreManager?.addNewItem("Visakhapatnam", lat: 17.737265482417016, long: 83.28873471540155)
        // act
        let result = testCoreManager?.getSavedItems
        print(result ?? "Source undefined")
        // assert
        XCTAssertNotNil(result)
    }

    func testGetManagedObjects() {
        // arrange
        for iterator in 0...5 {
            testCoreManager?.addNewItem("TestCity",
                            lat: Double(iterator),
                            long: Double(iterator))
        }
        // act
        guard let savedCities = testCoreManager?.getSavedItems else {
            XCTFail("testGetManagedObjects failed")
            return
        }
        // assert
        XCTAssertEqual(savedCities.count, 6)
    }

    func testDeleteAll() {
        // arrange
        for iterator in 0...10 {
            testCoreManager?.addNewItem("TestCity",
                            lat: Double(iterator),
                            long: Double(iterator))
        }
        // act
        testCoreManager?.deleteAll()
        guard let result = testCoreManager?.getSavedItems else {
            XCTFail("testDeleteAll failed")
            return
        }
        // assert
        XCTAssertEqual(result.count, 0)
    }
    
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        testCoreManager = nil
    }

}
