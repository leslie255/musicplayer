//
//  SongsViewController.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/7.
//

import UIKit

class SongsViewController: UITableViewController {
    
    @IBOutlet var mainTableView: UITableView!
    
    let placeholderData: [(String, String, UIImage?)] = [
        ("Wonderwall", "Oasis", nil),
        ("Everybody Wants To Rule The World", "Tears For Fears", nil),
    ]
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.placeholderData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTrackCell", for: indexPath) as! SongsTrackCell
        let (track, artist, albumArt) = self.placeholderData[indexPath.row]
        cell.setupLayer()
        cell.trackLabel.text = track
        cell.artistLabel.text = artist
        let albumArtImage = albumArt ?? UIImage(systemName: "music.note")!
        cell.albumArtView.image = albumArtImage
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }

}
