//
//  StockDetailHeaderView.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 11/12/21.
//

import UIKit

/// Header for stock details
final class StockDetailHeaderView: UIView {
    
    /// Metrics ViewModels
    private var metricViewModels:[MetricCollectionViewCell.ViewModel] = []
    
    // Subviews
    
    /// ChartView
    private let chartView = StockChartView()
    
    /// CollectionView
    private let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 25
         
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .secondarySystemBackground
        // Register cells
        collectionView.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: MetricCollectionViewCell.identifier)
        return collectionView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        //        chartView.backgroundColor = .link
        addSubviews(chartView,collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = CGRect(x: 0, y: 0, width: width, height: heigth - 100)
        collectionView.frame = CGRect(x: 0, y: heigth - 100, width: width, height: 100)
    }
    
    /// Configure view
    /// - Parameters:
    ///   - chartViewModel: Chart view Model
    ///   - metricViewModels: Collection of metric viewModels
    func configure(
        chartViewModel:StockChartView.ViewModel,
        metricViewModels:[MetricCollectionViewCell.ViewModel]
    ) {
        // Update Chartview
        chartView.configure(with: chartViewModel)
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate

extension StockDetailHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricCollectionViewCell.identifier, for: indexPath) as? MetricCollectionViewCell else
        {
            fatalError()
        }
        cell.configure(with: metricViewModels[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: 100/3)
    } 
}
