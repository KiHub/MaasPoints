//
//  ViewController.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 20.05.2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let mapView: MKMapView = {
        let initLocation = CLLocation(latitude: 50.849463, longitude: 5.688586)
        let map = MKMapView()
        let region = MKCoordinateRegion(center: initLocation.coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 50000)
        map.setCameraZoomRange(zoomRange, animated: true)
        map.centerLocation(initLocation)
        map.overrideUserInterfaceStyle = .dark
        map.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        return map
    }()
    
  //  let initLocation = CLLocation(latitude: 50.849463, longitude: 5.688586)
   
   

    override func viewDidLoad() {
        super.viewDidLoad()
       
        setup()
        layout()
    }

    func setup() {
        view.addSubview(mapView)
   //     mapView.centerLocation(initLocation)
//        let region = MKCoordinateRegion(center: initLocation.coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
   //     mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
      //  let zoomRange = MKMapView.CameraZoomRange(10000)
     //  mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    func layout() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

extension MKMapView {
    func centerLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 2000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
        
        
    }
}

extension MapViewController: MKMapViewDelegate {
    
    
}
