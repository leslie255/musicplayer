//
//  SongsViewController.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/7.
//

import UIKit

class SongsViewController: UITableViewController, UISearchBarDelegate {
    
    private enum SongsSortMode {
        case random, byArtist, byAlbum, byTitle
    }
    
    @IBOutlet private weak var sortButton: UIBarButtonItem!
    
    private var playerBarView: UIView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var sortMode: SongsSortMode = .random {
        didSet {
            switch sortMode {
            case .random:
                presentedTracks = MusicLibrary.shared.tracks.indices.map(TrackID.init(unsafeFromRawIndex:))
            case .byArtist:
                presentedTracks = MusicLibrary.shared.tracksByArtist
            case .byAlbum:
                presentedTracks = MusicLibrary.shared.tracksByAlbum
            case .byTitle:
                presentedTracks = MusicLibrary.shared.tracksByTitle
            }
            syncSortModeMenu()
        }
    }
    
    /// Text in the search bar, `nil` if search bar isn't active
    private var searchText: String?
    
    /// The tracks presented inside this VC, "points"
    private var presentedTracks = [TrackID]()
    
    /// Tracks filtered by `searchText`
    private var filteredTracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.placeholder = "Find in Songs"
        syncSortModeMenu()
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
        initPlayerBar()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchText = nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        57
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presentedTracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTrackCell", for: indexPath) as! SongsTrackCell
        let track = MusicLibrary.shared.track(forID: presentedTracks[indexPath.row])
        let album = MusicLibrary.shared.album(forOptionalID: track.album)
        cell.trackLabel.text = track.name
        if sortMode == .byAlbum {
            cell.artistLabel.text = String(
                format: "%@ - %@",
                MusicLibrary.shared.artist(forID: track.artist).name,
                MusicLibrary.shared.album(forOptionalID: track.album)?.name ?? "Single"
            )
        } else {
            cell.artistLabel.text = MusicLibrary.shared.artist(forID: track.artist).name
        }
        let albumArtImage = album?.art?.uiImage ?? UIImage(systemName: "music.note")
        cell.albumArtView.image = albumArtImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = MusicLibrary.shared.track(forID: presentedTracks[indexPath.row])
        let albumArt = MusicLibrary.shared.album(forOptionalID: track.album)?.art
        let artistName = MusicLibrary.shared.artist(forID: track.artist).name
        Player.shared.playTrack(track: track, albumArt: albumArt?.uiImage, artistName: artistName)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// Sync the selection of the sort menu
    private func syncSortModeMenu() {
        let actionArtist = UIAction(
            title: "Artist",
            state: sortMode == .byArtist ? .on : .off
        ) { [self] _ in
            sortMode = .byArtist
            tableView.reloadData()
        }
        let actionAlbum = UIAction(
            title: "Album",
            state: sortMode == .byAlbum ? .on : .off
        ) { [self] _ in
            sortMode = .byAlbum
            tableView.reloadData()
        }
        let actionTitle = UIAction(
            title: "Title",
            state: sortMode == .byTitle ? .on : .off
        ) { [self] _ in
            sortMode = .byTitle
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
        sortMode = .byArtist
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func initPlayerBar() {
//        playerBarView = UIView()
//        playerBarView.backgroundColor = .systemTeal
//        self.view.addSubview(playerBarView)
//        self.view.addConstraint(playerBarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor))
//        self.view.addConstraint(playerBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor))
//        self.view.addConstraint(playerBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor))
//        playerBarView.addConstraint(NSLayoutDimension().constraint(equalToConstant: 160))
    }
    
}
