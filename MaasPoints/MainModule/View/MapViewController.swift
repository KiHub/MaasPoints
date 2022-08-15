//
//  ViewController.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 20.05.2022.
//

import UIKit
import MapKit
import CoreLocation
import BLTNBoard


class MapViewController: UIViewController {
    
    
    var pinsPresenter: PinsPresenterProtocol!
    
    var pointsCoordinates: [CLLocation] = []
    var pointsTitle: [String] = []
    var subTitle: [String] = []
    
    let animation = Animation()
    let regionInMeters: Double = 5000
    
    var destinationCoordinate: CLLocationCoordinate2D?
    let locationManger = CLLocationManager()
    
    var itemTitle: String?
    
    
    let mapView: MKMapView = {
        let map = MKMapView()
        let region = MKCoordinateRegion(center: initLocation.coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
        map.centerLocation(initLocation)
        map.overrideUserInterfaceStyle = .dark
        map.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        return map
    }()
    
    let clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "clean"), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }()
    
    let locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "you"), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
        return button
    }()
    
    let maasLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "maas"), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(maasLocationTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var bottomManager : BLTNItemManager = {
        
        var item = BLTNPageItem(title: "")
        item.image = UIImage(named: "point")
        item.actionButtonTitle = "Get directions"
        item.alternativeButtonTitle = "Close"
        item.descriptionText = itemTitle
        
        item.actionHandler = { _ in
            self.getTapped()
        }
        
        item.alternativeHandler = { _ in
            self.closeTapped()
            
        }
        item.appearance.actionButtonColor = appMainColor
        item.appearance.alternativeButtonTitleColor = appBackGroundColor
        item.appearance.titleTextColor = appBackGroundColor
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("loaded"), object: nil, queue: nil) { _ in
            item.descriptionText = self.itemTitle
            guard let safeItemTitle = self.itemTitle else {return}
            if UIImage(named: safeItemTitle) != nil {
                item.image = UIImage(named: safeItemTitle)
            } else {
                item.image = UIImage(named: "launcLogo")
            }
        }
        return BLTNItemManager(rootItem: item)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
        pinsPresenter.getMapData()
        setup()
        layout()
        
    }
    
    func setup() {
        view.addSubview(mapView)
        view.addSubview(locationButton)
        view.addSubview(clearButton)
        view.addSubview(maasLocationButton)
        bottomManager.backgroundColor = appThirdColor.withAlphaComponent(0.8)
        locationButton.isEnabled = false
        
        if let distance = userDistance(from: initLocation) {
            print("Distance: \(distance)")
            if distance < 5000 {
                locationButton.isEnabled = true
            }
        }
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
            maasLocationButton.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 28),
            maasLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
        
        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: maasLocationButton.bottomAnchor, constant: 28),
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
        
        NSLayoutConstraint.activate([
            locationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            locationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
    }
    
    
    func getTapped() {
        print("Get")
        
        
        if let distance = userDistance(from: initLocation) {
            print("Distance: \(distance)")
            if distance < 5000 {
                dismiss(animated: true)
                guard let destination = destinationCoordinate else {return}
                print(destination)
                mapView.removeOverlays(mapView.overlays)
                mapRoute(destinationCoordinate: destination)
            } else {
                dismiss(animated: true)
                let alert = UIAlertController(title: "Sorry", message: "You are too far from Maastricht", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                alert.view.tintColor = appMainColor
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        
    }
    
    func closeTapped() {
        dismiss(animated: true)
        print("Close")
    }
    
    private func userDistance(from point: CLLocation) -> Double? {
        //   guard let location = locationManger.location else {return}
        guard let userLocation = locationManger.location else {
            return nil
        }
        let pointLocation = CLLocation(
            latitude:  point.coordinate.latitude,
            longitude: point.coordinate.longitude
        )
        print(pointLocation)
        return userLocation.distance(from: pointLocation)
    }
    
}

