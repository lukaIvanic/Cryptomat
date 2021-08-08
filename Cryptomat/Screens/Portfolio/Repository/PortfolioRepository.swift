//
//  PortfolioRepository.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 07.08.2021..
//

import Foundation
import RxSwift

protocol PortfolioRepository {
    func getPortfolio() -> Observable<Portfolio>
}
