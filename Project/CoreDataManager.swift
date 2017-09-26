//
//  CoreDataManager.swift
//  helloCoreDataManager
//
//  Created by Willy on 2017/9/7.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager<T:NSManagedObject>: NSObject,NSFetchedResultsControllerDelegate {
    
    //Constants from init
    let momdFilename:String
    let dbFilename:String
    let dbFilePathURL:URL
    let entityName:String
    let sortKey:String
    
    private var saveCompletion:SaveCompletion?
    
    init(momdFilename:String,dbFilename:String? = nil,dbFilePathURL:URL? = nil,entityName:String,sortKey:String) {
    
        self.momdFilename = momdFilename
        
        if let dbFilename = dbFilename {
            self.dbFilename = dbFilename
        }else {
            self.dbFilename = momdFilename
        }
        
        if let dbFilePathURL = dbFilePathURL {
            self.dbFilePathURL = dbFilePathURL
        }else {
            self.dbFilePathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        self.entityName = entityName
        self.sortKey = sortKey
        
        super.init()
        
    }
    
    //Mark: - Private methods/proerties.
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        
        let modelURL = Bundle.main.url(forResource: self.momdFilename, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having  added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.dbFilePathURL.appendingPathComponent(self.dbFilename + "sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    //負責根其他VC溝通的介面
    private lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Fetched results controller
    //讀取資料
    
    private var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: entityName)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController as NSFetchedResultsController<NSFetchRequestResult>
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    
    //當存擋動作執行時啟動
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //
        saveCompletion?(true)
        saveCompletion = nil //重要
    }
    
    //MARK: - Public Methods
    
    typealias SaveCompletion = (_ sucess:Bool) -> Void
    
    // MARK: - Core Data Saving support
    func saveContext (completion:SaveCompletion?) {
        if managedObjectContext.hasChanges {
            do {
                guard saveCompletion == nil else {
                    completion?(false)
                    return
                }
                
                saveCompletion = completion
        
                try managedObjectContext.save()
                
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                saveCompletion?(false)
                //在debug模式下會停止程式
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }else {
            completion?(true)
        }
    }
    //下列方法裡的code參考HelloCoreDataDemo
    func totalCount() -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![0]
        return sectionInfo.numberOfObjects
    }
    
    func createItem() -> T {
        
        let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: self.managedObjectContext)
        return newManagedObject as! T
        
    }
    
    func createItemTo(target:NSManagedObject) -> T {
        
        let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: target.managedObjectContext!)
        return newManagedObject as! T
        
    }
    
    func delete(item:T) {
        self.managedObjectContext.delete(item)
    }
    
    func fetchItemAt(index:Int) -> T? {
        
        let indexPath = IndexPath(row: index, section: 0)
        
        return self.fetchedResultsController.object(at: indexPath) as? T
    }
    
    func searchBy(keyword:String,field:String) -> [T]? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        // ==> name CONTAINS[cd] "lee"
        let predicate = NSPredicate(format: field + " CONTAINS[cd] \"\(keyword)\"")
            
            request.predicate = predicate
        
        do {
            let result = try managedObjectContext.fetch(request) as? [T]
            return result
        } catch  {
            //在debug模式下會停止程式
            assertionFailure("Fail to fetch:\(error)")
        }
        
        return nil
    }

}
