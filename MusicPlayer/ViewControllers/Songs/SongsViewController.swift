//
//  SongsViewController.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/7.
//

import UIKit

class SongsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadTableView),
            name: .musicLibraryUpdated,
            object: nil
        )
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MusicLibrary.shared.tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTrackCell", for: indexPath) as! SongsTrackCell
        let track = MusicLibrary.shared.tracks[indexPath.row]
        let album = track.album.map(MusicLibrary.shared.album(forID:))
        cell.setupLayers()
        cell.trackLabel.text = track.name
        cell.artistLabel.text = MusicLibrary.shared.artist(forID: track.artist).name
        let albumArtImage = album?.art ?? UIImage(systemName: "music.note")
        cell.albumArtView.image = albumArtImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = MusicLibrary.shared.tracks[indexPath.row]
        Player.shared.playTrack(track: track)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
