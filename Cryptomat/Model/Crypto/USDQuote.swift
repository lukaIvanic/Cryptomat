//
//  USDQuote.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 26.07.2021..
//

import Foundation

struct USDQuote: Codable {
    let price: Double
    let percentChange24h: Double?
    let marketCap: Double?
    
    enum CodingKeys: String, CodingKey {
        case price = "price"
        case percentChange24h = "percent_change_24h"
        case marketCap = "market_cap"
    }
}
