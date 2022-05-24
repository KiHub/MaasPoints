//
//  ModuleBuilder.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 24.05.2022.
//

import UIKit

protocol Builder {
    static func createMainModule() -> UIViewController
}

class ModuleBuilder: Builder {
    static func createMainModule() -> UIViewController {
        let networkManager = NetworkManager()
        let mapView = MapViewController()
        let pinsPresenter = PinsPresenter(networkManager: networkManager, mapView: mapView)
        mapView.pinsPresenter = pinsPresenter
        return mapView
    }
}
