//
//  AlbumViewController.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/7.
//

import UIKit

class AlbumViewController: UITableViewController {
    
    @IBOutlet var mainTableView: UITableView!
    
    let placeholderData: [(Int, String)] = [
        (1, "Hello"),
        (2, "Roll with It"),
        (3, "Wonderwall"),
        (4, "Don't Look Back in Anger"),
        (5, "Hey Now!"),
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let navBar = self.navigationController!.navigationBar
//        navBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        let navBar = self.navigationController!.navigationBar
//        navBar.prefersLargeTitles = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.placeholderData.count + 1
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
            return self.banner_cell(
                image: nil,
                name: "(What's the Story) Morning Glory?",
                artist: "Oasis",
                genre: "Rock"
            )
        } else {
            let (num, name) = placeholderData[indexPath.row - 1]
            return self.track_cell(num: num, name: name)
        }
    }
    
    private func banner_cell(image: UIImage?, name: String?, artist: String?, genre: String?) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "AlbumsBannerCell") as! AlbumBannerCell
        cell.setupLayer()
        cell.albumArtView.image = image ?? UIImage(systemName: "music.note.list")
        cell.nameLabel.text = name
        cell.artistLabel.text = artist
        cell.genreLabel.text = genre
        return cell
    }
    
    private func track_cell(num: Int, name: String?) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "AlbumsTrackCell") as! AlbumTrackCell
        cell.numLabel.text = String(num)
        cell.nameLabel.text = name
        return cell
    }
}
