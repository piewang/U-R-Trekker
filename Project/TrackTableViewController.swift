//
//  TrackTableViewController.swift
//  Project
//
//  Created by Champion on 2017/10/12.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit
import CoreLocation

extension TrackTableViewController: UISearchResultsUpdating {
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            var searchString: String? = searchController.searchBar.text
            if (searchString != nil){
                //判斷裡面有沒有字
//                var p = NSPredicate(format: "SELF CONTAINS[cd] %@", searchString!)
//                //上面property增加陣列搜尋後的結果
//                searchResult = notes?.filter({ (<#String#>) -> Bool in
//                    <#code#>
//                })
            }
            else {
                searchResult = nil
            }
        }
        else {
            searchResult = nil
        }
        tableView.reloadData()
    }
}

class TrackTableViewController: UITableViewController {
    let searchController = UISearchController(searchResultsController: nil)
    let gesture = GestureRecognizer()
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var searchResult:[String]?
    var notes:[String]?
    let formatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gesture.turnOnMenu(target: menuButton, VCtarget: self)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        var rect: CGRect = searchController.searchBar.frame
        rect.size.height = 44.0
        searchController.searchBar.frame = rect
        searchController.searchBar.placeholder = "輸入關鍵字"
        self.tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        self.tableView.rowHeight = 128.0
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TrackTableViewCell
        cell.imgView?.image = UIImage(data: ((usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run).annotations?.allObjects.first as! Annotation).imageData!)
        cell.runName?.text = (usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run).runname
//        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.date?.text = formatter.string(from: (usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run).timestamp!)
        if let cityName = (usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run).city{
            cell.location?.text = "地點:\(cityName)"
        }
     return cell
     }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc2 = storyboard?.instantiateViewController(withIdentifier: "MyRecordedViewController") as! MyRecordedViewController
        if let cityLabel =  (usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run).city{
            vc2.city = cityLabel
        }
        //singleton
//        let run = usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run
//        usersDataManager.giveRunValue(toRunItem: run)
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        vc2.runDate = formatter.string(from: (usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run).timestamp!)
        //傳送Annotation
        var annotation = [Annotation]()
        guard let totals = (usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run).annotations?.allObjects.count else {
            return
        }
        guard totals != 0 else {
            return
        }
        let total = totals - 1
        for num in 0...total{
            if let items = (usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run).annotations?.allObjects {
                let item = items[num] as! Annotation
                annotation.append(item)
            }
        }
        vc2.annotation = annotation
        //傳送CLLocation
        vc2.run = (usersDataManager.userItem?.runs?.allObjects[indexPath.row] as! Run)
        navigationController?.pushViewController(vc2, animated: true)
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
