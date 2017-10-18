//
//  DownloadTableViewController.swift
//  Project
//
//  Created by Champion on 2017/10/13.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit
import Firebase

class DownloadTableViewController: UITableViewController {
    
    var downloadData: [String:NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let databaseRef = Database.database().reference().child("users").child(uuid!).child("record")
        databaseRef.observe(.value, with: { (snapshot) in
            if let downloadDict = snapshot.value as? [String:NSDictionary] {
                self.downloadData = downloadDict
                self.tableView!.reloadData()
            }
            print(self.downloadData)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataDic = downloadData {
            return dataDic.count
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let dataDic = downloadData {
            var keyArray = Array(dataDic.keys)
            let dateString = keyArray[indexPath.row]
            print(dateString)
            cell.textLabel?.text = dateString
        }
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let download = UITableViewRowAction(style: .normal, title: "下載") { action, index in
            if let dataDict = self.downloadData {
                var keyArray = Array(dataDict.keys)
                let dataURL = dataDict[keyArray[indexPath.row]]!["data"] as! String
                print("下載位置====>\(dataURL)")
                if let downloadUrl = URL(string: dataURL) {
                    
                    URLSession.shared.dataTask(with: downloadUrl, completionHandler: { (data, response, error) in
                        
                        if error != nil {
                            print("Download Image Task Fail: \(error!.localizedDescription)")
                        }
                        else if let downladData = data {
                            //解析下載回來的檔案
                            DispatchQueue.main.async {
                                guard let response = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) else {
                                    return
                                }
                                
                                let responseDict = response as! NSDictionary
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                let timeStamp = responseDict["timestamp"] as! String
                                
                                //存取下載回來的檔案
                                typealias EditDoneHandler = (_ success:Bool,_ resultItem:Run?) -> Void
                                let runManager = CoreDataManager<Run>(momdFilename: "InfoModel", entityName: "Run", sortKey: "timestamp")
                                
                                func editRun(originalItem:Run?,completion:@escaping EditDoneHandler) {
                                    var finalItem = originalItem
                                    if finalItem == nil {
                                        //把Run存在與Users同一個context里
                                        finalItem = runManager.createItemTo(target: usersDataManager.userItem!)
                                        finalItem?.timestamp = dateFormatter.date(from: timeStamp)
                                        usersDataManager.userItem?.addToRuns(finalItem!)
                                    }
                                    if let runName = responseDict["runname"] {
                                        finalItem?.runname = runName as! String
                                    }
                                    if let city = responseDict["city"] {
                                        finalItem?.city = city as! String
                                    }
                                    if let duration = responseDict["duration"] {
                                        finalItem?.duration = duration as! String
                                    }
                                    if let distance = responseDict["distance"] {
                                        finalItem?.distance = distance as! String
                                    }
                                    completion(true,finalItem)
                                }
                                
                                editRun(originalItem: usersDataManager.runItem, completion: { (success, item) in
                                    guard success == true else {
                                        return
                                    }
                                    do {
                                        
                                        try usersDataManager.runItem?.managedObjectContext?.save()
                                        try usersDataManager.userItem?.managedObjectContext?.save()
                                        usersDataManager.giveRunValue(toRunItem: item!)
                                    } catch {
                                        let error = error as NSError
                                        assertionFailure("Unresolve error\(error)")
                                    }
                                })
                                
                                
                                
                                typealias EditAnnotationDoneHandler = (_ success:Bool, _ resultItem:Annotation?) -> Void
                                
                                let annotationManager = CoreDataManager<Annotation>(momdFilename: "InfoModel", entityName: "Annotation", sortKey: "timestamp")
                                let annotation:[NSDictionary] = responseDict["annotations"] as! [NSDictionary]
                                
                                //存取annotation
                                func editAnnotation(originalItem: Annotation?, index:Int, completion: EditAnnotationDoneHandler) {
                                    var finalItem = originalItem
                                    
                                    if finalItem == nil {
                                        finalItem = annotationManager.createItemTo(target: usersDataManager.runItem!)
                                        finalItem?.timestamp = dateFormatter.date(from: timeStamp)
                                        usersDataManager.runItem?.addToAnnotations(finalItem!)
                                    }
                                    
                                    if let text = annotation[index]["text"] {
                                        finalItem?.text = text as! String
                                        print(finalItem?.text)
                                    }
                                    //解碼string轉換成data存入coredata
                                    let imageString = annotation[index]["imageData"] as! String
                                    let imgDecoded:Data = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters)!
//                                    let imageToUIImage = UIImage(data: imgDecoded as Data)
//                                    let imgSaved = UIImageJPEGRepresentation(imageToUIImage!, 1.0)
                                    finalItem?.imageData = imgDecoded
                                    usersDataManager.giveValue(toAnnotationItem: finalItem!)
                                }
                                
                                for i in 0...annotation.count-1 {
                                    editAnnotation(originalItem: nil, index: i) { (success, item) in
                                        guard success == true else {
                                            return
                                        }
                                        do {
                                            try usersDataManager.annotationItem?.managedObjectContext?.save()
                                            try usersDataManager.runItem?.managedObjectContext?.save()
                                            try usersDataManager.userItem?.managedObjectContext?.save()
                                        } catch {
                                            let error = error as NSError
                                            assertionFailure("Unresolve error\(error)")
                                        }
                                    }
                                }
                                
                                
                                
                            }
                            
                        }
                        
                    }).resume()
                }
            }
        }
        download.backgroundColor = UIColor.lightGray
        return [download]
    }
    
}
