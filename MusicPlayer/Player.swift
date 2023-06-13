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
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.avplayer.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.avplayer.pause()
            return .success
        }
        commandCenter.changePlaybackRateCommand.addTarget { [unowned self] event in
            let time = (event as! MPChangePlaybackPositionCommandEvent).positionTime
            let cmtime = CMTime(value: CMTimeValue(Float16(time)), timescale: 1)
            self.avplayer.seek(to: cmtime, toleranceBefore: .indefinite, toleranceAfter: .indefinite)
            return .success
        }
    }
    
    func playTrack(track: Track) {
        self.avplayer.replaceCurrentItem(with: AVPlayerItem(asset: track.asset))
        self.avplayer.play()
    }
    
}
