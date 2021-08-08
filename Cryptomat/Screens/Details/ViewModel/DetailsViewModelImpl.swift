//
//  DetailsViewModelImpl.swift
//  Cryptomat
//
//  Created by Luka Ivanić on 08.08.2021..
//
import Charts

class DetailsViewModelImpl: DetailsViewModel {
    func getGeneratedData(startingValue: Double) -> [ChartDataEntry] {
        
        let currentTimestamp = NSDate().timeIntervalSince1970 - 30 * 1000 * 60 * 60 * 24
        
        var yValues = [ChartDataEntry]()
        var lastValue = startingValue
        
        yValues.append(ChartDataEntry(x: currentTimestamp, y: startingValue))
        for i in 1...30{
            
            var change = Double(Int.random(in: 1...100))/100
            
            if Bool.random() && lastValue > change {
                change *= -1
            }
            
            let newValue = lastValue + change
            yValues.append(ChartDataEntry(x: currentTimestamp + Double(i * 1000 * 60 * 60 * 24), y: newValue))
            lastValue = newValue
        }
        
        
        return yValues
    }
}
