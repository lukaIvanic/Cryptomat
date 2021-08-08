//
//  HomeViewModelImpl.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 26.07.2021..
//

import RxSwift
import RxCocoa

class HomeViewModelImpl: HomeViewModel {
    
    var cryptosDataRelay = BehaviorRelay<[Crypto]>.init(value: [])
    var moversDataRelay = BehaviorRelay<[Crypto]>.init(value: [])
    var loadCryptosSubject = ReplaySubject<()>.create(bufferSize: 1)
    
    var loaderSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    
    
    
    weak var reloadTableDelegate: ReloadTableViewDelegate?
    var cryptoRepository: CryptoRepository
    
    init(cryptoRepository: CryptoRepository) {
        self.cryptoRepository = cryptoRepository
    }
    
    func initializeObservables() -> [Disposable] {
        var disposables = [Disposable]()
        disposables.append(initializeLoadCryptosSubject(subject: loadCryptosSubject))
        return disposables
    }
    
}

private extension HomeViewModelImpl {
    
    func initializeLoadCryptosSubject(subject: ReplaySubject<()>) -> Disposable {
        return subject
            .flatMap{ [unowned self] (_) -> Observable<[Crypto]> in
                self.loaderSubject.onNext(true)
                return self.cryptoRepository.getAllCrypto()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .subscribe(onNext: { (cryptos) in
                
                var watchlistCryptos = Array(cryptos[0..<5])
                let defaults = UserDefaults.standard
                for crypto in Array(cryptos[5..<cryptos.count]) {
                    if defaults.bool(forKey: crypto.name){
                        watchlistCryptos.append(crypto)
                    }
                }
                
                self.cryptosDataRelay.accept(watchlistCryptos)
                self.moversDataRelay.accept(self.sortCryptosByChange(cryptos: cryptos))
                
                
                self.loaderSubject.onNext(false)
            })
    }
}

private extension HomeViewModelImpl {
     
    func sortCryptosByChange(cryptos: [Crypto]) -> [Crypto]{
        var sortedCryptos = cryptos
        
        
        sortedCryptos.sort { crypto1, crypto2 in
            guard let change1 = crypto1.quote?.USD.percentChange24h,
                  let change2 = crypto2.quote?.USD.percentChange24h else { return false }
            
            return abs(change1) > abs(change2)
        }
        
        return Array(sortedCryptos[0..<10])
    }
    
}
