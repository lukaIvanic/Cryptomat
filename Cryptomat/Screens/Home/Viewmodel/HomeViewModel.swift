//
//  HomeViewModel.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 26.07.2021..
//

import RxSwift
import RxCocoa


protocol HomeViewModel {
    
    var reloadTableDelegate: ReloadTableViewDelegate? {get set}
    
    var loaderSubject: ReplaySubject<Bool> {get}
    
    var cryptosDataRelay: BehaviorRelay<[Crypto]> {get}
    var loadCryptosSubject: ReplaySubject<()> {get}
    
    var moversDataRelay: BehaviorRelay<[Crypto]> {get}
    
    
    func initializeObservables() -> [Disposable]
    
}


