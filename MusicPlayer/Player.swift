//
//  Player.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/12.
//

import AVFoundation
import MediaPlayer

class Player {
    
    static let shared = Player()
    
    private let avplayer = AVPlayer()
    
    func setupMPRemoteCommandCenter() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.avplayer.rate == 0.0 {
                self.avplayer.play()
                return .success
            } else {
                return .commandFailed
            }
        }
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.avplayer.rate == 1.0 {
                self.avplayer.pause()
                return .success
            } else {
                return .commandFailed
            }
        }
    }
    
    func playTrack(track: Track) {
        // play
        let asset = AVAsset(url: track.source)
        self.avplayer.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        self.avplayer.play()
    }

}
