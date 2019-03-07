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

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    
    
    func checkLocationServices(){
        if(CLLocationManager.locationServicesEnabled()) {
            setupLocationManager()
            checkLocationAuthorization()
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
            centerViewOnUserLocation()
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
    
    func showLocationDisabledPopup(){
        let alertController = UIAlertController(
            title: "Background Location Acces Disabeled",
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
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else {return}
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkLocationAuthorization()
        }
    }
}

