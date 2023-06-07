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
    
    func setupLayer() {
        self.albumArtView.layer.cornerRadius = 16
        self.albumArtView.layer.backgroundColor = UIColor.secondarySystemFill.cgColor
    }

}
