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
    //MARK: - Deinit
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
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
    @IBOutlet weak var addBtn: UIButton!
    
// MARK: - Global Variables
    let locationManager = CLLocationManager()
    // MainMenu
    let gesture = GestureRecognizer()
    // CoreData - runManager & locationCoreDataManager
    let runManager = CoreDataManager<Run>(momdFilename: "InfoModel", entityName: "Run", sortKey: "runname")
    let locationCoreDataManager = CoreDataManager<Location>(momdFilename: "InfoModel", entityName: "Location", sortKey: "timestamp")
    var annotationManager:CoreDataManager? = nil
    private var second = 0
    var timer: Timer?
    private var distance = Measurement(value: 0.0, unit: UnitLength.meters)
    private var locationList = [CLLocation]()
    var isRecording = false
    var finalTime:String? = nil
    var finalDistance:String? = nil
    var finalRunName:String? = nil
    let dateformatter = DateFormatter()
    
// MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // 手勢滑動開啟 sideMenu
        gesture.turnOnMenu(target: menuButton, VCtarget: self)

        // 剛進到畫面的 UI 設定
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        upAndDowBtn.setImage(UIImage(named:"up.png"), for: .normal)
        heightOfInfoView.constant = 0 // 80
        heightOfStatusView.constant = 0 // 30
        statusView.isHidden = true
        durationView.isHidden = true
        distanceView.isHidden = true
        addBtn.isEnabled = false
        // Prepare fog
        if let fullRadius = CLLocationDistance(exactly: MKMapRectWorld.size.height) {
            mapView.add(MKCircle(center: mapView.centerCoordinate, radius: fullRadius))
        }
        NotificationCenter.default.addObserver(self, selector: #selector(addAnnotation), name: NSNotification.Name(rawValue:"addAnnotation"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        // locationManger 初始定位
        locationManagerSetting()
    }
    // MARK: - IBActions
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
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "InsertStopViewController") as? InsertStopViewController else {
            return
        }
        vc.latitude = locationManager.location?.coordinate.latitude
        vc.longitude = locationManager.location?.coordinate.longitude
        NSLog("\(vc.latitude ?? 0.0), \(vc.longitude ?? 0.0)")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func upAndDownBtnPressed(_ sender: UIButton) {
        infoUpAndDown()
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
        guard let location = locationManager.location else {
            return
        }
        showCity(currentLocation: location)
    }
        
    func startRec() {
        // 新增 RunItem 所以 originalItem: nil
        addBtn.isEnabled = true
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
        navigationItem.leftBarButtonItem?.isEnabled = false
        heightOfStatusView.constant = 30
        UIView.animate(withDuration: 0.5, animations: {
            self.statusView.layoutIfNeeded()
            self.statusView.frame.origin.y += 44
        }) { _ in
            self.statusView.isHidden = false
        }
        infoUpAndDown()
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
    // 時間顯示與距離顯示更新
    func eachSecond() {
        second += 1
        updateDisplay()
    }
    private func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(second)
        distanceLabel.text = formattedDistance
        timeLabel.text = formattedTime
        finalTime = formattedTime
        finalDistance = formattedDistance
    }
    // 暫停記錄
    private func pauseRec() {
        timer?.invalidate()
        statusLabel.text = "暫停記錄"
        updateDisplay()
        pauseAlert()
        NSLog("Time: \(String(describing: timeLabel.text)), Distance: \(String(describing: distanceLabel.text))")
    }
    
    func pauseAlert() {
        let alert = UIAlertController(title: "暫停記錄", message: "您可選擇「繼續」、「儲存」或「刪除」", preferredStyle: .alert)
        let saveBtn = UIAlertAction(title: "儲存", style: .default) { _ in
            self.editRunNameAlert()
        }
        let discardBtn = UIAlertAction(title: "刪除", style: .destructive) {_ in
            usersDataManager.userItem?.removeFromRuns(usersDataManager.runItem!)
            self.stopRec()
            self.infoUpAndDown()
            self.statusLabel.text = "已刪除"
            NSLog("\(String(describing: usersDataManager.userItem?.name))有\(String(describing: usersDataManager.userItem?.runs?.count))次軌跡記錄")
        }
        
        let keepRecordingBtn = UIAlertAction(title: "繼續", style:.default) { _ in
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
                self.statusLabel.text = "記錄中"
                self.eachSecond()
            })
        }
        alert.addAction(keepRecordingBtn)
        alert.addAction(saveBtn)
        alert.addAction(discardBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    func editRunNameAlert() {
        let alert = UIAlertController(title: "記錄命名", message: "您可以為本次記錄新增名稱，或直接以記錄日期命名", preferredStyle: .alert)
        alert.addTextField { (tf) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            tf.placeholder = dateFormatter.string(from: (usersDataManager.runItem?.timestamp)!)
        }
        let ok = UIAlertAction(title: "確定", style: .default) { _ in
            if alert.textFields?.first?.text?.isEmpty == true {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                self.finalRunName = dateFormatter.string(from: (usersDataManager.runItem?.timestamp)!)
            } else {
                self.finalRunName = alert.textFields?.first?.text
            }
            
            self.editRun(originalItem: usersDataManager.runItem, completion: { (success, item) in
                guard success == true else {
                    return
                }
                do {
                    try usersDataManager.runItem?.managedObjectContext?.save()
                    try usersDataManager.userItem?.managedObjectContext?.save()
                } catch {
                    let error = error as NSError
                    assertionFailure("Unresolve error\(error)")
                }
                NSLog("RunName: \(String(describing: usersDataManager.runItem?.runname)),\n Duration: \(String(describing: usersDataManager.runItem?.duration)),\n Distance: \(String(describing: usersDataManager.runItem?.distance)),\n CreateDate: \(String(describing: usersDataManager.runItem?.timestamp))")
                NSLog("\(String(describing: usersDataManager.userItem?.name))有\(String(describing: usersDataManager.userItem?.runs?.count))次軌跡記錄")
                self.stopRec()
                self.infoUpAndDown()
                self.statusLabel.text = "已儲存"
                var times = [String]()
                let runArray = usersDataManager.userItem?.runs?.allObjects as![Run]
                guard runArray.count != 0 else {
                    return
                }
                for aRun in runArray {
                    if let time = aRun.duration {
                        times.append(time)
                    }
                    NSLog("\(times)")
                }
            })
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func stopRec() {
        // 狀態 與 UI 修正
        addBtn.isEnabled = false
        isRecording = false
        timeLabel.text = "00:00:00"
        distanceLabel.text = "0.0"
        recBtn.setImage(UIImage(named:"start.png"), for: .normal)
        navigationItem.leftBarButtonItem?.isEnabled = true
        timer?.invalidate()
        if self.mapView.annotations.count > 0{
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        if self.mapView.overlays.count > 1 {
            for i in self.mapView.overlays {
                if i is MKPolyline {
                    self.mapView.remove(i)
                }
            }
        }
        
        locationManagerSetting()
    }

    @objc private func addAnnotation() {
        
        if usersDataManager.runItem?.annotations?.count != 0 {
            
            let annotationLati = (usersDataManager.runItem?.annotations?.allObjects.last as! Annotation).latitude
            let annotationLongi = (usersDataManager.runItem?.annotations?.allObjects.last as! Annotation).longitude
            let annotationCoordinate = CLLocationCoordinate2D(latitude: annotationLati, longitude: annotationLongi)
            print(annotationLati,annotationLongi)
            
            let customAnnotation = CustomAnnotation(coordinate: annotationCoordinate)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(CLLocation.init(latitude: annotationLati, longitude: annotationLongi), completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    if let state = firstLocation?.addressDictionary!["State"] as? NSString, let city = firstLocation?.addressDictionary!["City"] as? NSString {
                        customAnnotation.city = String((state as String) + (city as String))
                    }
                }
            })
            
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
            customAnnotation.date = dateformatter.string(from: (usersDataManager.runItem!.annotations!.allObjects.last as! Annotation).timestamp!)
            customAnnotation.text = (usersDataManager.runItem?.annotations?.allObjects.last as! Annotation).text
            customAnnotation.image = UIImage(data: (usersDataManager.runItem?.annotations?.allObjects.last as! Annotation).imageData!)
            mapView.addAnnotation(customAnnotation)
        }
    }
    // 取得目前位置的地址
    typealias CLGeocodeCompletionHandler = ([CLPlacemark]?, Error?) -> Void
    
    func showCity(currentLocation:CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                print(firstLocation?.addressDictionary as Any)
                if let state = firstLocation?.addressDictionary!["State"] as? NSString, let city = firstLocation?.addressDictionary!["City"] as? NSString
                {
                    self.cityLabel.text = String((state as String) + (city as String))
                }
            }
        })
    }
    
