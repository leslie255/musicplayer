//
//  AlbumViewController.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/7.
//

import UIKit

class AlbumViewController: UITableViewController {
    
    @IBOutlet var mainTableView: UITableView!
    
    var album: Album! = nil
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.album.tracks.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // the banner cell
            return self.banner_cell(
                image: nil,
                name: album.name,
                artist: album.artist,
                genre: album.genre
            )
        }
        
        if let trackID = self.album.tracks[checked: indexPath.row - 1] {
            let track = MusicLibrary.shared.track(forID: trackID)
            return self.track_cell(num: track.trackNum, name: track.name)
        } else {
            return self.track_cell(num: 99, name: "Unknown")
        }
    }
    
    private func banner_cell(image: UIImage?, name: String?, artist artistID: ArtistID, genre: String?) -> UITableViewCell {
        let artist = MusicLibrary.shared.artist(forID: artistID)
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "AlbumsBannerCell") as! AlbumBannerCell
        cell.setupLayer()
        cell.albumArtView.image = image ?? UIImage(systemName: "music.note.list")
        cell.nameLabel.text = name
        cell.artistLabel.text = artist.name
        cell.genreLabel.text = genre
        return cell
    }
    
    private func track_cell(num: Int?, name: String?) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "AlbumsTrackCell") as! AlbumTrackCell
        cell.numLabel.text = num.map(String.init)
        cell.nameLabel.text = name
        return cell
    }
}
