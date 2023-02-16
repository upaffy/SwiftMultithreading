//
//  NewsListCell.swift
//  NewsApp
//
//  Created by Pavlentiy on 05.02.2023.
//

import UIKit

class FoxListCell: UITableViewCell {
   
    @IBOutlet weak var foxImage: UIImageView!
    @IBOutlet weak var foxTitle: UILabel!
    
    private let defaultImageSystemName = "photo"
    
    static let reuseId = "FoxListCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.layer.cornerRadius = 5
        contentView.backgroundColor = .white
        foxImage.layer.cornerRadius = 5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let margins = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        contentView.frame = contentView.frame.inset(by: margins)
    }
    
    func configure(with fox: Fox) {
        self.foxTitle.text = fox.name
        
        var unfilteredImage: UIImage?
        
        imageManager.fetchImage(from: fox.imageURL) { result in
            switch result {
            case .success(let imageData):
                unfilteredImage = UIImage(data: imageData)
            case .failure(_):
                break
            }
        }
        
        imageManager.filterImage(unfilteredImage) { filteredImage in
            self.foxImage.image = filteredImage ?? UIImage(systemName: self.defaultImageSystemName)
        }
    }
}
