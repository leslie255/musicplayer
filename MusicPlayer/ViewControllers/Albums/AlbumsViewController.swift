//
//  AlbumsViewController.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/8.
//

import UIKit

class AlbumsViewController: UICollectionViewController {
    
    let placeHolderData: [UIImage?] = [
        nil,
        nil,
        nil,
        nil,
        nil,
    ]

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.placeHolderData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumsCell", for: indexPath) as! AlbumsCell
        cell.setupLayer()
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        cell.albumArtView.image = self.placeHolderData[indexPath.row] ?? UIImage(systemName: "music.note.list")
        return cell
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        let p = sender.location(in: self.collectionView!)
        let indexPath = self.collectionView.indexPathForItem(at: p)!
        print("Tapped: \(indexPath)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let albumVC = storyboard.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController
        self.navigationController!.pushViewController(albumVC, animated: true)
    }
}

extension AlbumsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(2)
        let padding = 8 * (itemsPerRow + 1)
        let totalW = view.frame.width - padding - (16 * 2)
        let w = totalW / itemsPerRow
        
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
