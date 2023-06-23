//
//  AlbumsViewController.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/8.
//

import UIKit

class AlbumsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.placeholder = "Find in Albums"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc func tapOnAlbum(_ sender: UITapGestureRecognizer) {
        let p = sender.location(in: self.collectionView!)
        let indexPath = self.collectionView.indexPathForItem(at: p)!
        if let album = MusicLibrary.shared.albums[checked: indexPath.row] {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let albumVC = storyboard.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController
            albumVC.album = album
            self.navigationController!.pushViewController(albumVC, animated: true)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        MusicLibrary.shared.albums.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let album = MusicLibrary.shared.albums[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumsCell", for: indexPath) as! AlbumsCell
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnAlbum(_:))))
        cell.albumArtView.image = album.art?.uiImage ?? UIImage(systemName: "music.note.list")
        cell.nameLabel.text = album.name
        cell.artistLabel.text = MusicLibrary.shared.artist(forID: album.artist).name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(2)
        let padding = 8 * (itemsPerRow + 1)
        let totalW = view.frame.width - padding - (16 * 2)
        let w = totalW / itemsPerRow
        
        return CGSize(width: w, height: w + 42)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
}
