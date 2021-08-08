//
//  SearchRepositoryImpl.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

import Foundation
import RxSwift

class SearchRepositoryImpl: SearchRepository {
    
    
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getAllCrypto(_ searchQuery: SearchQuery) -> Observable<[Crypto]> {
        
        let observable = Observable<[Crypto]>.create { observer in
            self.networkManager.getAllCryptos()
                .subscribe { cryptos in
                    observer.onNext(self.filterWithQuery(cryptos: cryptos, searchQuery: searchQuery))
                    observer.onCompleted()
                } onError: { error in
                    print("repository error: \(error)")
                }
            
            return Disposables.create ()
        }
        
        return observable
    }
    
}

extension SearchRepositoryImpl {
    
    private func filterWithQuery(cryptos: [Crypto], searchQuery: SearchQuery) -> [Crypto] {
    
        guard let safeQuery = searchQuery.text else { return cryptos }
    
        var returnCryptos = cryptos.filter { cryptos in
            if safeQuery != "" &&
                !(cryptos.name.lowercased().contains(safeQuery.lowercased()) || cryptos.symbol.lowercased().contains(safeQuery.lowercased()))
            {
                return false
            }
            
            
            switch searchQuery.type {
                case .All:
                    return true
                case .Gainers:
                    return cryptos.quote?.USD.percentChange24h ?? 0 > 0
                case .Losers:
                    return cryptos.quote?.USD.percentChange24h ?? 0 < 0
            }
        }
        if returnCryptos.count == 0{
            returnCryptos.append(Crypto(name: "No cryptocurrencies found", symbol: "", quote: nil, max_supply: nil, circulating_supply: nil, total_supply: nil))
        }
        return returnCryptos
    }
    
    
    
}
