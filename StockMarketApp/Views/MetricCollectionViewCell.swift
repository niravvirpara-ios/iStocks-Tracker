//
//  MetricCollectionViewCell.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 11/12/21.
//

import UIKit

/// Metric table cell
final class MetricCollectionViewCell: UICollectionViewCell {
    
    /// Cell Identifier
    static let identifier = "MetricCollectionViewCell"
    
    /// Metric table cell viewModel
    struct ViewModel {
        let name:String
        let value:String
    }
    
    /// Name label
    private let nameLable:UILabel = {
        let lable = UILabel()
        return lable
    }()
    
    /// Value label
    private let valueLable:UILabel = {
        let lable = UILabel()
        lable.textColor = .secondaryLabel
        return lable
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        addSubviews(nameLable,valueLable)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLable.sizeToFit()
        valueLable.sizeToFit()
        nameLable.frame = CGRect(
            x: 3,
            y: 0,
            width: nameLable.width,
            height: contentView.heigth
        )
        
        valueLable.frame = CGRect(
            x: nameLable.right + 3,
            y: 0,
            width: valueLable.width,
            height: contentView.heigth
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLable.text = nil
        valueLable.text = nil
    }
    
    /// Configure view
    /// - Parameter viewmodel: View ViewModel
    func configure(with viewmodel:ViewModel) {
        self.nameLable.text = viewmodel.name + ":"
        self.valueLable.text = viewmodel.value
    }
}
