//
//  FinancialMetricsResponse.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 11/12/21.
//

import Foundation

/// Matrics response from API
struct FinancialMetricsModel: Codable {
    let metricType:String
    let metric: Metrics
}

/// Financial metrics
struct Metrics: Codable {
    
    let AnnualWeekHigh : Double
    let TenDayAverageTradingVolume:Double
    let AnnualWeekLow:Double
    let AnnualWeekLowDate:String
    let AnnualWeekPriceReturnDaily:Double
    let beta:Float
    
    enum CodingKeys: String, CodingKey {
        case AnnualWeekHigh = "52WeekHigh"
        case AnnualWeekLow = "52WeekLow"
        case AnnualWeekLowDate = "52WeekLowDate"
        case AnnualWeekPriceReturnDaily = "52WeekPriceReturnDaily"
        case beta = "beta"
        case TenDayAverageTradingVolume = "10DayAverageTradingVolume"
    }
}
