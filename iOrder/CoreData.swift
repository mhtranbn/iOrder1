//
//  CoreData.swift
//  iOrder
//
//  Created by mhtran on 5/7/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import Foundation
import CoreData

class CoreData {
    let model = "iOrder"
    
     lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        return urls[urls.count - 1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.model, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
     lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.model)
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true]
            
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,configuration: nil, URL: url, options: options)
        }
        catch {
            fatalError("Error adding persistence store")
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType:.MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
        
    }()
    
    // Save Context Func
    
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            }
            catch {
                print("Error saving context")
                abort()
            }
        }
    }
    
    func deleteCoreData(fetchRequest: NSFetchRequest) {
        do {
            let coreData = CoreData()
            managedObjectContext = coreData.managedObjectContext
            let objects = try managedObjectContext.executeFetchRequest(fetchRequest)
            for object in objects as! [NSManagedObject] {
                managedObjectContext.deleteObject(object)
                try managedObjectContext.save()
            }
        } catch {
            fatalError("Error excuteFetchRequewst")
        }
    }
}