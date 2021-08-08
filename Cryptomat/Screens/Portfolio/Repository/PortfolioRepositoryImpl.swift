//
//  PortfolioRepositoryImpl.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 07.08.2021..
//

import RxSwift

class PortfolioRepositoryImpl: PortfolioRepository {
    
    func getPortfolio() -> Observable<Portfolio> {
        let defaults = UserDefaults.standard
        if let portfolioData = defaults.data(forKey: "portfolio"),
           let portfolio: Portfolio = SerializationManager().parse(jsonData: portfolioData){
            
            return Observable.just(portfolio)
        }
        return Observable.just(Portfolio())
    }
    
}
