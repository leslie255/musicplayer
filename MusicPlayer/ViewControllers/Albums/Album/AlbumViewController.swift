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
                image: album.art,
                name: album.name,
                artist: album.artist,
                genre: album.genre
            )
        }
        
        guard let trackID = self.album.tracks[checked: indexPath.row - 1] else {
            return self.track_cell(num: 99, name: "Unknown")
        }
        
        let track = MusicLibrary.shared.track(forID: trackID)
        return self.track_cell(num: track.trackNum, name: track.name)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard let trackID = self.album.tracks[checked: indexPath.row - 1] else { return }
        let track = MusicLibrary.shared.track(forID: trackID)
        let artist = MusicLibrary.shared.artist(forID: album.artist)
        Player.shared.playTrack(track: track, albumArt: album.art, artistName: artist.name)
    }
    
    private func banner_cell(image: UIImage?, name: String?, artist artistID: ArtistID, genre: String?) -> UITableViewCell {
        let artist = MusicLibrary.shared.artist(forID: artistID)
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "AlbumsBannerCell") as! AlbumBannerCell
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
