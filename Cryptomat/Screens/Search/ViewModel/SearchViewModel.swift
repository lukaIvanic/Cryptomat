//
//  SearchViewModel.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

import Foundation
import RxSwift
import RxCocoa

protocol SearchViewModel {
    var reloadTableDelegate: ReloadTableViewDelegate? {get set}
    
    var loaderSubject: ReplaySubject<Bool> {get}
    
    var cryptosDataRelay: BehaviorRelay<[Crypto]> {get}
    var loadCryptosSubject: ReplaySubject<SearchQuery> {get}
    
    func initializeObservables() -> [Disposable]
}
