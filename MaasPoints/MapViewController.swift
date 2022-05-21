//
//  ViewController.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 20.05.2022.
//

import UIKit
import MapKit
import Contacts

class MapViewController: UIViewController {
    
    var pointsData: Place?
    var pointsCoordinates: [CLLocation] = []
    var pointsTitle: [String] = []
    var subTitle: [String] = []
    let animation = Animation()
    var routeOverlay: MKOverlay?
    
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


    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setup()
        layout()
  
        
        if let pointsJson = self.getJson() {
            parseJson(jsonData: pointsJson)
        }
        addPins()
        
       // drawRoute(routeData: pointsCoordinates)
    }
    
    

    func setup() {
        view.addSubview(mapView)
        
//        let cityHall = Places(title: "Maastricht City Hall", locationName: "Markt 78", discipline: "Building", coordinate: CLLocationCoordinate2D(latitude: 50.8512304, longitude: 5.6910586))
//        mapView.addAnnotation(cityHall)
        
     //   loadData()
     //   mapView.addAnnotations(places)
        

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
          //  print(pointsData)
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
//                for title in pointsTitle {
//                    startPin.title = title
//                }
                
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
    
    func drawRoute(routeData: [CLLocation]) {
        if routeData.count == 0 {
            print("No coordinates to draw")
            return
        }
        let coordinates = routeData.map { location -> CLLocationCoordinate2D in
            return location.coordinate
        }
        DispatchQueue.main.async {
            self.routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
            guard let safeRouteOverlay = self.routeOverlay else {return}
            self.mapView.addOverlay(safeRouteOverlay, level: .aboveRoads)
            let customEdgePadding: UIEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
            self.mapView.setVisibleMapRect(safeRouteOverlay.boundingMapRect, edgePadding: customEdgePadding, animated: true)
            
        }
    }
    
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

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
     animation.shake(view: view)
        print("Tapped")
      
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Info")
        drawRoute(routeData: pointsCoordinates)
       // guard let places = view.annotation as? Place else {return}
        print("Info2")
     //   let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
//        places.
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKGradientPolylineRenderer(overlay: overlay)
        render.setColors([appMainColor,appSecondColor,appThirdColor], locations: [])
        render.lineCap = .round
        render.lineWidth = 4.0
        return render
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