//MARK: - CoreData functions
    typealias EditDoneHandler = (_ success:Bool,_ resultItem:Run?) -> Void
    
    func editRun(originalItem:Run?,completion:@escaping EditDoneHandler) {
        var finalItem = originalItem
        if finalItem == nil {
            //把Run存在與Users同一個context里
            finalItem = runManager.createItemTo(target: usersDataManager.userItem!)
            finalItem?.timestamp = Date()
            usersDataManager.userItem?.addToRuns(finalItem!)
        }
        if let runName = finalRunName {
            finalItem?.runname = runName
        }
        if let city = cityLabel.text {
            finalItem?.city = city
        }
        if let duration = finalTime {
            finalItem?.duration = duration
        }
        if let distance = finalDistance {
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
}
// MARK: - UI method
extension ViewController {
    func infoUpAndDown() {
        if heightOfInfoView.constant == 0 {
            heightOfInfoView.constant = 80
            UIView.animate(withDuration: 0.5, animations: {
                self.infoView.frame.origin.y += 90
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
}
// MARK: - CLLocationManagerDelegate, MKMapViewDelegate functions
extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate  {
    
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
                locationList.append(newLocation)
                print(locationList.count)
                showCity(currentLocation: locationList.last!)
                // 儲存 locaiton
                editLocation(originalItem: nil, completion: { (success, item) in
                    guard success == true else {
                        return
                    }
                    do {
                        try usersDataManager.runItem?.managedObjectContext?.save()
                        try usersDataManager.userItem?.managedObjectContext?.save()
                    } catch {
                        let error = error as NSError
                        assertionFailure("Unresolve error\(error)")
                    }
                    
                })
                print(usersDataManager.runItem?.locations?.count as Any)
            }
        }
    }
    
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
        result?.canShowCallout = false
        let image = UIImage(named:"code.png")
        result?.image = image
        //configureDetailView(annotationView: result!)
        return result
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard usersDataManager.runItem?.annotations?.count != 0 else {
            return
        }
        if view.annotation is MKUserLocation {
            return
        }
        
        let customAnnotation = view.annotation as! CustomAnnotation
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        
        calloutView.layer.cornerRadius = 10
        calloutView.layer.masksToBounds = true
        calloutView.cityLabel.text = customAnnotation.city
        calloutView.timestampLabel.text = customAnnotation.date
        calloutView.imageView.image = customAnnotation.image
        calloutView.textLabel.text = customAnnotation.text
        calloutView.center = CGPoint(x: view.bounds.size.width, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: MKAnnotationView.self) {
            for subView in view.subviews {
                subView.removeFromSuperview()
            }
        }
    }
}






