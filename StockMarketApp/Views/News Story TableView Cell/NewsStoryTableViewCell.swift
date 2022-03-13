//
//  NewsStoryTableViewCell.swift
//  StockMarketApp
//
//  Created by Nirav virpara on 10/10/21.
//

import UIKit
import SDWebImage

class NewsStoryTableViewCell: UITableViewCell {

    static let identifier = "NewsStoryTableViewCell"
   
    @IBOutlet weak var sourceLable: UILabel!
    @IBOutlet weak var headlineLable: UILabel! 
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var storyImageView_height: NSLayoutConstraint!
    @IBOutlet weak var storyImageView_width: NSLayoutConstraint!
    
    /// Ideal height of cell
    static let preferredHeight:CGFloat = 140
    
    /// Cell viewmodel
    struct ViewModel {
        let source:String
        let headline:String
        let dateString:String
        let imageUrl:URL?
        
        init(model:NewsStoriesModel) {
            source = model.source
            headline = model.headline
            dateString = .string(from: model.datetime)
            imageUrl = URL(string: model.image)
        }
    }
    
    // MARK: - Init
     
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        setupLayout()
    }
     
    private func setupLayout() {
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// Image View
        let imageSize:CGFloat = contentView.heigth / 1.4
        storyImageView_width.constant = imageSize
        storyImageView_height.constant = imageSize
        storyImageView.clipsToBounds = true
        storyImageView.backgroundColor = .tertiarySystemBackground
        storyImageView.contentMode = .scaleAspectFill
        storyImageView.layer.cornerRadius = 6
        storyImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLable.text = nil
        headlineLable.text = nil
        dateLable.text = nil
        storyImageView.image = nil
    }
    
    /// Configure view
    /// - Parameter viewmodel: View ViewModel
    public func configure(with viewmodel:ViewModel)
    {
        headlineLable.text = viewmodel.headline
        sourceLable.text = viewmodel.source
        dateLable.text = viewmodel.dateString
        storyImageView.sd_setImage(with: viewmodel.imageUrl, completed: nil)
    }
}
