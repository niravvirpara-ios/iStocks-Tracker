//
//  PersistanceManager.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 24/07/21.
//

import Foundation

/// Object to manage saves caches
final class PersistanceManager {
    /// Singleston
    static let shared = PersistanceManager()
    
    /// Reference to user defaults
    private let userDefaults:UserDefaults = UserDefaults.standard
    
    /// Constants
    struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }
    
    /// Private constructor
    private init() {}
    
    //MARK:- Public
    
    /// Get user watch list
    public var watchList : [String] {
        if(!hasOnboarded) {
            userDefaults.set(true,forKey: Constants.onboardedKey)
            setDefaultWatchlist()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }
    
    /// Check watchlist contain symbol
    /// - Parameter symbol: Symbol to check
    /// - Returns: Boolean
    public func watchlistContains(symbol:String) -> Bool {
        return watchList.contains(symbol)
    }
    
    /// Add symbol to watchlist
    /// - Parameters:
    ///   - symbol: Symbol to add
    ///   - CompanyName: Company name for symbol being added
    public func addToWatchList(symbol:String,CompanyName:String) {
        var currentWatchlist  = watchList
        currentWatchlist.append(symbol)
        userDefaults.set(currentWatchlist, forKey: Constants.watchlistKey)
        userDefaults.set(CompanyName,forKey: symbol)
        
        NotificationCenter.default.post(name: Notification.Name.didAddToWatchList, object: nil)
    }
    
    /// Remove symbol to watchlist
    /// - Parameter symbol: Symbol to remove
    public func removeFromWatchList(symbol:String) {
        var newList = [String]()
        
        userDefaults.set(nil, forKey: symbol)
        for item in watchList where item != symbol {
            newList.append(item)
        }
        
        userDefaults.set(newList,forKey: Constants.watchlistKey)
    }
    
    //MARK:- Private
    
    /// Check if user has been onboarded
    private var hasOnboarded:Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    /// Set up default watch list
    private func setDefaultWatchlist()
    {
        let defaultWatchlist:[String:String] = [
            "AAPL" : "Apple Inc",
            "MSFT" : "Microsoft Corporation",
            "SNAP" : "Snap Inc",
            "GOOG" : "Alphabet",
            "AMZN" : "Amazon.com, Inc.",
            "FB"   : "Facebook Inc.",
            "NVDA" : "Nvidia Inc.",
            "NKE" : "Nike",
            "PINS" : "Pinterest Inc."
        ]
        
        let symbols = defaultWatchlist.keys.map { $0 }
        
        userDefaults.set(symbols, forKey: Constants.watchlistKey)
        
        for (symbol,name) in defaultWatchlist {
            userDefaults.set(name,forKey: symbol)
        }
    }
    
}
