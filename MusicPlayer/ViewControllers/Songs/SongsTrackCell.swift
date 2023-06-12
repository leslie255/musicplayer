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
    
    func setupLayers() {
        self.albumArtView.layer.cornerRadius = 4.0
        self.albumArtView.backgroundColor = .secondarySystemFill
    }
    
    override func setSelected(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = .secondarySystemBackground
        } else if animated {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = .systemBackground
            }
        } else {
            self.backgroundColor = .systemBackground
        }
    }
    
}
