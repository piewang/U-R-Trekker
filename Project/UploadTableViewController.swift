//
//  UploadTableViewController.swift
//  Project
//
//  Created by Champion on 2017/10/13.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit
import Firebase

class UploadTableViewController: UITableViewController {
    
    var firebaseTimeArray = [String]()
    let formatter = DateFormatter()
    var dateString:String?
    let alert = AlertSetting()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // #warning Incomplete implementation, return the number of rows
        return (usersDataManager.userItem?.runs?.count ?? 0)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UITableViewCell
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateString = formatter.string(from: (usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run).timestamp!)
        cell.textLabel?.text = dateString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //...
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
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //要上傳的檔案
        let record = usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run
        let annotationsRecord = record.annotations?.allObjects
        let locationsRecord = record.locations?.allObjects

        //型別轉換
        var annotationDict = ["imageData":"",
                              "text":""]
        var annotationArray = [NSDictionary]()
        var locationArray = [NSDictionary]()
        
        //轉換annotation
        guard let annotationTotals = annotationsRecord?.count else {
            return nil
        }
        for num in 0..<annotationTotals {
            if let items = annotationsRecord {
                var item = items[num] as! Annotation
                let imgPic = UIImage(data: item.imageData!)
                let imgNSData = UIImageJPEGRepresentation(imgPic!, 0.9)
                let imgString =  imgNSData?.base64EncodedString(options: .lineLength64Characters)
                annotationDict["imageData"] = imgString
                annotationDict["text"] = item.text
                annotationArray.append(annotationDict as NSDictionary)
            }
        }
        
        //把coredata資料打包成JSON
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateString = formatter.string(from: record.timestamp!)
        
        let parameters:[String:Any] = [
            "city":record.city,
            "distance":record.distance,
            "duration":record.duration,
            "runname":record.runname,
            "timestamp":dateString,
            "annotations":annotationArray,
//            "locations":locationString
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else{
            return nil
        }
        
        let upload = UITableViewRowAction(style: .normal, title: "上傳") { action, index in
            //上傳中通知視窗
            self.alert.displayActivityIndicator(target: self, title: "上傳中\n")
            let databaseRef = Database.database().reference().child("users").child(uuid!).child("record").child(self.dateString!)
            let storageRef = Storage.storage().reference().child(uuid!).child(self.dateString!)
            let uploadtask = storageRef.putData(data, metadata: nil)
            uploadtask.observe(.success){(snapshot) in
                guard let displayName = Auth.auth().currentUser?.displayName else{
                    return
                }
                
                //database的參照
                if let dataURL = snapshot.metadata?.downloadURL()?.absoluteString{
                    let post: [String:Any] = ["data": dataURL]
                    databaseRef.setValue(post)
                }
                
                    alertController?.dismiss(animated: true, completion: nil)
                    let alert = UIAlertController(title: "資料備份成功!", message: nil, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                
            }
            
            
        }
        upload.backgroundColor = UIColor.lightGray
        return [upload]
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
