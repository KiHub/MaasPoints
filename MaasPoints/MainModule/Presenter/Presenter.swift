//
//  Presenter.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 23.05.2022.
//

import Foundation

protocol MapViewProtocol: AnyObject {
    func addPins(points: Place)
}

protocol PinsPresenterProtocol: AnyObject {
    init(networkManager: NetworkManager, mapView: MapViewProtocol)
    func getMapData()
}

class PinsPresenter: PinsPresenterProtocol {
        let networkManager: NetworkManager
        var mapView: MapViewProtocol
    
    required init(networkManager: NetworkManager, mapView: MapViewProtocol) {
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
