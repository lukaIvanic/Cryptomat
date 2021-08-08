//
//  CryptoRepository.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 26.07.2021..
//

import RxSwift

protocol CryptoRepository {
    
    func getAllCrypto() -> Observable<[Crypto]>
    
}
