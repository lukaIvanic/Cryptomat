//
//  Crypto.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 26.07.2021..
//

import Foundation

struct Crypto: Codable {
    
    var name: String
    let symbol: String
    let quote: Quotes?
    let max_supply: Double?
    let circulating_supply: Double?
    let total_supply: Double?
    
}
