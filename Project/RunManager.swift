//
//  RunManager.swift
//  Project
//
//  Created by pie wang on 2017/10/2.
//  Copyright © 2017年 Willy. All rights reserved.
//

import Foundation
import CoreData

/// 1.
// 可設計 Singleton: 跨 VC 去共享
/// 但有可能一個專案用不只一個 coreData 資料庫
// 以下說明 不用 singleton 但可以跨 VC 使用:
// 若 cm1 想要跨 vc 使用，可創造一個 子model 去繼承cm 並定成 singleton。
/// 5.
// 加入 protocol
/// 15. 加入支援泛型
// 指定 coreDataManager 可以支援任何「支援 NSManagedObject 型別」的物件
class RunDataManager <T: NSManagedObject> : NSObject, NSFetchedResultsControllerDelegate {
    
    // Constants from init
    let momdFilename: String
    let dbFilename: String
    let dbFilePathURL: URL
    let entityName: String
    let sortKey: String
    
    /// 19.2
    // 為了要跨 func 保留這個閉包參數
    private var saveCompletion: SaveCompletion?
    
    // 建構式
    init(momdFilename:String,
         dbFilename:String? = nil,
         dbFilePathURL: URL? = nil,
         entityName: String,
         sortKey:String)
    {
        self.momdFilename = momdFilename
        
        if let dbFilename = dbFilename {
            self.dbFilename = dbFilename
        } else {
            self.dbFilename = momdFilename
        }
        
        if let dbFilePathURL = dbFilePathURL {
            self.dbFilePathURL = dbFilePathURL
        } else {
            self.dbFilePathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        self.entityName = entityName
        self.sortKey = sortKey
        super.init()
    }
    
    // MARK: - Private method
    /// 資料模型
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        /// 3.1
        // 修改 for Resourse
        // 模型 sourseCode 副檔名為 xcdatamodeld ，但 apple 會把它轉成 momd 檔案
        let modelURL = Bundle.main.url(forResource: self.momdFilename, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        /// 3.2
        // 創造自己
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel) /// 創造時需要 managedObjectModel，如果為首次用到，則會透過 bundle 創造出來
        
        // 修改路徑 保留副檔名 sqlite
        let url = self.dbFilePathURL.appendingPathComponent(self.dbFilename + ".sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            /// 3.3
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // 出錯時候的東西....
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    
    /// 3.4
    private lazy var managedObjectContext: NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        
        // concurrencyType 平行處理的方法 預設為 mainQueue
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    
    
    
    
    
    /// 6.
    // MARK: - Fetched results controller
    private var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        /// 如果從來都沒創造過 ...
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        // Edit the entity name as appropriate.
        /// 6.1
        // 修改 entityName
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)
        fetchRequest.entity = entity
        
        
        fetchRequest.fetchBatchSize = 20
        
        /// 6.2
        // 修改排序 key
        let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        /// 6.3
        // 修改 cacheName
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: entityName)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController as NSFetchedResultsController<NSFetchRequestResult>
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            
            abort()
        }
        
        return _fetchedResultsController!
    }
    
    /// 7.
    // 當存擋工作沒有出現異常 方法就會被觸發
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        ///.. 存擋完成 配合更新 ui 時執行
        /// 20.
        saveCompletion?(true)
        // 任務完成 要釋放
        saveCompletion = nil    /// Important!!
        
        
    }
    
    
    
    // MARK: Public method
    /// 19.
    // 未來檔案資料量可能會變大，儲存可能會需要時間處理，不適合 saveContext 馬上接 reloadData
    // 這個型別設計 是為了可以帶入 這個 SaveCompletion 閉包
    // 閉包寫法 不吃東西也不吐東西
    typealias SaveCompletion = (_ success: Bool) -> Void
    
    /// 4.
    // MARK: - Core Data Saving support
    /// 19.1 增加參數
    func saveContext (completion: SaveCompletion?) {
        if managedObjectContext.hasChanges {
            do {
                /// 20.
                // Check if we are under saving process.
                guard saveCompletion == nil else {
                    completion?(false)
                    return
                }
                
                /// 19.4
                saveCompletion = completion
                try managedObjectContext.save()
            } catch {
                
                let nserror = error as NSError
                //NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                /// 19.5
                saveCompletion?(false)     /// report there is an error
                ///25.2
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
                //abort()
            }
            /// 19.3
            // 檢查 managedObjectContext 是否改變
            // 如果沒有改變 就....
        } else {
            completion?(true)
        }
    }
    
    
    /// 8.
    // 若需要 return 的 先以假資料代替
    // 總數
    func totalCount() -> Int {
        /// 8.1 copy
        // 一維一個 section
        let sectionInfo = self.fetchedResultsController.sections![0]
        return sectionInfo.numberOfObjects
    }
    // 新增
    func creatItem() -> T {
        
        /// 8.2 copy
        // 透過 fetchedResultsController 拿到 context 與 entity
        // 但是 我們在上面已經完成 context 與 entityName 等資料 因此 前兩行多餘可省略
        // let context = self.fetchedResultsController.managedObjectContext
        // let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: self.entityName, into: self.managedObjectContext)
        
        return newManagedObject as! T
    }
    // 刪除
    /// 15.2 泛型調整
    func deleteItem(item: T) {
        /// 8.3 no copy
        self.managedObjectContext.delete(item)
        
    }
    // 讀取
    // 在讀取時候加以修改，可能就會被儲存，所以唔需要多一個 func
    // 設為可選型別，因為有可能不存在
    /// 15.3 泛型調整
    func fetchItem(index: Int) -> T? {
        /// 8.4 copy
        // 自己刻 indexPath
        let indexPath = IndexPath(row: index, section: 0)
        // object 會 return 一個範型類別 因可強迫轉型
        return self.fetchedResultsController.object(at: indexPath) as? T
    }
    // 搜尋
    // 設為可選型別，因為有可能不存在
    func searchBy(keyword:String, field:String) -> [T]? {
        /// 24.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        // predicate 特殊語法
        // ==> name CONTAINS[cd]"Lee"
        let predicate = NSPredicate(format: field + " CONTAINS[cd] \" \(keyword) \"")
        request.predicate = predicate
        
        do{
            let results = try managedObjectContext.fetch(request) as? [T]
            return results
        } catch {
            // 它比 NSLog 更好用 => 如果程式到這裡，在debug版時會當機
            /// 25.1
            assertionFailure("Fail to fetch: \(error)")
        }
        return nil
    }
    
    
    
    
    
    /// property 說明：
    // private: 私有 這個類別可以用，其他類別不能用
    // private(set): 唯讀
    // fileprivate: 私有 是針對至個 swift file 可以用，妻他 swift file 就不能用
    // internal: 內部使用 只有這個程式模組可以使用
    // open: 表示子類別可以改寫 override，通常用在 func
    // static: 會在 app 一開始啟動就開啟一個記憶體空間給他
}

