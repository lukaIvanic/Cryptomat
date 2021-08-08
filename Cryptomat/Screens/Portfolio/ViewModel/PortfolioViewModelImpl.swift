//
//  PortfolioViewModelImpl.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 07.08.2021..
//

import RxSwift
import RxCocoa

class PortfolioViewModelImpl: PortfolioViewModel {
    
    var portfolioDataRelay = BehaviorRelay<Portfolio>.init(value: Portfolio())
    var loadPortfolioSubject = ReplaySubject<()>.create(bufferSize: 1)
    
    var portfolioRepository: PortfolioRepository
    
    init(portfolioRepository: PortfolioRepository) {
        self.portfolioRepository = portfolioRepository
    }
    
    func initializeObservables() -> [Disposable] {
        var disposables = [Disposable]()
        disposables.append(initLoadPortfolioSubject(subject: loadPortfolioSubject))
        return disposables
    }
    
    func transferFunds(_ fromCrypto: Crypto, _ toCrypto: Crypto, _ amountInUSD: Double) -> TransactionResponse {
        return _transferFunds(fromCrypto, toCrypto, amountInUSD)
    }
    
    func transferFunds(_ toCrypto: Crypto, _ amountInUSD: Double) -> TransactionResponse {
        return _transferFunds(toCrypto, amountInUSD)
    }
    
    func getAmount(crypto: Crypto?) -> Double {
        if crypto == nil { return 0 }
        return round(99*(getAsset(crypto: crypto!)?.amountInUSD ?? 0))/100
    }
    
    func getAmount() -> Double {
        return round(99*portfolioDataRelay.value.currPortfolioRecord.fiatBalance)/100
    }
    
    func getAsset(crypto: Crypto) -> Asset? {
        return portfolioDataRelay.value.getAsset(crypto: crypto)
    }
    
    func reset(){
        savePortfolio(portfolio: Portfolio())
    }
}

extension PortfolioViewModelImpl {
    func _transferFunds(_ fromCrypto: Crypto, _ toCrypto: Crypto, _ amountInUSD: Double) -> TransactionResponse {
        if !checkCryptoBalance(crypto: fromCrypto, amountInUSD: amountInUSD) {
            return .insufficientAmount
        }
        
        let response = portfolioDataRelay.value.currPortfolioRecord.transferFunds(fromCrypto: fromCrypto, toCrypto: toCrypto, amountInUSD: amountInUSD)
        
        if response == .success {
            savePortfolio(portfolio: portfolioDataRelay.value)
        }
        return response
    }
    
    func _transferFunds(_ toCrypto: Crypto, _ amountInUSD: Double) -> TransactionResponse {
        if !checkFiatBalance(amountInUSD: amountInUSD){
            return .insufficientAmount
        }
        
        let response = portfolioDataRelay.value.currPortfolioRecord.transferFunds(toCrypto: toCrypto, amountInUSD: amountInUSD)
        
        if response == .success {
            savePortfolio(portfolio: portfolioDataRelay.value)
        }
        return response
    }
}

extension PortfolioViewModelImpl {
    func savePortfolio(portfolio: Portfolio){
        
        let defaults = UserDefaults.standard
        do {
            let encoder = JSONEncoder()
            portfolio.currPortfolioRecord.timestamp = NSDate().timeIntervalSince1970
            portfolio.portfolioRecords.append(portfolio.currPortfolioRecord)
            let data = try encoder.encode(portfolio)
            print("saving port count: \(portfolio.portfolioRecords.count)")
            defaults.setValue(data, forKey: "portfolio")
        } catch {
            print("error while saving portfolio")
        }
    }
}

extension PortfolioViewModelImpl {
    func checkCryptoBalance(crypto: Crypto, amountInUSD: Double) -> Bool {
        guard let asset = getAsset(crypto: crypto) else { return false }
        
        if amountInUSD > asset.amountInUSD {
            return false
        }
        return true
    }
    
    func checkFiatBalance(amountInUSD: Double) -> Bool {
        return amountInUSD < portfolioDataRelay.value.currPortfolioRecord.fiatBalance
    }
}

extension PortfolioViewModelImpl {
    func initLoadPortfolioSubject(subject: ReplaySubject<()>) -> Disposable {
        return subject
            .flatMap{ [unowned self] (_) -> Observable<Portfolio> in
                return self.portfolioRepository.getPortfolio()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .subscribe(onNext: { (portfolio) in
                self.portfolioDataRelay.accept(portfolio)
            })
    }
}
