//
//  AlbumBannerCell.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/7.
//

import UIKit

class AlbumBannerCell: UITableViewCell {

    @IBOutlet weak var albumArtView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var genreLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    override func didMoveToSuperview() {
        self.albumArtView.layer.cornerRadius = 12
        self.albumArtView.layer.borderWidth = 0.5
        self.albumArtView.layer.borderColor = UIColor.secondarySystemFill.cgColor
        self.albumArtView.backgroundColor = .secondarySystemFill
    }

}
