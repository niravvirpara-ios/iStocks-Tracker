//
//  TopStoriesViewController.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 02/10/21.
//

import UIKit
import SafariServices

/// Controller to show news
final class TopNewsViewController: UIViewController {
    
    /// Type of news
    enum `Type` {
        case topStories
        case company(symbol:String)
        
        /// Title for given type
        var title:String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    // MARK: - Properties
    
    /// Collection of models
    private var stories = [NewsStoriesModel]()
    
    /// instance of type
    private let type:Type
    
    /// Primary News table view
    let NewstableView : UITableView = {
        let table  = UITableView()
        table.backgroundColor = .clear
        
        // Register Cell , Header
        table.register(UINib(nibName: NewsStoryTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
          
        table.register(TopNewsHeaderView.self, forHeaderFooterViewReuseIdentifier: TopNewsHeaderView.identifier)
        return table
    }()
    
    
    // MARK: - Initialize
    
    /// Create VC with type
    /// - Parameter type: Type of VC from topStories and company
    init(type:Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NewstableView.frame = view.bounds
    }
    
    // MARK: - Private
    
    /// Set up News table view
    func setupTable()
    {
        view.addSubview(NewstableView)
        NewstableView.delegate = self
        NewstableView.dataSource = self
    }
    
    /// Fetch news models
    func fetchNews()
    {
        ApiCaller.shared.news(for: .topStories) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.NewstableView.reloadData()
                }
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    /// Open news article
    /// - Parameter url: News article url
    private func openUrl(url:URL) {
        let safarivc = SFSafariViewController(url: url)
        present( safarivc, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension TopNewsViewController:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier,for: indexPath) as! NewsStoryTableViewCell
        
        cell.configure(with: NewsStoryTableViewCell.ViewModel(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header =  tableView.dequeueReusableHeaderFooterView(withIdentifier: TopNewsHeaderView.identifier) as? TopNewsHeaderView
        else {
            return nil
        }
        
        header.configure(with: TopNewsHeaderView.ViewModel(
            title: self.type.title,
            shouldShowAddButton: false
        ))
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TopNewsHeaderView.perferredHeight
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Open News Story
        let story = stories[indexPath.row]
        
        guard let url = URL(string: story.url) else {
            presentFailedToOpenAlert()
            return
        }
        openUrl(url:url)
    }
    
    /// Present alert when unable to open news article
    private func presentFailedToOpenAlert() {
        let alert = UIAlertController(
            title: "Unable to Open",
            message: "We were unable to open article",
            preferredStyle: .alert)
        
        alert.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}
