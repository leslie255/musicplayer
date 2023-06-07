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
    
    func setupLayer() {
        self.layer.cornerRadius = 12.0
        self.layer.backgroundColor = UIColor.secondarySystemFill.cgColor
    }
    
}
