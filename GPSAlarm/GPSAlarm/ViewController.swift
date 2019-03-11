//
//  ViewController.swift
//  GPSAlarm
//
//  Created by Carsten Flokstra on 07/03/2019.
//  Copyright © 2019 Carsten Flokstra. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBarMap: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var destination  = CLLocationCoordinate2D()
    var destinationName = ""
    let alert = UIAlertController(title: "No location set", message: "There is no location selected on the map. We need a location to wake you up. Please search for a location in the searchbar", preferredStyle: .actionSheet)
    let regionInMeters: Double = 1000
    let locationSearcher = LocationSearcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        checkLocationServices()
        centerViewOnUserLocation()
        searchBarMap.delegate = self
    }
    
    
    @IBAction func touchSetAlarm(_ sender: Any) {
        checkLocationAuthorization()
        if(mapView.annotations.count <= 1){
            self.present(alert,animated: true)
        }
        
        else{
       
            let region = CLCircularRegion(center: destination,
                                          radius: 1000,
                                          identifier: destinationName)
            
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
        }
    }
    
    func checkLocationServices(){
        if(CLLocationManager.locationServicesEnabled()) {
            checkLocationAuthorization()
            setupLocationManager()
            } else{
            showLocationDisabledPopup()
            }
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationAuthorization(){
        
        switch CLLocationManager.authorizationStatus(){
        
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        break
            
        case .denied:
            showLocationDisabledPopup()
            break
        case .authorizedWhenInUse:
            showLocationDisabledPopup()
            break
        case .restricted:
            showLocationDisabledPopup()
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarMap.becomeFirstResponder()
        self.searchBarMap.endEditing(true)
        mapView.removeAnnotations(mapView.annotations)
        
        let geocoder = CLGeocoder()
        
        if let query = searchBarMap.text{
            geocoder.geocodeAddressString(query) { (placemarks:[CLPlacemark]?, error:Error?) in
                if error == nil{
                let placemarks = placemarks?.first
                self.destinationName = query
                
                let anno = MKPointAnnotation()
                self.destination = (placemarks?.location?.coordinate)!
                anno.coordinate = self.destination
                anno.title = self.destinationName
                
                self.mapView.addAnnotation(anno)
                self.mapView.selectAnnotation(anno, animated: true)
               let region = MKCoordinateRegion.init(center: anno.coordinate, latitudinalMeters: self.regionInMeters*10, longitudinalMeters: self.regionInMeters*10)
                self.mapView.setRegion(region, animated: true)
                
            }else{
                print(error?.localizedDescription ?? "error")
            }
        }
    }
    }
    
    func showLocationDisabledPopup(){
        let alertController = UIAlertController(
            title: "Background Location Access Disabled",
            message: "In order to wake you op we need always your location",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction (title: "Open Settings", style: .default) { (action) in
            if let url = URL (string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController,animated: true,completion: nil)
        
    }

    
    private func setupLocationManager() {
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func handleWakeUp() {
        let alertController = UIAlertController(
            title: "\(destinationName) reached!",
            message: "Wake up!",
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         self.present(alertController,animated: true,completion: nil)
    }
}



extension ViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else {return}
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
    }
        
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkLocationAuthorization()
            mapView.showsUserLocation = (status == .authorizedAlways)
        }
        
        func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            if let region = region as? CLCircularRegion {
                let identifier = region.identifier
                handleWakeUp()
            }
        }
}



