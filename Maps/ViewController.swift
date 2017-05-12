//
//  ViewController.swift
//  Maps
//
//  Created by Enrique V. Kortright on 5/11/17.
//  Copyright © 2017 Enrique V. Kortright. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var showDetails : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsLabel.isHidden = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let latitude : CLLocationDegrees = 20.598351
        let longitude : CLLocationDegrees = -100.380255
        let latDelta : CLLocationDegrees = 0.05
        let lonDelta : CLLocationDegrees = 0.05
        let center : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region : MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation : MKPointAnnotation = MKPointAnnotation()
        annotation.title = "Pathe 13"
        annotation.subtitle = "Blast from the past!"
        annotation.coordinate = center
        mapView.addAnnotation(annotation)
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(uiGestureRecognizer:)))
        uilpgr.minimumPressDuration = 2
        
        mapView.addGestureRecognizer(uilpgr)
    }
    
    func longpress(uiGestureRecognizer: UIGestureRecognizer) {
        print("longpress")
        let touchPoint = uiGestureRecognizer.location(in: self.mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "New Place"
        annotation.subtitle = "Good place!"
        mapView.addAnnotation(annotation)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location: \(locations[0])")
        let latDelta : CLLocationDegrees = 0.005
        let lonDelta : CLLocationDegrees = 0.005
        let center : CLLocationCoordinate2D = locations[0].coordinate
        let span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region : MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
        var address = ""
        CLGeocoder().reverseGeocodeLocation(locations[0]) { (placemarks, error) in
            if error != nil {
                print("Error reverse geocoding: \(String(describing: error))")
            } else {
                if let placemark = placemarks?[0] {
                    let formattedAddressLines = placemark.addressDictionary?["FormattedAddressLines"] as! [String]
                    address = ""
                    for line in formattedAddressLines {
                        print("line: \(line)")
                        address += line + "\n"
                    }
                    if self.showDetails {
                        self.detailsLabel.text = "Details:\n\n" +
                            "location: " + String(format: "%.4f", locations[0].coordinate.latitude) + "," +
                            String(format: "%.4f", locations[0].coordinate.longitude) + "\n" +
                            "speed: \(locations[0].speed) mps\n" +
                            "course: \(locations[0].course) degrees\n" +
                            "altitude: \(locations[0].altitude) m\n" +
                            "near address:\n" + address
                    }
                    print("address: \(address)")
                }
            }
        }
    }
    
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    @IBAction func actionTapped(_ sender: Any) {
        print("actionTapped")
        showDetails = !showDetails
        print("showDetails: \(showDetails)")
        detailsLabel.isHidden = !showDetails
    }
}

