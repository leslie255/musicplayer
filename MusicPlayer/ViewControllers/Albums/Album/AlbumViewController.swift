//
//  AlbumViewController.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/7.
//

import UIKit

class AlbumViewController: UITableViewController {
    
    var album: Album! = nil
    
    /// The label for showing the title of the album in the first cell.
    /// When it is under the naviagation bar, title of the album would be displayed on the navigation bar.
    /// Set by `banner_cell(image:name:artist:genre:)`
    unowned var albumTitleLabel: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backItem?.title = nil
    }
    
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
                image: album.art?.uiImage,
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
        Player.shared.playTrack(track: track, albumArt: album.art?.uiImage, artistName: artist.name)
    }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // calling `super.scrollViewDidScroll(_:)` crashes because UIKit magic ig
//        // note that this function is also called on initial loading
//
//        // show album title on navigation bar if album title is hidden
//        guard let navController = self.navigationController else { return }
//        guard let albumTitleLabel else { return }
//        let albumTitleMaxY = self.view.convert(
//            CGPoint(x: 0, y: albumTitleLabel.frame.maxY),
//            to: self.view.coordinateSpace
//        ).y
//        let navigationBarMaxY = self.tableView.convert(
//            CGPoint(x: 0, y: navController.navigationBar.frame.maxY),
//            to: self.view.coordinateSpace
//        ).y
//        NSLog("\((albumTitleMaxY, navigationBarMaxY))")
//    }
    
    private func banner_cell(image: UIImage?, name: String?, artist artistID: ArtistID, genre: String?) -> UITableViewCell {
        let artist = MusicLibrary.shared.artist(forID: artistID)
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "AlbumsBannerCell") as! AlbumBannerCell
        cell.albumArtView.image = image ?? UIImage(systemName: "music.note.list")
        cell.nameLabel.text = name
        cell.artistLabel.text = artist.name
        cell.genreLabel.text = genre
        albumTitleLabel = cell.nameLabel
        return cell
    }
    
    private func track_cell(num: Int?, name: String?) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "AlbumsTrackCell") as! AlbumTrackCell
        cell.numLabel.text = num.map(String.init)
        cell.nameLabel.text = name
        return cell
    }
}
