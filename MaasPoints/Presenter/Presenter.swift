//
//  Presenter.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 23.05.2022.
//

import Foundation


protocol MapView: AnyObject {
    func addPins(points: Place)
}

class PinsPresenter {
    
    let networkManager: NetworkManager
    var mapView: MapView
    
    
    init(networkManager: NetworkManager, mapView: MapView) {
        self.networkManager = networkManager
        self.mapView = mapView
    }
    
    func getMapData() {
        
        if let pointsJson = networkManager.getJson() {
            networkManager.parseJson(jsonData: pointsJson) { [self] result in
                switch result {
                case .success(let points):
                    mapView.addPins(points: points)
                case .failure(_):
                    print("Data error")
                }
            }
        }
    }
}
