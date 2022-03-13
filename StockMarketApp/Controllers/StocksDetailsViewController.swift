//
//  StocksDetailsViewController.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 24/07/21.
//

import UIKit
import SafariServices

/// VC to show stock details
final class StocksDetailsViewController: UIViewController {
    
    //MARK:- Properties
    
    /// Stock Symbol
    private let symbol:String
    
    /// Company name
    private let CompanyName:String
     
    /// Collection of data
    private var candleStickData:[CandleStick]
    
    /// Primary table view
    private let tableView:UITableView = {
        let tableView =  UITableView()
        
        // Register a cell
        tableView.register(TopNewsHeaderView.self, forHeaderFooterViewReuseIdentifier: TopNewsHeaderView.identifier)
         
        tableView.register(UINib(nibName: NewsStoryTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
         
        return tableView
    }()
    
    /// Collection of news stories
    private var stories : [NewsStoriesModel] = []
    
    /// Company Metrics
    private var metrics : Metrics?
    
    // MARK: - Init
    
    init(symbol:String,
         CompanyName:String,
         candleStickData:[CandleStick] = []
    ) {
        self.symbol = symbol
        self.CompanyName = CompanyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = CompanyName
        setUpCloseButton()
        setUpTable()
        fetchFinancialData()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    } 
    
    // MARK: - Private
    
    /// Sets up close button
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.close,
            target: self,
            action: #selector(didTapClose)
        )
    }
    
    /// Handle close button tap
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Sets up table view
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(
            frame: CGRect(x: 0,y: 0,width: view.width,height: (view.width * 0.7) + 100)
        )
    }
    
    /// Fetch Financial Metric data
    private func fetchFinancialData() {
        let group = DispatchGroup()
        // Fetch candle sticks if needed
        if candleStickData.isEmpty {
            group.enter()
            ApiCaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response) :
                    self?.candleStickData = response.candleSticks
                case .failure(let error) :
                    print(error)
                }
            }
        }
        
        group.enter()
        
        ApiCaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response) :
                let metrics = response.metric
                print(metrics)
                self?.metrics = metrics
                
            case .failure(let error) :
                print(error)
                break
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }
    
    /// Fetch news for give type
    private func fetchNews() {
        ApiCaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let storiesResult):
                DispatchQueue.main.async {
                    self?.stories = storiesResult
                    self?.tableView.reloadData()
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    /// Render chart and metrics
    private func renderChart() {
        // Chart VM | FinancialMetricViewModel(s)
        
        let headerView = StockDetailHeaderView(
            frame: CGRect (x: 0,
                           y: 0,
                           width: view.width,
                           height: ( view.width * 0.7 ) + 100
            ))
        
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52W Low", value: "\(metrics.AnnualWeekLow)"))
            viewModels.append(.init(name: "52W Low Date", value: "\(metrics.AnnualWeekLowDate)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.TenDayAverageTradingVolume)"))
        }
        
        // Configure Headerview
        let changePercentage = getChangePercentage(
            symbol:symbol,
            data:candleStickData
        )
        
        headerView.configure(chartViewModel: .init(
            data: candleStickData.reversed().map { $0.close },
            showLegend: true,
            showAxisBool: true,
            fillColor: changePercentage < 0 ? .systemRed : .systemGreen
        ),
        metricViewModels: viewModels
        )
        
        tableView.tableHeaderView = headerView
    }
    
    /// Get change percentage
    /// - Parameters:
    ///   - symbol: Symbol of company
    ///   - data: Collection of data
    /// - Returns: Percentage
    private func getChangePercentage(symbol:String ,data:[CandleStick]) -> Double {
        // check data length
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
     
    private func openUrl(url:URL) {
        let safarivc = SFSafariViewController(url: url)
        present( safarivc, animated: true)
    }
    
    private func presentFailedToOpenAlert() {
        let alert = UIAlertController(
            title: "Unable to Open",
            message: "We were unable to open article",
            preferredStyle: .alert)
        
        alert.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension StocksDetailsViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell
        else {
            fatalError()
        }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TopNewsHeaderView.identifier) as? TopNewsHeaderView else {
            fatalError()
        }
        header.delegate = self
        header.configure(with: .init(title:symbol.uppercased(),
                                     shouldShowAddButton: !PersistanceManager.shared.watchlistContains(symbol: symbol)))
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TopNewsHeaderView.perferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Open News Story 
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFailedToOpenAlert()
            return
        }
        openUrl(url:url)
    }
}

// MARK: - TopNewsHeaderViewDelegate

extension StocksDetailsViewController:TopNewsHeaderViewDelegate {
    func topNewsHeaderViewDidTapAddButton(_ headerView: TopNewsHeaderView) {
        // Add to Watchlist
        
        headerView.button.isHidden = true
        PersistanceManager.shared.addToWatchList(
            symbol: symbol,
            CompanyName: CompanyName
        )
        
        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "we have added \(CompanyName) successfully to your watchlist",
            preferredStyle: .alert
        )
        
        alert.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


