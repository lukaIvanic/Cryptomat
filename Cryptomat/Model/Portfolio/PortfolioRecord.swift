//
//  PortfolioRecord.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 07.08.2021..
//

import Foundation

class PortfolioRecord: Codable {
    
    var timestamp: Double
    var fiatBalance: Double
    var assets: [Asset]
    
    init(_ timestamp: Double, _ fiatBalance: Double, _ assets: [Asset]) {
        self.timestamp = timestamp
        self.fiatBalance = fiatBalance
        self.assets = assets
    }
    
    var balance: Double {
        get {
            var total = fiatBalance
            for asset in assets {
                let crypto = asset.crypto
                total += (crypto.quote?.USD.price ?? 0) * asset.amount
            }
            return total
        }
    }
    
    func transferFunds(fromCrypto: Crypto, toCrypto: Crypto, amountInUSD: Double) -> TransactionResponse {
        guard let fromIndex = getAssetIndex(crypto: fromCrypto),
              let toIndex = getAssetIndex(crypto: toCrypto),
              let fromPrice = fromCrypto.quote?.USD.price,
              let toPrice = toCrypto.quote?.USD.price else { return .unknownError}
        
        let subtractAmount = amountInUSD/fromPrice
        let addAmount = amountInUSD/toPrice
        
        if (subtractAmount > assets[fromIndex].amount) { return .insufficientAmount}

        assets[fromIndex].amount -= subtractAmount * 1.05
        assets[toIndex].amount += addAmount * 0.95
        
        return .success
    }
    
    func transferFunds(toCrypto: Crypto, amountInUSD: Double) -> TransactionResponse {
        guard let toIndex = getAssetIndex(crypto: toCrypto),
              let toPrice = toCrypto.quote?.USD.price else { return .unknownError}
        
        
        
        if (amountInUSD > fiatBalance) { return .insufficientAmount}
        
        let addAmount = amountInUSD/toPrice

        fiatBalance -= amountInUSD * 1.05
        assets[toIndex].amount += addAmount * 0.95
        
        return .success
    }
    
    func getAsset(crypto: Crypto) -> Asset? {
        for asset in assets {
            if crypto.name == asset.crypto.name {
                return asset
            }
        }
        let newAsset = Asset(crypto: crypto)
        assets.append(newAsset)
        return newAsset
    }
    
    func getAssetIndex(crypto: Crypto) -> Int? {
        for (i, asset) in assets.enumerated() {
            if crypto.name == asset.crypto.name {
                return i
            }
        }
        let newAsset = Asset(crypto: crypto)
        assets.append(newAsset)
        return assets.count - 1
    }
    
}
