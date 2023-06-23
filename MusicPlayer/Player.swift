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
    
    /// Timer for repeatedly sync elapse time in Now Playing
    private var syncTimer = Timer()
    
    private var avplayer = AVPlayer()
    
    /// Setup the system's Now Playing media controller
    func setupNowPlaying() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] event in
            syncElapsedPlaybackTime()
            avplayer.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            syncElapsedPlaybackTime()
            avplayer.pause()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            let time = (event as! MPChangePlaybackPositionCommandEvent).positionTime
            let cmtime = CMTime(value: CMTimeValue(Float16(time)), timescale: 1)
            avplayer.seek(to: cmtime, toleranceBefore: .indefinite, toleranceAfter: .indefinite)
            return .success
        }
    }
    
    func playTrack(track: Track, albumArt: UIImage?, artistName: String?) {
        let avAsset: AVAsset
        switch track.asset {
        case .avAsset(_, let _asset):
            avAsset = _asset
        case .unloaded(let url):
            avAsset = AVAsset(url: url)
        }
        
        avplayer.replaceCurrentItem(with: AVPlayerItem(asset: avAsset))
        avplayer.play()
        
        // setup Now Playing display
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
        if let artistName = artistName {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artistName
        }
        if let image = albumArt {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = avplayer.currentTime().seconds
        if let duration = track.duration {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func syncElapsedPlaybackTime() {
        MPNowPlayingInfoCenter.default()
            .nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = avplayer.currentTime().seconds
    }
    
}
