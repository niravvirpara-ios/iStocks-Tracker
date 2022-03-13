//
//  ViewController.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 24/07/21.
//

import FloatingPanel
import UIKit

/// VC to render user watch list
class WatchListViewController: UIViewController {
    
    /// Floating news panel
    private var floatingPanel:FloatingPanelController?
    
    /// Width to track change label
    static var maxChangeWidth:CGFloat = 0
     
    /// Model
    private var watchlistMap:[String: [CandleStick]] = [:]
    
    /// View Model
    private var viewModels : [WatchListTableViewCell.ViewModel] = []
    
    /// Main table view to render watch list
    private let watchListTableView :UITableView = {
        let tableView = UITableView()
        tableView.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        return tableView
    }()
    
    /// Observer to watch list updates
    private var observer:NSObjectProtocol?
    
    // MARK:- Lifecycle
    
    /// Called when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpWatchlistTableView()
        fetchWatchlistData()
        setupFloatingPanel()
        setUpTitleView()
        setUpNotificationObserver()
    }
    
    /// Layout subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        watchListTableView.frame = view.bounds
    }
    
    //    MARK:- Private
    
    /// Sets up observer for watch list updates
    private func setUpNotificationObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.didAddToWatchList,
            object: nil,
            queue: OperationQueue.main,
            using: { [weak self] _ in
                self?.viewModels.removeAll()
                self?.fetchWatchlistData()
            })
    }
    
    /// Fetch watch list models
    private func fetchWatchlistData() {
        let symbols = PersistanceManager.shared.watchList
        print("Symbols in Watchlist \(symbols)")
        let group = DispatchGroup()
        
        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            /// Fetch market data per symbol
            ApiCaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data) :
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error) :
                    print(error)
                    break
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.watchListTableView.reloadData()
        }
    }
    
    /// Create view models from models
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        for (symbol,candleSticks) in watchlistMap {
            let changePercentage = getChangePercentage(
                symbol:symbol,
                data:candleSticks
            )
            
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company", price: getLatestClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: String.percentage(from: changePercentage), chartViewModel: .init(
                        data: candleSticks.reversed().map { $0.close },
                        showLegend: false,
                        showAxisBool: false,
                        fillColor: changePercentage < 0 ? .systemRed : .systemGreen
                    )
                )
            )
        }
         
        self.viewModels = viewModels
    }
    
    /// Gets change percentage for symbol data
    /// - Parameters:
    ///   - symbol: Symbol to check for
    ///   - data: Collection of candle data
    /// - Returns: Double percentage
    private func getChangePercentage(symbol:String ,data:[CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                !Calendar.current.isDate($0.date , inSameDayAs: latestDate)
              })?.close else {
            return 0
        }
      
        let diff = 1 - (priorClose/latestClose)
        return diff
    }
    
    /// Get latest closing price
    /// - Parameter data: Collection of candel data
    /// - Returns: String
    private func getLatestClosingPrice(from data:[CandleStick]) -> String
    {
        guard  let closingPrice = data.first?.close else {
            return ""
        }
        return String.formatted(number: closingPrice)
    }
    
    /// Sets up watchlist table view
    private func setUpWatchlistTableView() {
        view.addSubview(watchListTableView)
        watchListTableView.delegate = self
        watchListTableView.dataSource = self
    }
     
    /// Sets up floating news panel
    private func setupFloatingPanel() {
        let topNewsVC = TopNewsViewController(type: .topStories)
        let panel = FloatingPanelController()
        panel.delegate = self
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: topNewsVC)
        panel.addPanel(toParent: self)
        panel.track(scrollView: topNewsVC.NewstableView)
    }
    
    /// Sets up custom title view
    private func setUpTitleView() {
        let titleView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: self.navigationController?.navigationBar.heigth ?? 100
            )
        )
        
        let lable = UILabel(frame: CGRect(x:10,
                                          y: 0,
                                          width: titleView.width - 20,
                                          height: titleView.heigth))
        
        lable.font = UIFont.systemFont(ofSize: 35, weight: .medium)
        lable.text = "Stocks"
        titleView.addSubview(lable)
        
        self.navigationItem.titleView = titleView
    }
    
    /// Sets up search and result controller
    private func setUpSearchController() {
        let searchresultVC = SearchResultsViewController()
        searchresultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: searchresultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}

// MARK: - Extension

// MARK: - UITableViewDelegate

extension WatchListViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            
            // Update persistance
            PersistanceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)
            // Update viewmodels
            viewModels.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    /// Redirect to Stock Details
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewModel = viewModels[indexPath.row]
        
        let stockDetailsVC = StocksDetailsViewController(
            symbol: viewModel.symbol,
            CompanyName: viewModel.companyName,
            candleStickData: watchlistMap[viewModel.symbol] ?? [])
        
        let navVC = UINavigationController(rootViewController: stockDetailsVC)
        present(navVC, animated: true)
    } 
    
}

// MARK: - UISearchResultsUpdating Extension

extension WatchListViewController: UISearchResultsUpdating {
    
    /// Update search on key tap
    /// - Parameter searchController: Reference of search controller
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text ,
              let searchresultVC = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let queryLength:Int = query.count
        if(queryLength >= 3)
        {
            ApiCaller.shared.searchSymbol(query: query) { (result) in
                switch(result){
                case .success(let response) :
                    print(response.result)
                    DispatchQueue.main.async {
                        searchresultVC.update(with: response.result)
                    }
                    break
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        searchresultVC.update(with: [])
                    }
                    break
                }
            }
        }
        
    }
    
}

// MARK: - SearchResultsViewControllerDelegate

extension WatchListViewController:SearchResultsViewControllerDelegate
{
    /// Notify of search result selection
    /// - Parameter searchResult: search result that was selected
    func SearchResultsViewControllerDidSelect(searchResult: SeachResult) {
        //        print("Selected Symbol \(searchResult.displaySymbol)")
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let vc = StocksDetailsViewController(
            symbol: searchResult.displaySymbol,
            CompanyName: searchResult.description,
            candleStickData: []
        ) 
        
        let StocksDetailsnavVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(StocksDetailsnavVC, animated: true)
    }
}

// MARK: - FloatingPanelControllerDelegate

extension WatchListViewController:FloatingPanelControllerDelegate
{
    /// Gets floating panel state change
    /// - Parameter fpc: Referenece of floating panel
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full 
    }
}

// MARK: - WatchListTableViewCellDelegate
extension WatchListViewController:WatchListTableViewCellDelegate{
    /// Notify delegate of change label width
    func didUpdateMaxWidth() {
        // Optimize the only rows prior to the current row that changes the max width
        watchListTableView.reloadData()
    }
}
