//
//  LocationSearcher.swift
//  GPSAlarm
//
//  Created by Carsten Flokstra on 10/03/2019.
//  Copyright © 2019 Carsten Flokstra. All rights reserved.
//

import Foundation
import MapKit

class LocationSearcher{
    func findLocationByAddress(_ query: String) -> MKPointAnnotation {
        let anno = MKPointAnnotation()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { (placemarks:[CLPlacemark]?, error:Error?) in
        if error == nil{
        let placemarks = placemarks?.first
        
        
        anno.coordinate = (placemarks?.location?.coordinate)!
        anno.title = query
            }else{
                print(error?.localizedDescription ?? "error")
        }
            
}
        return anno
}
}
