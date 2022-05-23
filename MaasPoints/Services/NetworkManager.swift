//
//  NetworkManager.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 23.05.2022.
//

import Foundation


class NetworkManager {
    
    
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
    
    func parseJson(jsonData: Data, completion: @escaping (Result<Place,Error>) -> Void) {
        
        do {
            let results = try JSONDecoder().decode(Place.self, from: jsonData)
            completion(.success(results))
            
        } catch {
            completion(.failure(error))
            print("Parse Json error")
        }
    }
    
    
    
}
