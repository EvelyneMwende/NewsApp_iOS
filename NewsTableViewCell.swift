//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Eclectics on 18/03/2022.
//

import UIKit
class NewsTableViewCellViewModel {
    let title:String
    let subtitle:String
    let imageURL: URL?
    //cache data after downloading the image so we dont do it over and over
    //initially its going to be nil cause you havent fetched any data
    var imageData: Data? = nil
    
    init(
        title:String,
        subtitle:String,
        imageURL: URL?
    ){
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        
}
}

class NewsTableViewCell: UITableViewCell {

    //register our cell to the table
    static let identifier = "NewsTableViewCell"
    
    // subviews
    private let newsTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .light)
        return label
    }()
    
    private let newsImageView: UIImageView={
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //add subviews
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(newsImageView)
    }
    
    required init?(coder: NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //giving subviews a frame
        newsTitleLabel.frame = CGRect(
              x: 10,
              y: 0,
              width: contentView.frame.size.width - 170,
              height: 70
        )
        
        subtitleLabel.frame = CGRect(
              x: 10,
              y: 70,
              width: contentView.frame.size.width - 170,
              height:contentView.frame.size.height/2
        )
        
        newsImageView.frame = CGRect(
              x: contentView.frame.size.width - 150,
              y: 5,
              width: 140,
              height:contentView.frame.size.height - 10 //5-point margin at top and bottom
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsTitleLabel.text = nil
        subtitleLabel.text = nil
        newsImageView.image = nil
        
    }
    
    //configure cells with a viewmodel
    func configure(with viewModel: NewsTableViewCellViewModel ){
        newsTitleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        
        //image
        if let data = viewModel.imageData{
            newsImageView.image = UIImage(data: data)
            
        }else if let url = viewModel.imageURL{
            //fetch image
            URLSession.shared.dataTask(with: url){
                [weak self] data, _, error in
                guard let data = data, error == nil else {
                    //if the image wasn't downloaded
                    return
                }
                
                //if download was successful
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}
