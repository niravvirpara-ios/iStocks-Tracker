//
//  SearchSymbolResponse.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 25/09/21.
//

import Foundation

/// API response for search
struct SearchSymbolResponse: Codable {
    let count: Int
    let result: [SeachResult]
}

/// Single search result
struct SeachResult: Codable {
    let description, displaySymbol, symbol, type : String
}
 
