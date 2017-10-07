//
//  ViewController.swift
//  Project
//
//  Created by Willy on 2017/9/5.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class ViewController: UIViewController, UINavigationControllerDelegate{
    
// MARK: - IBOutlet
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var infoView: UIView!
    // StatusViewItem
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var upAndDowBtn: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    // InfoViewItem
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    // Constraints
    @IBOutlet weak var heightOfStatusView: NSLayoutConstraint!
    @IBOutlet weak var heightOfInfoView: NSLayoutConstraint!
    @IBOutlet weak var recBtn: UIButton!
    
// MARK: - Global Variables
    // MainMenu
    let gesture = GestureRecognizer()
    
    // locationManager Singleton
    private let locationManager = LocationManager.shared
    
    // CoreData - runManager & locationCoreDataManager
    let runManager = CoreDataManager<Run>(momdFilename: "InfoModel", entityName: "Run", sortKey: "timestamp")
    let locationCoreDataManager = CoreDataManager<Location>(momdFilename: "InfoModel", entityName: "Location", sortKey: "timestamp")
    
    
    private var second = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0.0, unit: UnitLength.meters)
    private var locationList = [CLLocation]()
    
    // 判斷變數
    var isRecording = false
    
    
    
    
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // 手勢滑動開啟 sideMenu
        gesture.turnOnMenu(target: menuButton, VCtarget: self)

        // CoreData Singleton
        usersDataManager = UsersManager.shared
        
        // 剛進到畫面的 UI 設定
        upAndDowBtn.setImage(UIImage(named:"up.png"), for: .normal)
        heightOfInfoView.constant = 0 // 80
        heightOfStatusView.constant = 0 // 30
        statusView.isHidden = true
        durationView.isHidden = true
        distanceView.isHidden = true

        // locationManger 初始定位
        self.locationManagerSetting()

        // Prepare fog
        if let fullRadius = CLLocationDistance(exactly: MKMapRectWorld.size.height) {
            mapView.add(MKCircle(center: mapView.centerCoordinate, radius: fullRadius))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
/// MARK: - IBActions
    @IBAction func userTrackingBtnPressed(_ sender: UIButton) {
        self.mapView.userTrackingMode = .followWithHeading
        locationManagerSetting()
    }
    
    @IBAction func recBtnPressed(_ sender: UIButton) {
        if isRecording == false {
            isRecording = true
            // 開始記錄
            startRec()
        } else {
            pauseRec()
        }
    }
    
    @IBAction func addBtnPressed(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "InsertStopViewController") as? InsertStopViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        addAnnotation()
    }
    
    @IBAction func upAndDownBtnPressed(_ sender: UIButton) {
        if heightOfInfoView.constant == 0 {
            heightOfInfoView.constant = 80
            UIView.animate(withDuration: 0.5, animations: {
                self.infoView.frame.origin.y += 80
                self.infoView.layoutIfNeeded()
            }, completion: { _ in
                self.durationView.isHidden = false
                self.distanceView.isHidden = false
                self.timeLabel.isHidden = false
                self.distanceLabel.isHidden = false
                
            })
            upAndDowBtn.setImage(UIImage(named:"up.png"), for: .normal)
            
        } else if heightOfInfoView.constant == 80 {
            durationView.isHidden = true
            distanceView.isHidden = true
            timeLabel.isHidden = true
            distanceLabel.isHidden = true
            self.heightOfInfoView.constant = 0
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.infoView.frame.origin.y -= 40
                self.infoView.layoutIfNeeded()
            }, completion: nil)
            upAndDowBtn.setImage(UIImage(named:"down.png"), for: .normal)
        }
    }
    
    
    // locationManager 初始設定
    func locationManagerSetting() {
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.startUpdatingLocation()
        mapView.userTrackingMode = .followWithHeading
        showCity(currentLocation: locationManager.location!)

    }
        
    
    
    private func startRec() {
        // 新增 RunItem 所以 originalItem: nil
        editRun(originalItem: nil) { (success, item) in
            guard success == true else {
                return
            }
            usersDataManager.giveRunValue(toRunItem: item!)
        }
        // UI 狀態改變
        recBtn.setImage(UIImage(named:"pause.png"), for: .normal)
        statusLabel.text = "記錄中"
        // status 動畫
        statusView.isHidden = false
        heightOfStatusView.constant = 30
        UIView.animate(withDuration: 0.5, animations: {
            self.statusView.layoutIfNeeded()
            self.statusView.frame.origin.y += 44
        }) { _ in
            self.statusView.isHidden = false
        }
        // info 動畫
        self.infoView.isHidden = false
        self.heightOfInfoView.constant = 80
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveLinear, animations: {
            self.infoView.layoutIfNeeded()
            self.infoView.frame.origin.y += 74
        }) { _ in
            self.infoView.isHidden = false
            self.durationView.isHidden = false
            self.distanceView.isHidden = false
        }

        // 設定 計時器 與 計算距離長度
        second = 0
        distance = Measurement(value: 0.0, unit: UnitLength.meters)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.eachSecond()
        })
        // 預先清空 locationList
        locationList.removeAll()
        updateDisplay()
        
    }
    
    func eachSecond() {
        second += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(second)
        distanceLabel.text = formattedDistance
        timeLabel.text = formattedTime
    }
    
    private func pauseRec() {
        timer?.invalidate()
        // 暫停警告視窗
        statusLabel.text = "暫停記錄"
        let alert = UIAlertController(title: "暫停記錄", message: "您可選擇「繼續」、「刪除」或「儲存」", preferredStyle: .alert)
        let saveBtn = UIAlertAction(title: "儲存", style: .default, handler: {_ in
            /// 儲存 軌跡資料
            /// 儲存 UI 畫面
            // 儲存軌跡資料
//            self.editRun(originalItem: nil, completion: { (success, item) in
//                guard success == true else {
//                    return
//                }
//                do{
//                    try usersDataManager.userItem?.managedObjectContext?.save()
//                } catch {
//                    let nserror = error as NSError
//
//                    assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
//                }
//            })
            // 終止記錄軌跡
            self.stopRec()
        })
        let discard = UIAlertAction(title: "刪除", style: .default, handler: { _ in
            /// delete this Run 的資料

            /// 再 清空 UI
            // 清空 locationList 與 mapView 上的記號
            self.locationList.removeAll()
            
            if self.mapView.overlays.count > 1 {
                for i in self.mapView.overlays {
                    if i is MKPolyline {
                        self.mapView.remove(i)
                    }
                }
            }
            self.mapView.removeAnnotations(self.mapView.annotations)
            // 終止記錄軌跡
            self.stopRec()
        })
        let cancelBtn = UIAlertAction(title: "繼續", style: .cancel, handler: {_ in
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {_ in
                self.statusLabel.text = "記錄中"
                self.eachSecond()
            })
        })
        alert.addAction(cancelBtn)
        alert.addAction(discard)
        alert.addAction(saveBtn)
        present(alert, animated: true, completion: nil)
    }
    
    private func stopRec() {
        // 狀態 與 UI 修正
        isRecording = false
        timeLabel.text = "00:00:00"
        distanceLabel.text = "0.0"
        recBtn.setImage(UIImage(named:"start.png"), for: .normal)
        timer?.invalidate()
        //locationManager.stopUpdatingLocation()
        locationManagerSetting()
    }
    
    private func addAnnotation() {
        guard let annotationCoordinate = locationList.last?.coordinate else {
            return
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = annotationCoordinate
        /// annotation 要算出是這次run 的第幾個index 配合 coredata 呈現 title與 image
        annotation.title = "肯德基🐔"
        annotation.subtitle = "真好吃"
        mapView.addAnnotation(annotation)
    }
    
    private func saveRec() {
        // 對 Run 儲存
        
            // 對 Location 儲存

        
    }
    
    
    // 取得目前位置的地址
    typealias CLGeocodeCompletionHandler = ([CLPlacemark]?, Error?) -> Void
    
    private func showCity(currentLocation:CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                print(firstLocation?.addressDictionary as Any)
                if let state = firstLocation?.addressDictionary!["State"] as? NSString, let city = firstLocation?.addressDictionary!["City"] as? NSString
                {
                    self.cityLabel.text = (state as String) + (city as String)
                }
            }
        })
    }
    
    
    
    //MARK: - EditRun
    typealias EditDoneHandler = (_ success:Bool,_ resultItem:Run?) -> Void
    
    func editRun(originalItem:Run?,completion:@escaping EditDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            //把Run存在與Users同一個context里
            finalItem = runManager.createItemTo(target: usersDataManager.userItem!)
            finalItem?.timestamp = NSDate() as Date
            usersDataManager.userItem?.addToRuns(finalItem!)
        }
        if let runName = cityLabel.text {
            finalItem?.runname = runName
        }
        if let city = cityLabel.text {
            finalItem?.city = city
        }
        
        if let duration = Int(timeLabel.text!) {
            finalItem?.duration = Int16(duration)
        }
        if let distance = Double(distanceLabel.text!) {
            finalItem?.distance = distance
        }
        completion(true,finalItem)
    }
    
    
    typealias EditLocationDoneHandler = (_ success:Bool,_ resultItem:Location?) -> Void
    func editLocation(originalItem:Location?,completion:@escaping EditLocationDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            finalItem = locationCoreDataManager.createItemTo(target: usersDataManager.runItem!)
            finalItem?.timestamp = NSDate() as Date
            usersDataManager.runItem?.addToLocations(finalItem!)
        }
        
        if locationList.count != 0 {
            for everyLocation in locationList {
                if let latitude = everyLocation.coordinate.latitude as? Double {
                    finalItem?.latitude = latitude
                }
                if let longitude = everyLocation.coordinate.longitude as? Double {
                    finalItem?.longitude = longitude
                }
            }
        }
        completion(true, finalItem)
    }
    
    
    
    
    
    
    /// END
}


extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate  {
    
    // MARK: - CLLocationManagerDelegate Method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isRecording == false {
            guard let currentLocation = locations.last else {
                return
            }
            let coordinate = currentLocation.coordinate
            // NSLog("Lat:\(coordinate.latitude),Lon:\(coordinate.longitude)")
            
            // GCD of DispatchQueue
            DispatchQueue.once(token: "MoveAndZoomMap") {
                let span = MKCoordinateSpanMake(0.009, 0.009);
                let region = MKCoordinateRegion(center: coordinate, span: span);
                mapView.setRegion(region, animated: true);
            }
        } else {
            for newLocation in locations {
                let howRecent = newLocation.timestamp.timeIntervalSinceNow
                 //準確度校正
                guard abs(howRecent) < 10 && newLocation.horizontalAccuracy < 20 else {
                    return
                }
                if let lastLocation = locationList.last {
                    // 計算距離差
                    let delta = newLocation.distance(from: lastLocation)
                    distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                    //guard delta
                    
                    // 在 最後一個點 與 新點 繪製路線
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(lastLocation.coordinate)
                    coords.append(newLocation.coordinate)
                    mapView.add(MKPolyline(coordinates: coords, count: coords.count))
                    // 設定 regiopn
                    let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
                }
                showCity(currentLocation: locationList.last!)
                locationList.append(newLocation)
                
                /// editLocation
                editLocation(originalItem: nil, completion: { (success, item) in
                    guard success == true else {
                        return
                    }
                    do {
                        try usersDataManager.runItem?.managedObjectContext?.save()
                    } catch {
                        let error = error as NSError
                        assertionFailure("save")
                    }
                    
                })
                print(usersDataManager.runItem?.locations?.count)
                
            }
        }
    }
    
    
    // MARK: - MKMapViewDelegate Method
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKCircle {
            let view = MKCircleRenderer(overlay: overlay)
            view.fillColor = UIColor.white.withAlphaComponent(0.2)
            return view
        }
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor(red: 0, green: 0.83, blue: 0.61, alpha: 1)
        renderer.lineWidth = 10
        return renderer
    }
   
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            return nil
        }
        let identifier = "Stop"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if result == nil {
            result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }else{
            result?.annotation = annotation
        }
        result?.canShowCallout = true
        let image = UIImage(named:"Annotation.png")
        result?.image = image
        
        
        // 針對 callOut 作格式調整
        let imageView = UIImageView(image:image)
        result?.leftCalloutAccessoryView = imageView
        
        // Prepare RightCalloutAccessoryView
        let button = UIButton(type: .detailDisclosure)
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        result?.rightCalloutAccessoryView = button
        return result
    }
    @objc func buttonTapped(sender:Any) {
        NSLog("buttonTapped!")
    }
    
    
}





