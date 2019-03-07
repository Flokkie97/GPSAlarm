//
//  ViewController.swift
//  GPSAlarm
//
//  Created by Carsten Flokstra on 07/03/2019.
//  Copyright © 2019 Carsten Flokstra. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            print(location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if (status == CLAuthorizationStatus.denied){
            showLocationDisabledPopup()
        }
    }
    
    func showLocationDisabledPopup(){
        let alertController = UIAlertController(
            title: "Background Location Acces Disabeled",
            message: "In order to wake you op we need your location",
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

    


}

