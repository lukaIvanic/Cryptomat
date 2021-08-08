//
//  Asset.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

import Foundation

struct Asset: Codable {
    var crypto: Crypto
    var amount: Double = 0
    
    var amountInUSD: Double {
        get {
            return amount * (crypto.quote?.USD.price ?? 0)
        }
    }
}
