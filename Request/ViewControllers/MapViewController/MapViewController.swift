//
//  MapViewController.swift
//  Request
//
//  Created by Álvaro Sanz Rodrigo on 21/11/18.
//  Copyright © 2018 Álvaro Sanz Rodrigo. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var mapView: MKMapView!
    internal var locationToShow: CLLocation?
    
    convenience init(lat: Double!, lng: Double!) {
        self.init()
        self.locationToShow = CLLocation(latitude: lat, longitude: lng)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let annotation = MKPointAnnotation()
        annotation.coordinate = (locationToShow?.coordinate)!
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegionMakeWithDistance((locationToShow?.coordinate)!, 2000, 2000)
        mapView.setRegion(region, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func segmentedControllDidChange(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard

        }
    }
}
