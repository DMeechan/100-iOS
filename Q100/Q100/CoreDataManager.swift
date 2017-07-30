//
//  CoreDataManager.swift
//  Q100
//
//  Created by Daniel Meechan on 19/07/2017.
//  Copyright © 2017 Rogue Studios. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataManager {
  
  // MARK: - Properties
  
  private let modelName: String
  
  // MARK: - Initialization
  
  init(modelName: String) {
    self.modelName = modelName
  }
  
  // MARK: - Core Data Stack
  
  private(set) lazy var managedObjectContextL: NSManagedObjectContext = {
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    
    return managedObjectContext
    
  }()
  
  privte lazy var persisitentStoreCoordinator: NSPersistentStoreCoordinator = {
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    
    let fileManager = fileManager.default
    let storeName = "\(self.modelName).sqlite"
    
    let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
    
    do {
      try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                        configurationName: nil,
                                                        at: persistentStoreURL,
                                                        options: nil)
    } catch {
      fatalError("Unable to Load Persistent Store")
    }
    
    return persistentStoreCoordinator
    
  }
  
}
