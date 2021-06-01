//
//  TestCoreDataStack.swift
//  CampgroundManagerTests
//
//  Created by Lê Cảnh Phong on 01/06/2021.
//  Copyright © 2021 Razeware. All rights reserved.
//

import Foundation
import  CampgroundManager
import CoreData

class TestCoreDataStack: CoreDataStack {
  override init() {
    super.init()
    let persistentStoreDescription = NSPersistentStoreDescription()
    persistentStoreDescription.type = NSInMemoryStoreType
    
    let container = NSPersistentContainer(name: CoreDataStack.modelName, managedObjectModel: CoreDataStack.model)
    container.persistentStoreDescriptions = [persistentStoreDescription]
    
    container.loadPersistentStores { (_, error) in
      if let error = error as NSError? {
              fatalError(
                "Unresolved error \(error), \(error.userInfo)")
      }
    }
    self.storeContainer = storeContainer
  }
}
