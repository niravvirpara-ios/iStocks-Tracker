//
//  SearchResultsViewController.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 24/07/21.
//

import UIKit

/// Delegate for search results
protocol SearchResultsViewControllerDelegate:AnyObject {
    /// Notify delegate of selection
    /// - Parameter searchResult: Result for symbol that was picked
    func SearchResultsViewControllerDidSelect(searchResult:SeachResult)
}

/// VC to show search results
final class SearchResultsViewController: UIViewController {
    
    /// Delegate to get events
    weak var delegate : SearchResultsViewControllerDelegate?
    
    /// Collection of results
    var results:[SeachResult] = []
    
    private let searchResultTableView : UITableView = {
        let table = UITableView()
        // Register a cell
        table.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        table.isHidden = true
        return table
    }()
    
    // MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultTableView.frame = view.bounds
    }
    
    // MARK: - Private
    
    /// Sets up table view
    func setUpTable()  {
        view.addSubview(searchResultTableView)
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
    }
    
    // MARK: - Public
    
    /// Update result on VC
    /// - Parameter results: Collection of new results
    public func update(with results:[SeachResult])  {
        self.results = results
        searchResultTableView.isHidden = results.isEmpty
        searchResultTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate

extension SearchResultsViewController:UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCell(
            withIdentifier: SearchResultTableViewCell.identifier,
            for: indexPath) as! SearchResultTableViewCell
        
        let model = self.results[indexPath.row]
        
        cell.title.text = model.symbol
        cell.subTitle.text = model.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.results[indexPath.row]
        delegate?.SearchResultsViewControllerDidSelect(searchResult: model)
    }
    
}
