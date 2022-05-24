//
//  MapViewControllerExtensions.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 23.05.2022.
//

import UIKit
import MapKit

extension MKMapView {
    func centerLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 2000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            
            annotationView?.canShowCallout = true
            annotationView?.calloutOffset = CGPoint(x: 10, y: 5)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView?.tintColor = appMainColor
            
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.image = UIImage(named: "point")
        annotationView?.layer.shadowColor =  UIColor.black.cgColor
        annotationView?.layer.shadowOpacity = 0.5
        annotationView?.layer.shadowOffset = .init(width: 3, height: 3)
        annotationView?.layer.shadowRadius = 15
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        animation.shake(view: view)
        print("Tapped")
        destinationCoordinate = view.annotation?.coordinate
        itemTitle = view.annotation?.title ?? ""
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Info")
        NotificationCenter.default.post(name: NSNotification.Name("loaded"), object: nil)
        bottomManager.showBulletin(above: self)
        
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKGradientPolylineRenderer(overlay: overlay)
        render.setColors([appMainColor,appSecondColor,appThirdColor], locations: [])
        render.lineCap = .round
        render.lineWidth = 4.0
        return render
    }
    
    func mapRoute(destinationCoordinate: CLLocationCoordinate2D) {
        
        guard let sourceCoordinate = locationManger.location?.coordinate else {return}
        let sourceMark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationMark = MKPlacemark(coordinate: destinationCoordinate)
        
        let sourceItem = MKMapItem(placemark: sourceMark)
        let destinationItem = MKMapItem(placemark: destinationMark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
        destinationRequest.transportType = .walking
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        
        directions.calculate { (responce, error) in
            guard let responce = responce else { return }
            let route = responce.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
}


extension MapViewController: CLLocationManagerDelegate {
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            print("Error")
        }
    }
    
    func setupLocationManager() {
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManger.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            // show alert instructions
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

extension MapViewController {
    @objc func clearTapped(_ sender: UIButton) {
        if mapView.overlays.count != 0 {
            mapView.removeOverlays(mapView.overlays)
        }
        print("Clear tapped")
    }
    @objc func locationTapped(_ sender: UIButton) {
        guard let location = locationManger.location else {return}
        mapView.centerLocation(location)
        print("Location tapped")
    }
    @objc func maasLocationTapped(_ sender: UIButton) {
     //  let initLocation = CLLocation(latitude: 50.849463, longitude: 5.688586)
        mapView.centerLocation(initLocation)
        print("Maas location tapped")
    }
}

extension MapViewController: MapViewProtocol {
    
    func addPins(points: Place) {
        
        DispatchQueue.main.async { [self] in
            var index = 0
            for pin in points.features {
                let mapPin = MKPointAnnotation()
                mapPin.coordinate.longitude = pin.geometry.coordinates[1]
                mapPin.coordinate.latitude = pin.geometry.coordinates[0]
                let coordinate = CLLocation(latitude: pin.geometry.coordinates[0], longitude: pin.geometry.coordinates[1])
                pointsCoordinates.append(coordinate)
                pointsTitle.append(pin.properties.title)
                mapPin.title = pointsTitle[index]
                subTitle.append(pin.properties.location)
                mapPin.subtitle = subTitle[index]
                mapView.addAnnotation(mapPin)
                index += 1
                
            }
        }
    }
}


