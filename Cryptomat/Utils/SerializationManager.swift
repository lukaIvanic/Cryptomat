//
//  SerializationManager.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 26.07.2021..
//

import Foundation

class SerializationManager {
    
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    static let jsonEncoder = JSONEncoder()
    
    public func parse<T: Codable>(jsonData: Data) -> T? {
        var object: T?
        
        do {
            object = try SerializationManager.jsonDecoder.decode(T.self, from: jsonData)
        } catch  {
            print("errro: \(error)")
            object = nil
        }
        return object
        
    }
    
    public func readLocalFile (for name: String) -> Data? {
        do {
            
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8){
                return jsonData
            }
            
        }catch{
            print(error)
        }
        
        return nil
    }
    
}
