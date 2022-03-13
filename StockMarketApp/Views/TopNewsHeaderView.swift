//
//  TopNewsHeaderView.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 02/10/21.
//

import UIKit

/// Delegate to notify of header events
protocol TopNewsHeaderViewDelegate:AnyObject {
    /// Notify user tappedheader button
    /// - Parameter headerView: Reference of header view
    func topNewsHeaderViewDidTapAddButton(_ headerView: TopNewsHeaderView)
}

/// Tableview header for news
final class TopNewsHeaderView: UITableViewHeaderFooterView {
    
    /// Identifier for header
    static let identifier = "TopNewsHeaderView"
     
    /// Ideal height of header
    static let perferredHeight:CGFloat = 70
    
    /// Delegate instance for events
    weak var delegate: TopNewsHeaderViewDelegate?
    
    /// ViewModel for header view
    struct ViewModel {
        let title:String
        let shouldShowAddButton:Bool
    }
    
    // MARK: - Private
    
    let lable :UILabel = {
        let lable = UILabel()
        lable.font = UIFont.boldSystemFont(ofSize: 32)
        return lable
    }()
    
    let button:UIButton = {
        let button = UIButton()
        button.setTitle("+ Watchlist", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
     
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(lable,button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
     
    override func layoutSubviews() {
        super.layoutSubviews()
        lable.frame = CGRect(x: 14, y: 0, width: contentView.width - 28, height: contentView.heigth)
        
        button.sizeToFit()
        button.frame = CGRect(
            x: contentView.width - button.width - 16,
            y: (contentView.heigth - button.heigth)/2,
            width: button.width + 8,
            height: button.heigth)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lable.text = nil
    }
     
    // MARK: - Public
    
    /// Handle button tap
    @objc private func didTapButton()
    {
        delegate?.topNewsHeaderViewDidTapAddButton(self)
    }
     
    /// Configure view
    /// - Parameter viewmodel: View ViewModel
    func configure(with viewmodel:ViewModel)
    {
        lable.text = viewmodel.title
        button.isHidden = !viewmodel.shouldShowAddButton
    }
    
}
