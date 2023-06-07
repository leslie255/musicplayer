//
//  SongsTrackCell.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/7.
//

import UIKit

/// A table view cell for displaying a track in Songs tab
class SongsTrackCell: UITableViewCell {
    
    @IBOutlet weak var albumArtView: UIImageView!
    
    @IBOutlet weak var trackLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    func setupLayer() {
        self.albumArtView.layer.cornerRadius = 4.0
        self.albumArtView.layer.backgroundColor = UIColor.secondarySystemFill.cgColor
    }
}
