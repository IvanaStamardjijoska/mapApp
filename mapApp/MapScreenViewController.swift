//
//  ViewController.swift
//  mapApp
//
//  Created by CodeWell on 12/19/18.
//  Copyright © 2018 Ivana Stamardjioska. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation

class MapScreenViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var parkingArray = [Parking]()
    var regionArray = [CLRegion:Parking]()
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkForLocationServices()
        generateParkingSpots()
        
        
    }
    //MARK: Functions
    func generateParkingSpots(){
        let parking1 = Parking()
        parking1.name = "Aerodrom"
        parking1.price = 40
        parking1.lontitude = 21.4670
        parking1.latitude = 41.985
        parking1.identifier = PARKING_POC
        parking1.radius = 60
        
        let parking2 = Parking()
        parking2.name = "Grad Skopje"
        parking2.price = 50
        parking2.lontitude = 21.4161
        parking2.latitude = 41.9971
        parking2.identifier = PARKING_GRAD_SKOPJE
        parking2.radius = 20
        
        let parking3 = Parking()
        parking3.name = "Parking Centar"
        parking3.price = 30
        parking3.lontitude = 21.4159
        parking3.latitude = 41.9960
        parking3.identifier = PARKING_CENTAR
        parking3.radius = 40
        
        parkingArray.append(parking1)
        parkingArray.append(parking2)
        parkingArray.append(parking3)
        
        generateRegions()
    }
    func showAlertForParking (parking: Parking){
        let alert = UIAlertController(title: "New parking!", message: "You have entered " + parking.name + ". The cost is " + String(parking.price) + " den.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    func generateRegions(){
        if !parkingArray.isEmpty{
            mapView.removeOverlays(mapView.overlays)
            for parking in parkingArray{
                if let longitude = parking.lontitude, let latitude = parking.latitude, let radius = parking.radius{
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let region = CLCircularRegion(center: coordinate, radius: Double(radius), identifier: parking.identifier)
                    locationManager.startMonitoring(for: region)
                    regionArray[region] = parking
                    let circle = MKCircle(center: coordinate, radius: region.radius)
                    mapView.add(circle)
                }
            }
        }
    }
    
    
    
    //MARK: Location setup and authorization
    func checkForLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthentication()
        }
    }
    
    func checkLocationAuthentication(){
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedAlways:
            startTrackingUserLocation()
            break
            
        case .authorizedWhenInUse:
            startTrackingUserLocation()
            break
            
        case .denied:
            
            break
        case .notDetermined:
            
            locationManager.requestAlwaysAuthorization()
            break
            
        case .restricted:
            
            break
            
        }
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self
    }
    
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        centerUserOnTheMap()
        
    }
    func centerUserOnTheMap(){
        if let location = locationManager.location?.coordinate{
            let span = MKCoordinateSpan(latitudeDelta: 300, longitudeDelta: 300)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    //MARK: Location Manager Delegate Functions
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        checkLocationAuthentication()
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        locationManager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            if let _ = regionArray[region], let parking = regionArray[region]{
                showAlertForParking(parking: parking)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.showsUserLocation = true
        if !locations.isEmpty {
            let location = locations[0]
            let locationCoordinate = location.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 300, longitudeDelta: 300)
            
            let region = MKCoordinateRegion(center: locationCoordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: Map View Delegate functions
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else {return MKOverlayRenderer() }
        
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.fillColor = UIColor.red
        circleRenderer.alpha = 0.3
        return circleRenderer
    }
    
    //MARK: Actions
    
    @IBAction func longPressOnScreen(_ sender: Any) {
        guard let longPress = sender as? UILongPressGestureRecognizer else { return }
        if longPress.state == .ended {
            let touchLocation = longPress.location(in: mapView)
            let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            print("longitude = " + String(coordinate.longitude))
            print("latitude = " + String(coordinate.latitude))
            let alert = UIAlertController(title: "New location!", message: "latitude = " + String(coordinate.latitude) + "\nlongitude = " + String(coordinate.longitude), preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func resetLocationTapped(_ sender: Any) {
        locationManager.startUpdatingLocation()
        
    }
}

