//
//  AlbumsCell.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/8.
//

import UIKit

/// A cell in AlbumsViewController
class AlbumsCell: UICollectionViewCell {
    
    @IBOutlet weak var albumArtView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    override func didMoveToSuperview() {
        self.albumArtView.layer.cornerRadius = 12.0
        self.albumArtView.layer.borderWidth = 0.5
        self.albumArtView.layer.borderColor = UIColor.secondarySystemFill.cgColor
        self.albumArtView.backgroundColor = .secondarySystemFill
    }
    
}
