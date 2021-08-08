//
//  SearchViewModelImpl.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModelImpl: SearchViewModel {
    
    var cryptosDataRelay = BehaviorRelay<[Crypto]>.init(value: [])
    var loadCryptosSubject = ReplaySubject<SearchQuery>.create(bufferSize: 1)
    
    var loaderSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    
    weak var reloadTableDelegate: ReloadTableViewDelegate?
    var searchRepository: SearchRepository
    
    init(repository: SearchRepository) {
        searchRepository = repository
    }
    
    func initializeObservables() -> [Disposable] {
        var disposables = [Disposable]()
        disposables.append(initializeLoadCryptosSubject(subject: loadCryptosSubject))
        return disposables
    }
}

extension SearchViewModelImpl {
    
    func initializeLoadCryptosSubject(subject: ReplaySubject<SearchQuery>) -> Disposable {
        return subject
            .flatMap{ [unowned self] (searchQuery) -> Observable<[Crypto]> in
                self.loaderSubject.onNext(true)
                return self.searchRepository.getAllCrypto(searchQuery)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .subscribe(onNext: { (cryptos) in
                self.cryptosDataRelay.accept(cryptos)
                
                self.loaderSubject.onNext(false)
            })
    }
}
