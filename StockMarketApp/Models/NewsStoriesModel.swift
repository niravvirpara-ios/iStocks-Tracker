//
//  NewsModel.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 09/10/21.
//

import Foundation

/// Represent news story
struct NewsStoriesModel: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let id: Int
    let image: String
    let related, source, summary: String
    let url: String
}
