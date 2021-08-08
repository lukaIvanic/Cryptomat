//
//  CryptoRepositoryImpl.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 26.07.2021..
//

import RxSwift

class CryptoRepositoryImpl: CryptoRepository {
    
    
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getAllCrypto() -> Observable<[Crypto]> {
        return networkManager.getAllCryptos()
    }
    
}
