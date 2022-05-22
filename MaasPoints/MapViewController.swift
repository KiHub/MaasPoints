//
//  ViewController.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 20.05.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var pointsData: Place?
    var pointsCoordinates: [CLLocation] = []
    var pointsTitle: [String] = []
    var subTitle: [String] = []
    let animation = Animation()
  //  var routeOverlay: MKOverlay?
    let regionInMeters: Double = 5000
    
    var destinationCoordinate: CLLocationCoordinate2D?
    let locationManger = CLLocationManager()
    
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
    
    let clearButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("❎", for: .normal)
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }()
    
    let locationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("❇️", for: .normal)
        button.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
        return button
    }()
    
    let maasLocationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("✅", for: .normal)
        button.addTarget(self, action: #selector(maasLocationTapped), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setup()
        layout()
        checkLocationServices()
        
        if let pointsJson = self.getJson() {
            parseJson(jsonData: pointsJson)
        }
        addPins()
        
       // drawRoute(routeData: pointsCoordinates)
    }
    
    

    func setup() {
        view.addSubview(mapView)
       
        view.addSubview(locationButton)
        view.addSubview(clearButton)
        view.addSubview(maasLocationButton)
 
//        let cityHall = Places(title: "Maastricht City Hall", locationName: "Markt 78", discipline: "Building", coordinate: CLLocationCoordinate2D(latitude: 50.8512304, longitude: 5.6910586))
//        mapView.addAnnotation(cityHall)

    }
    func layout() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            locationButton.topAnchor.constraint(equalTo: maasLocationButton.bottomAnchor, constant: 16),
            locationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
        
        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 16),
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
        
        NSLayoutConstraint.activate([
            maasLocationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            maasLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
    }
    
    func getJson() -> Data? {
        if let path = Bundle.main.path(forResource: "Data", ofType: "geojson") {
            do {
                let data = try String(contentsOfFile: path).data(using: .utf8)
                print("Json read successfully")
                return data
            } catch {
                print("Json error")
            }
        }
        return nil
    }
    
    func parseJson(jsonData: Data) {
        do {
            pointsData = try JSONDecoder().decode(Place.self, from: jsonData)
            for feature in pointsData?.features ?? [] {
                let location = CLLocation(
                    latitude: feature.geometry.coordinates[0],
                    longitude: feature.geometry.coordinates[1]
                )
                pointsCoordinates.append(location)
                let title = feature.properties.title
                pointsTitle.append(title)
                let sub = feature.properties.location
                subTitle.append(sub)
                
            }
        } catch {
            print("Parse Json error")
        }
    }
    
    func addPins() {
        if pointsCoordinates.count != 0 {
            print("not nill")
            var index = 0
            for pin in pointsCoordinates {
                let mapPin = MKPointAnnotation()
                mapPin.coordinate.longitude = pin.coordinate.longitude
                mapPin.coordinate.latitude = pin.coordinate.latitude
                
                mapPin.title = pointsTitle[index]
                mapPin.subtitle = subTitle[index]
                mapView.addAnnotation(mapPin)
                index += 1
            }
            
            
            
//            let startPin = MKPointAnnotation()
//            startPin.title = "start"
//            startPin.coordinate = CLLocationCoordinate2D(
//                latitude: pointsCoordinates[0].coordinate.latitude, longitude: pointsCoordinates[0].coordinate.longitude)
//      //      mapView.addAnnotation(startPin)
//
//            let endPin = MKPointAnnotation()
//            endPin.title = "end"
//            endPin.coordinate = CLLocationCoordinate2D(
//                latitude: pointsCoordinates[1].coordinate.latitude, longitude: pointsCoordinates[1].coordinate.longitude)
//         // mapView.addAnnotation(endPin)
//          //  mapView.addAnnotations([startPin, endPin])
        }
        
    }
    
//    func drawRoute(routeData: [CLLocation]) {
//        if routeData.count == 0 {
//            print("No coordinates to draw")
//            return
//        }
//        let coordinates = routeData.map { location -> CLLocationCoordinate2D in
//            return location.coordinate
//        }
//        DispatchQueue.main.async {
//            self.routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
//            guard let safeRouteOverlay = self.routeOverlay else {return}
//            self.mapView.addOverlay(safeRouteOverlay, level: .aboveRoads)
//            let customEdgePadding: UIEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
//            self.mapView.setVisibleMapRect(safeRouteOverlay.boundingMapRect, edgePadding: customEdgePadding, animated: true)
//
//        }
//    }
    
//    func loadData() {
//
//        guard let fileName = Bundle.main.url(forResource: "Points", withExtension: "geojson"),
//              let placesData = try? Data(contentsOf: fileName)
//        else {return}
//
//        do {
//            let features = try MKGeoJSONDecoder()
//                .decode(placesData)
//                .compactMap{$0 as? MKGeoJSONFeature}
//            let valid = features.compactMap(Places.init)
//            places.append(contentsOf: valid)
//        } catch {
//            print("Error")
//        }
//
//    }
    
    
    
}

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
     //   annotationView?.calloutOffset = CGPoint(x: 0, y: 25)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
     animation.shake(view: view)
        print("Tapped")
        destinationCoordinate = view.annotation?.coordinate
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Info")

        guard let destination = destinationCoordinate else {return}
        print(destination)
        mapView.removeOverlays(mapView.overlays)
        mapRoute(destinationCoordinate: destination)
        print("Info2")

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

//
//extension MapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? Places else {return nil}
//
//        let identifier = "Places"
//        let view: MKMarkerAnnotationView
//        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
//            dequeueView.annotation = annotation
//            view = dequeueView
//        } else {
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//        return view
//    }
//
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        guard let places = view.annotation as? Places else {return}
//        let launchOption = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
//
//      //  places.mapItem?.openInMaps(launchOptions: launchOption)
//    }
//
//
//}

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
          //  locationManger.startUpdatingLocation()
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
        let initLocation = CLLocation(latitude: 50.849463, longitude: 5.688586)
        mapView.centerLocation(initLocation)
        print("Maas location tapped")
    }
}
