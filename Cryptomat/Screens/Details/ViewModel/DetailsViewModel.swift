//
//  DetailsViewModel.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//

import Charts

protocol DetailsViewModel {
    func getGeneratedData(startingValue: Double) -> [ChartDataEntry]
}
