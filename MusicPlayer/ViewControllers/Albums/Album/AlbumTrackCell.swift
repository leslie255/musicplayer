//
//  AlbumTrackCell.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/7.
//

import UIKit

class AlbumTrackCell: UITableViewCell {

    @IBOutlet weak var numLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func setSelected(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = .systemFill
        } else if animated {
            UIView.animate(withDuration: 0.4) {
                self.backgroundColor = .systemBackground
            }
        } else {
            self.backgroundColor = .systemBackground
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.backgroundColor = .systemFill
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if self.backgroundColor != .systemBackground {
            self.backgroundColor = .systemBackground
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if self.backgroundColor != .systemBackground {
            self.backgroundColor = .systemBackground
        }
    }
    
}
