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

class ViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userTrackinBtn: UIButton!
    @IBOutlet weak var startRecordBtn: UIButton!
    @IBOutlet weak var btnAnimatedBtn: UIButton!
    @IBOutlet weak var addTextBtn: UIButton!
    @IBOutlet weak var addPhotoBtn: UIButton!
    
    
    let gesture = GestureRecognizer()
    
    let locationManager = CLLocationManager()
    var locations = [CLLocation]()
    var distance = 0.0
    var instantPace = 0.0
    var previousAlt = 0.0
    var vertClimb = 0.0
    var vertDescent = 0.0
    
    // Status 判斷變數
    var addBtnPressed = false
    var startRecord = false
    var addedRedFlag = false
    var addedGreenAnnotation = false
    var addedEndFlag = false
    
    var containerView = UIView()
    let textView = UITextView()
    var photoImageView = UIImageView()
    
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 手勢滑動開啟 sideMenu
        gesture.turnOnMenu(target: menuButton, VCtarget: self)

        // 初始定位設定
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        // ==== NaviBar 透明化 =====
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        //        recordInfoBar.backgroundColor? = UIColor.white.withAlphaComponent(0.5)
        
        // ===== 迷霧 ======
        if let fullRadius = CLLocationDistance(exactly: MKMapRectWorld.size.height) {
            
            mapView.add(MKCircle(center: mapView.centerCoordinate, radius: fullRadius))
        }
        
        // 點擊空白處收鍵盤
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToHideKeyboard))
//        self.view.addGestureRecognizer(tapGesture)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: IBActions
    @IBAction func userTrackingBtnPressed(_ sender: Any) {
        self.mapView.userTrackingMode = .followWithHeading
    }
    
    
    @IBAction func startRecordBtnPressed(_ sender: Any) {
        // 在一般模式下 按下「開始記錄」按鈕 => 出現紅旗
        if startRecord == false {
            mapViewAddRedFlag()
            startRecord = true
            print("start tracking!!")
            // 可再加入按鈕變化
            
            
            // 在紀錄模式下 按下「結束紀錄」按鈕
        } else {
            mapViewAddEndFlag()
            let alert = UIAlertController(title: "Stop Tracking", message: "Choose 'Save' to save this record, 'Discard' to discard this record, or 'Cancel' to keep tracking", preferredStyle: .alert)
            
            // 1. 儲存
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (UIAlertAction) in
                // app 狀態先回到 一般模式
                self.startRecord = false
                ///...加入儲存 func
                
                
                print("Save Tracking!!")
                
                
            }))
            
            // 2. 丟棄
            alert.addAction(UIAlertAction(title: "Discard", style: .default, handler: { (UIAlertAction) in
                // app 模式調整
                self.startRecord = false
                self.addedRedFlag = false
                
                // 刪除已出現的 annotation 及 路線
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
                
                // 刪除 user 在這段期間的位置移動紀錄
                self.locations.removeAll()
                print("Discard record")
            }))
            
            // 3. 取消 => 繼續紀錄軌跡
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAnimatedBtnPressed(_ sender: Any) {
        self.addBtnPressedAnimate()
        print("animated")
    }
    
    @IBAction func addPhotoBtnPressed(_ sender: Any) {
        // 平時模式下 按下「加入照片」按鈕 => 會進入相機或相簿
        if startRecord == false {
            
            // app 模式需判斷在完成新增照片後，mapView 要新增紅旗與綠標
            // app 模式的調整：要在這邊？還是在確定新增照片後再調整
            //mapViewAddRedFlag()
            
            // 按鈕動畫歸位
            addBtnPressedAnimate()
            
            print("add Photo and start a track")
            
            
            // 在紀錄軌跡模式下 按下「加入照片」按鈕
        } else {
            // app 模式需判斷在完成新增照片後，mapView 要新增紅旗與綠標
            // app 模式的調整：要在這邊？還是在確定新增照片後再調整
            
            // 按鈕動畫歸位
            addBtnPressedAnimate()
            
            print("add Photo")
        }
        
        // 跳出 alert 視窗
        let alert = UIAlertController(title: "Add new Photo?", message: "Taking a pic from camera, or pick from photo library", preferredStyle: .actionSheet)
        // 相機
        let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
            
            self.launchImagePicker(sourceType: .camera)
        }
        // 相簿
        let library = UIAlertAction(title: "Library", style: .default) { (_) in
            self.launchImagePicker(sourceType: .photoLibrary)
        }
        // 取消
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    @IBAction func addTextBtnPressed(_ sender: Any) {
        // 平時模式下 按下「加入留言」按鈕
        if startRecord == false {
            // app 模式需判斷在完成新增照片後，mapView 要新增紅旗與綠標
            // app 模式的調整：要在這邊？還是在確定新增照片後再調整
            // startRecord = true
            
            // 按鈕動畫歸位
            addBtnPressedAnimate()
            
            print("try add Text and start a track")
            
            // 在紀錄軌跡模式下 按下「加入留言」按鈕
        } else {
            // app 模式需判斷在完成新增照片後，mapView 要新增紅旗與綠標
            // app 模式的調整：要在這邊？還是在確定新增照片後再調整
            // // 新增綠標 要改照片完成並確認後加入
            // mapViewAddGreenAnnotation()
            
            // 按鈕動畫歸位
            addBtnPressedAnimate()
            print("try add Text")
            
        }
        // 隱藏 recordInfoBar
        // recordInfoBar.isHidden = true
        
        // 設定編輯頁面的 View
        containerView = UIView(frame: self.mapView.frame)
        containerView.backgroundColor = UIColor.clear
        self.mapView.addSubview(containerView)
        
        // 加入 textView
        
        textView.frame = CGRect(x: 16, y: 104, width: 343, height: 250)
        textView.contentInset = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 2)
        textView.font = UIFont.systemFont(ofSize: 22)
        textView.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        self.mapView.addSubview(textView)
        
        // 加入按鈕
        let saveBtn = UIButton(frame: CGRect(x: 303, y: 362, width: 56, height: 30))
        saveBtn.setBackgroundImage(UIImage(named:"saveBtn"), for: .normal)
        // 設定儲存 function
        saveBtn.addTarget(self, action: #selector(saveAddText), for: .touchUpInside)
        
        
        let cancelBtn = UIButton(frame: CGRect(x: 235, y: 362, width: 56, height: 30))
        cancelBtn.setBackgroundImage(UIImage(named:"cancelBtn"), for: .normal)
        // 設定取消 function
        cancelBtn.addTarget(self, action: #selector(cancelAddText), for: .touchUpInside)
        
        containerView.addSubview(textView)
        containerView.addSubview(saveBtn)
        containerView.addSubview(cancelBtn)
        
        // 設定在按下 勾勾 或 叉叉 以前其他按鈕不能使用
        btnAnimatedBtn.isEnabled = false
        startRecordBtn.isEnabled = false
        userTrackinBtn.isEnabled = false
        addTextBtn.isHidden = true
        addPhotoBtn.isHidden = true
        
        
    }
    
    
    // MARK: CLLocationManagerDelegate Method
    
    // didUpdateLocations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 在一般狀態下 user 可看的初始範圍，與定位 update
        if startRecord == false {
            guard let currentLocation = locations.last else {
                return
            }
            let coordinate = currentLocation.coordinate
            NSLog("Lat:\(coordinate.latitude),Lon:\(coordinate.longitude)")
            
            // GCD of DispatchQueue
            DispatchQueue.once(token: "MoveAndZoomMap") {
                let span = MKCoordinateSpanMake(0.009, 0.009);
                let region = MKCoordinateRegion(center: coordinate, span: span);
                
                
                mapView.setRegion(region, animated: true);
            }
            
            
            // 在紀錄軌跡之狀態
        } else {
            
            for location in locations {
                
                //update distance
                // 如果開啟紀錄軌跡，當 Locations 陣列 有更多位置紀錄
                if self.locations.count > 0 {
                    self.distance += location.distance(from: self.locations.last!)
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    self.instantPace = location.distance(from: self.locations.last!)/(location.timestamp.timeIntervalSince(self.locations.last!.timestamp))
                    
                    // 繪入路線
                    mapView.add(MKPolyline(coordinates: &coords, count: coords.count))
                    self.previousAlt=location.altitude
                }
                // 加入新的 location(coordinate)
                self.locations.append(location)
            }
        }
    }
    
    
    // MARK: MKMapViewDelegate Methods.
    
    // Setting AnnotationView
    /// 改變 identifier 來簡化看看
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 如果 annotation 為紅旗
        if addedRedFlag == true {
            
            if annotation is MKUserLocation {
                return nil
            }
            let identifier = "trekRecord"
            var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if result == nil {
                result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                result?.annotation = annotation
            }
            
            result?.canShowCallout = true
            let imageFlag = UIImage(named: "redFlagAnnotation")
            result?.image = imageFlag
            
            addedRedFlag = false
            return result
            
            // 如果 annotation 為綠標
        } else if addedGreenAnnotation == true {
            
            if annotation is MKUserLocation {
                return nil
            }
            let identifier = "trekRecord"
            var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if result == nil {
                result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                result?.annotation = annotation
            }
            
            result?.canShowCallout = true
            let image = UIImage(named: "addAnnotation")
            result?.image = image
            
            /// 改成使用者紀錄的 文字 或是 照片
            let imageView = UIImageView(image: image)
            result?.leftCalloutAccessoryView = imageView
            // Prepare RightCalloutAccessoryView
            // 在 callOut 裡面設定是不需要管理 layOut
            let button = UIButton(type: .detailDisclosure)
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            result?.rightCalloutAccessoryView = button
            
            addedGreenAnnotation = false
            return result
            
            // 如果 annotation 為結束旗幟
        } else if addedEndFlag == true {
            if annotation is MKUserLocation {
                return nil
            }
            let identifier = "trekRecord"
            var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if result == nil {
                result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                result?.annotation = annotation
            }
            
            result?.canShowCallout = true
            let image = UIImage(named: "endFlagAnnotation")
            result?.image = image
            
            /// 改成使用者紀錄的 文字 或是 照片
            let imageView = UIImageView(image: image)
            result?.leftCalloutAccessoryView = imageView
            // Prepare RightCalloutAccessoryView
            // 在 callOut 裡面設定是不需要管理 layOut
            let button = UIButton(type: .detailDisclosure)
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            result?.rightCalloutAccessoryView = button
            
            addedEndFlag = false
            return result
            
            // 其他
        } else {
            if annotation is MKUserLocation {
                return nil
            }
            let identifier = "trekRecord"
            var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if result == nil {
                result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                result?.annotation = annotation
            }
            
            result?.canShowCallout = true
            let image = UIImage(named: "endFlagAnnotation")
            result?.image = image
            
            /// 改成使用者紀錄的 文字 或是 照片
            let imageView = UIImageView(image: image)
            result?.leftCalloutAccessoryView = imageView
            // Prepare RightCalloutAccessoryView
            // 在 callOut 裡面設定是不需要管理 layOut
            let button = UIButton(type: .detailDisclosure)
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            result?.rightCalloutAccessoryView = button
            return result
        }
    }
    
    func buttonTapped(sender:Any) {
        NSLog("buttonTapped!")
    }
    
    // Setting MKOverlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // 迷霧
        if overlay is MKCircle {
            
            let view = MKCircleRenderer(overlay: overlay)
            
            view.fillColor = UIColor.lightGray.withAlphaComponent(0.4)
            return view
        }
        // 路線
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
    
    
    
    
    
    // MARK: addBtnAnimated
    func addBtnPressedAnimate() {
        if addBtnPressed == false {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.addPhotoBtn.frame = CGRect(x: 37, y: 60, width: self.addPhotoBtn.frame.width, height: self.addPhotoBtn.frame.height)
                
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.addTextBtn.frame = CGRect(x: 37, y: 60, width: self.addTextBtn.frame.width, height: self.addTextBtn.frame.height)
                
            }, completion: nil)
            
            addBtnPressed = true
            
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.addPhotoBtn.frame = CGRect(x: 6, y: 13, width: self.addPhotoBtn.frame.width, height: self.addPhotoBtn.frame.height)
                
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.addTextBtn.frame = CGRect(x: 70, y: 13, width: self.addTextBtn.frame.width, height: self.addTextBtn.frame.height)
                
            }, completion: nil)
            
            addBtnPressed = false
        }
    }
    
    // MARK: ImagePickerController
    // UIImagePickerController delegate method
    func launchImagePicker(sourceType: UIImagePickerControllerSourceType) {
        // 檢查硬體設備是否相同 sourceType
        if UIImagePickerController.isSourceTypeAvailable(sourceType) == false {
            NSLog("No Available Device")
            return
        }
        // Prepare UIImagePicker
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.image","public.movie"]
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        /// 尚未完成
        //        self.photoImageView.frame = CGRect(x: Int, y: Int, width: Int, height: Int)
        //
        //        self.photoImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    
    
    // MARK: addFlagAndAnnotations
    // 新增紅旗
    func mapViewAddRedFlag() {
        addedRedFlag = true
        addedGreenAnnotation = false
        addedEndFlag = false
        
        locationManager.startUpdatingLocation()
        guard let currentLocation = locationManager.location else {
            return
        }
        let coordinate = currentLocation.coordinate
        NSLog("緯度: \(coordinate.latitude), 經度: \(coordinate.longitude)")
        
        
        let redFlag = MKPointAnnotation()
        redFlag.coordinate = coordinate
        redFlag.title = "Start"
        /// 新增紀錄區域名稱或是紀錄時間
        redFlag.subtitle = ""
        mapView.addAnnotation(redFlag)
    }
    
    
    // 新增綠色紀錄點
    func mapViewAddGreenAnnotation() {
        
        addedGreenAnnotation = true
        addedRedFlag = false
        addedEndFlag = false
        locationManager.startUpdatingLocation()
        guard let currentLocation = locationManager.location else {
            return
        }
        let coordinate = currentLocation.coordinate
        NSLog("緯度: \(coordinate.latitude), 經度: \(coordinate.longitude)")
        
        var annotationCoordinate = coordinate
        annotationCoordinate.latitude += 0.0001
        annotationCoordinate.longitude += 0.0001
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = annotationCoordinate
        annotation.title = "Annotation"
        /// 新增紀錄區域名稱或是紀錄時間
        annotation.subtitle = "使用者紀錄之文字"
        
        mapView.addAnnotation(annotation)
    }
    
    
    // 新增結束其標
    func mapViewAddEndFlag() {
        
        addedGreenAnnotation = false
        addedRedFlag = false
        addedEndFlag = true
        
        locationManager.startUpdatingLocation()
        guard let currentLocation = locationManager.location else {
            return
        }
        let coordinate = currentLocation.coordinate
        NSLog("緯度: \(coordinate.latitude), 經度: \(coordinate.longitude)")
        
        var annotationCoordinate = coordinate
        annotationCoordinate.latitude += 0.0001
        annotationCoordinate.longitude += 0.0001
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = annotationCoordinate
        annotation.title = "End Point"
        /// 新增紀錄區域名稱或是紀錄時間
        annotation.subtitle = "使用者紀錄之文字"
        
        mapView.addAnnotation(annotation)
    }
    
    
    // MARK: addTextSaveAndCancel
    func saveAddText() {
        if startRecord == false {
            //            mapViewAddRedFlag()
            //            mapViewAddGreenAnnotation()
            startRecord = true
            print("add Text and start a track")
            
            // 在紀錄軌跡模式下 按下「加入留言」按鈕 => 會增加一個綠標
        } else {
            
            //            mapViewAddGreenAnnotation()
            
            print("add Text")
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddPhotoAndTextViewController") as? AddPhotoAndTextViewController
        vc?.textEntered = textView.text
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
        
        
        
        
    }
    func cancelAddText() {
        
        
        if containerView.subviews.count > 0 {
            for i in containerView.subviews {
                i.removeFromSuperview()
            }
        }
        btnAnimatedBtn.isEnabled = true
        startRecordBtn.isEnabled = true
        userTrackinBtn.isEnabled = true
        addTextBtn.isHidden = false
        addPhotoBtn.isHidden = false
    }
    
    
    
    
    func tapToHideKeyboard() {
        self.mapView.endEditing(true)
    }
    
    /// END

    
    
}

