//
//  APICaller.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 24/07/21.
//

import Foundation
import Alamofire

/// Object to manage api calls
final class ApiCaller
{
    /// Singleton
    public static let shared = ApiCaller()
    
    /// Private constructor
    private init() {
        
    }
    
    // MARK:- Public
    
    /// Search for company
    /// - Parameters:
    ///   - query: Query string (symbol or name)
    ///   - completion: Result callback
    public func searchSymbol(
        query:String,
        completion: @escaping( Result<SearchSymbolResponse,Error> ) -> Void
    ){
        guard let safequery = query.addingPercentEncoding(
                withAllowedCharacters: .urlUserAllowed)
        else { return }
        
        guard  let url = url(
                for: .search,
                queryParam: ["q":safequery])
        else {
            return
        }
        
        getRequest(url: url,
                   expecting: SearchSymbolResponse.self,
                   completion: completion)
    }
    
    /// Get news for type
    /// - Parameters:
    ///   - type: Company or top stories
    ///   - completion: Result callback
    public func news(
        for type:TopNewsViewController.`Type`,
        completion:@escaping( Result<[NewsStoriesModel],Error> ) -> Void
    ){
        switch type
        {
        case .topStories:
            guard  let url = url(
                    for: .topStories,
                    queryParam: ["category":"general"])
            else {
                return
            }
            
            print(url)
            
            getRequest(url: url,
                       expecting: [NewsStoriesModel].self,
                       completion: completion)
            break
        case .company(let symbol):
            
            let today = Date()
            let onemonthBack = Date().addingTimeInterval(-( Constants.day * 30 ))
            
            guard  let url = url(
                    for: .companyNews,
                    queryParam: [
                        "symbol":symbol,
                        "from": DateFormatter.newsDateFormatter.string(from: onemonthBack),
                        "to":DateFormatter.newsDateFormatter.string(from: today)
                    ])
            else {
                return
            }
            getRequest(url: url,
                       expecting: [NewsStoriesModel].self,
                       completion: completion)
            break
        }
    }
    
    /// Get market data
    /// - Parameters:
    ///   - symbol: Given symbol
    ///   - numberOfDays: Number of days back from today
    ///   - completion: Result callback
    public func marketData(
        for symbol:String,
        numberOfDays: TimeInterval = 7,
        completion:@escaping (Result<MarketDataResponse , Error>) -> Void
    ) {
        let today = Date().addingTimeInterval(-( Constants.day * 2))
        let prior = today.addingTimeInterval(-( Constants.day * numberOfDays ))
        
        guard  let url = url(
                for: .markertData,
                queryParam: [
                    "symbol":symbol,
                    "resolution":"1",
                    "from": "\(Int(prior.timeIntervalSince1970))",
                    "to": "\(Int(today.timeIntervalSince1970))",
                ])
        else {
            return
        }
        
        getRequest(url: url,
                   expecting: MarketDataResponse.self,
                   completion: completion)
    }
    
    /// Get financial metrics
    /// - Parameters:
    ///   - symbol: Symbol of company
    ///   - completion: Result callback
    public func financialMetrics(
        for symbol:String,
        completion:@escaping(Result<FinancialMetricsModel,Error>) -> Void
    ){
        guard  let url = url(
                for: .financialsData,
                queryParam: [ "symbol":symbol,"metric":"all"])
        else {
            return
        }
        
        getRequest(url: url,
                   expecting: FinancialMetricsModel.self,
                   completion: completion)
        
    }
    
    // MARK:- Private Function
    
    /// Api Endpoints
    private enum Endpoint:String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case markertData = "stock/candle"
        case financialsData = "stock/metric"
    }
    
    /// Api Errors
    private enum ApiError:Error {
        case invalidUrl
        case noDataReturned
    }
    
    /// Create url for endpoint
    /// - Parameters:
    ///   - endpoint: Endpoint to create
    ///   - queryParam: Additional query arguments
    /// - Returns: Optional URL
    private func url(
        for endpoint:Endpoint,
        queryParam:[String:String] = [:]
    ) -> URL?
    {
        var urlString = Constants.baseApi + endpoint.rawValue
        var queryItems = [URLQueryItem]()
        
        for (name , value) in queryParam {
            queryItems.append(.init(name: name, value: value))
        }
        
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        
        urlString += "?" + queryString
        return URL(string: urlString)
    }
    
 
    /// Get Api Method using Alamofire
    /// - Parameters:
    ///   - url: URL to fetch data
    ///   - expecting: Type we expect to decode data
    ///   - completion: Result callback
    func getRequest<T:Codable>(url:URL?, expecting: T.Type, completion:@escaping (Result<T,Error>) -> Void ) {
        
        guard let url = url else {
            completion(.failure(ApiError.invalidUrl))
            return
        }
        
        AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response
        {
            (response) in
              
            guard let data = response.data , response.error == nil else {
                if let error = response.error {
                    completion(.failure(error))
                }
                else {
                    completion(.failure(ApiError.noDataReturned))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
             
        }
    }
    
    
    /// Get Api Method using Url Session
    /// - Parameters:
    ///   - url: URL to fetch data
    ///   - expecting: Type we expect to decode data
    ///   - completion: Result callback
    private func getRequest_urlsession<T:Codable>(
        url:URL?,
        expecting:T.Type,
        completion: @escaping (Result<T,Error>) -> Void
    )
    {
        guard let url = url else {
            completion(.failure(ApiError.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data , error == nil else {
                if let error = error {
                    completion(.failure(error))
                }
                else {
                    completion(.failure(ApiError.noDataReturned))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}
