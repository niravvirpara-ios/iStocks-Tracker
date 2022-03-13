//
//  WatchListTableViewCell.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 27/11/21.
//

import UIKit

/// Delegate to notify of cell events
protocol WatchListTableViewCellDelegate:AnyObject {
    func didUpdateMaxWidth()
}

/// Table view cell for watchlist
final class WatchListTableViewCell: UITableViewCell {
    
    /// Cell Identifier
    static let identifier = "WatchListTableViewCell"
    
    /// Delegate
    weak var delegate:WatchListTableViewCellDelegate?
     
    /// Ideal height of cell
    static let preferredHeight : CGFloat = 60
    
    /// Watchlist tableview cell viewmodel
    struct ViewModel {
        let symbol:String
        let companyName:String
        let price:String // formatted
        let changeColor:UIColor // red or green
        let changePercentage:String // formatted
        let chartViewModel: StockChartView.ViewModel
    }
    
    /// Symbol Lable
    private let symbolLabel:UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 16,weight:.regular)
        return lable
    }()
    
    /// Company Lable
    private let nameLabel:UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 15,weight:.medium)
        return lable
    }()
    
    /// Price Lable
    private let priceLabel:UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 15,weight:.regular)
        lable.textAlignment = .right
        return lable
    }()
    
    /// Change in Price Lable
    private let changeLabel:UILabel = {
        let lable = UILabel()
        lable.textAlignment = .right
        lable.textColor = .white
        lable.font = .systemFont(ofSize: 15,weight:.regular)
        lable.layer.masksToBounds = true
        lable.layer.cornerRadius = 6
        return lable
    }()
    
    /// MiniChart View
    private let miniChartView  : StockChartView = {
        let chartView = StockChartView()
        chartView.isUserInteractionEnabled = false
        chartView.clipsToBounds = true
        return chartView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubviews(
            symbolLabel,
            nameLabel,
            miniChartView,
            priceLabel,
            changeLabel
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
        
        let yStart:CGFloat = (contentView.heigth - symbolLabel.heigth - nameLabel.heigth) / 2
        
        symbolLabel.frame = CGRect(
            x: separatorInset.left,
            y: yStart,
            width: symbolLabel.width,
            height: symbolLabel.heigth
        )
        
        nameLabel.frame = CGRect(
            x: separatorInset.left,
            y: symbolLabel.bottom,
            width: nameLabel.width,
            height: nameLabel.heigth
        )
        
        let currentWidth = max(
            max(priceLabel.width,changeLabel.width),
            WatchListViewController.maxChangeWidth
        )
        
        if(currentWidth > WatchListViewController.maxChangeWidth) {
            WatchListViewController.maxChangeWidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }
        
        priceLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: (contentView.heigth - priceLabel.heigth - changeLabel.heigth)/2,
            width: priceLabel.width,
            height: priceLabel.heigth
        )
        
        changeLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: priceLabel.bottom,
            width: changeLabel.width,
            height: changeLabel.heigth
        )
        
        miniChartView.frame = CGRect(
            x: priceLabel.left - (contentView.width/3) - 5,
            y: 6,
            width: contentView.width/3,
            height: contentView.heigth - 12
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    /// Configure view
    /// - Parameter viewModel: View ViewModel
    public func configure(with viewModel:ViewModel)
    {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        miniChartView.configure(with: viewModel.chartViewModel)
    } 
}
