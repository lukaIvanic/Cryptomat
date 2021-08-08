//
//  PortfolioViewModel.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 07.08.2021..
//
import RxSwift
import RxCocoa

protocol PortfolioViewModel {

    var portfolioDataRelay: BehaviorRelay<Portfolio> {get}
    var loadPortfolioSubject: ReplaySubject<()> {get}
    
    func transferFunds(_ fromCrypto: Crypto, _ toCrypto: Crypto, _ amountInUSD: Double) -> TransactionResponse
    func transferFunds(_ toCrypto: Crypto, _ amountInUSD: Double) -> TransactionResponse
    func getAmount(crypto: Crypto?) -> Double
    func getAmount() -> Double
    func getAsset(crypto: Crypto) -> Asset?
    func reset()
    func initializeObservables() -> [Disposable]
    
}
