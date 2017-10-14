//
//  MyRecordedViewController.swift
//  Project
//
//  Created by Willy on 2017/9/5.
//  Copyright © 2017年 Willy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MyRecordedViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView2: MKMapView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var cityName: UILabel!
    var runDate:String?
    var city:String?
    var annotation = [Annotation]()
    var run: Run!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMap()
        date.text = runDate
        guard cityName.text == city else {
            return
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //把照片、文字傳給ContainerView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EmbedView"){
            let vc2 = segue.destination as! MyRecordViewController
            vc2.goodlist = self.annotation
        }
    }
    

    private func mapRegion() -> MKCoordinateRegion? {
        //調整顯示範圍
        let initialLoc = run.locations?.allObjects.first as! Location
        
        var minLat = initialLoc.latitude
        var minLng = initialLoc.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = run.locations?.allObjects as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude)
            minLng = min(minLng, location.longitude)
            maxLat = max(maxLat, location.latitude)
            maxLng = max(maxLng, location.longitude)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                                           longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.5,
                                   longitudeDelta: (maxLng - minLng)*1.5))
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor(red: 0, green: 0.83, blue: 0.61, alpha: 1)
        renderer.lineWidth = 8
        return renderer
    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        let locations = run.locations?.allObjects as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude,
                                                 longitude: location.longitude))
        }
        
        return MKPolyline(coordinates: &coords, count: coords.count)
    }
    
    func loadMap() {
        let locations = run.locations?.allObjects as! [Location]
        guard locations.count > 1 else{
            return
        }
        // Set the map bounds
        mapView2.region = mapRegion()!
        
        // Make the line(s!) on the map
        for i in 0..<locations.count{
            var coords = [CLLocationCoordinate2D]()
            coords.append(CLLocationCoordinate2D(latitude: locations[i].latitude, longitude: locations[i].longitude))
            mapView2.add(MKPolyline(coordinates: &coords, count: coords.count))
        }
    }
}
