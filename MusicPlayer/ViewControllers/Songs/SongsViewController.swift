//
//  SongsViewController.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/7.
//

import UIKit

class SongsViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    /// Text in the search bar, `nil` if search bar isn't active
    var searchText: String?
    
    /// The tracks presented inside this VC, "points"
    var presentedTracks = MusicLibrary.shared.tracks
    
    /// Tracks filtered by `searchText`
    var filteredTracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.placeholder = "Search in Songs"
        setupSortButton()
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(libraryFinishedScanning),
            name: .musicLibraryFinishedScanning,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(libraryFinishedSorting),
            name: .musicLibraryFinishedSorting,
            object: nil
        )
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchText = nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presentedTracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTrackCell", for: indexPath) as! SongsTrackCell
        let track = presentedTracks[indexPath.row]
        let album = track.album.map(MusicLibrary.shared.album(forID:))
        cell.setupLayers()
        cell.trackLabel.text = track.name
        cell.artistLabel.text = MusicLibrary.shared.artist(forID: track.artist).name
        let albumArtImage = album?.art ?? UIImage(systemName: "music.note")
        cell.albumArtView.image = albumArtImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = presentedTracks[indexPath.row]
        let albumArt = track.album.map(MusicLibrary.shared.album(forID:))?.art
        let artistName = MusicLibrary.shared.artist(forID: track.artist).name
        Player.shared.playTrack(track: track, albumArt: albumArt, artistName: artistName)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func setupSortButton() {
        let actionArtist = UIAction(title: "Artist", image: UIImage(systemName: "music.mic")) { [self] _ in
            presentedTracks = MusicLibrary.shared.tracksByArtist
            tableView.reloadData()
        }
        let actionAlbum = UIAction(title: "Album", image: UIImage(systemName: "square.stack.fill")) { [self] _ in
            presentedTracks = MusicLibrary.shared.tracksByArtist
            tableView.reloadData()
        }
        let actionTitle = UIAction(title: "Title", image: UIImage(systemName: "square.stack.fill")) { [self] _ in
            presentedTracks = MusicLibrary.shared.tracksByAlphabet
            tableView.reloadData()
        }
        let menu = UIMenu(title: "Sort by", children: [actionArtist, actionAlbum, actionTitle])
        sortButton.menu = menu
    }
    
    @objc private func libraryFinishedScanning() {
        // UITableView.reloadData must be called in the main thread
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc private func libraryFinishedSorting() {
        // UITableView.reloadData must be called in the main thread
        presentedTracks = MusicLibrary.shared.tracksByAlbum
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
