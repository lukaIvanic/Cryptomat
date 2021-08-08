//
//  Portfolio.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 07.08.2021..
//

import Foundation

class Portfolio: Codable {
    
    var portfolioRecords: [PortfolioRecord]
    var currPortfolioRecord: PortfolioRecord {
        get {
            return portfolioRecords.last!
        }
    }
    
    init(portfolioRecords: [PortfolioRecord] = []) {
        self.portfolioRecords = portfolioRecords
        
        if self.portfolioRecords.isEmpty {
            self.portfolioRecords.append(
                PortfolioRecord(NSDate().timeIntervalSince1970,
                                100,
                                [Asset(crypto: Crypto(name: "Bitcoin",symbol: "BTC",quote: Quotes(USD: USDQuote(price: 42000, percentChange24h: 1, marketCap: 100)), max_supply: 1000, circulating_supply: 1000, total_supply: 1000), amount: 0.05)]))
        }
        
    }
    
    func getAsset(crypto: Crypto) -> Asset? {
        return currPortfolioRecord.getAsset(crypto: crypto)
    }
    
}
