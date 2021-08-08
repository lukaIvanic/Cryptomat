//
//  SearchRepositorz.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

import RxSwift

protocol SearchRepository {
    func getAllCrypto(_ searchQuery: SearchQuery) -> Observable<[Crypto]>
}
