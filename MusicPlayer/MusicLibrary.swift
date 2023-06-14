//
//  MusicLibrary.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/8.
//

import Foundation
import AVFoundation
import UIKit

class Album {
    var name: String
    var artist: ArtistID
    var tracks: [TrackID]
    var art: UIImage?
    var genre: String
    
    init(name: String, artist: ArtistID, tracks: [TrackID], art: UIImage? = nil, genre: String) {
        self.name = name
        self.artist = artist
        self.tracks = tracks
        self.art = art
        self.genre = genre
    }
}

class Artist {
    var name: String
    var albums: [AlbumID]
    
    init(name: String, albums: [AlbumID]) {
        self.name = name
        self.albums = albums
    }
}

class Track {
    var name: String
    var artist: ArtistID
    var album: AlbumID?
    var genre: String?
    var discNum: Int?
    var trackNum: Int?
    var asset: AVAsset
    var duration: CMTime?
    
    init(
        name: String,
        artist: ArtistID,
        album: AlbumID? = nil,
        genre: String? = nil,
        discNum: Int? = nil,
        trackNum: Int? = nil,
        asset: AVAsset,
        duration: CMTime? = nil
    ) {
        self.name = name
        self.artist = artist
        self.album = album
        self.genre = genre
        self.discNum = discNum
        self.trackNum = trackNum
        self.asset = asset
        self.duration = duration
    }
}

struct ArtistID { fileprivate var idx: Int }
struct AlbumID  { fileprivate var idx: Int }
struct TrackID  { fileprivate var idx: Int }

class MusicLibrary {
    
    static var shared = MusicLibrary()
    
    var tracks = [Track]()
    var albums = [Album]()
    var artists = [Artist]()
    
    var tracksByArtist = [Track]()
    var tracksByAlbum = [Track]()
    var tracksByAlphabet = [Track]()
    
    private var docDir: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }()
    
    func track(forID id: TrackID) -> Track {
        tracks[id.idx]
    }
    
    func artist(forID id: ArtistID) -> Artist {
        artists[id.idx]
    }
    
    func album(forID id: AlbumID) -> Album {
        albums[id.idx]
    }
    
    func scanMusic() async {
        let items: [URL]
        do {
            items = try FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: [.isReadableKey])
        } catch {
            print("Cannot access documents directory")
            return
        }
        
        await withTaskGroup(of: Void.self) { group in
            for url in items {
                let artistName = url.lastPathComponent
                if artistName.first.map({ $0 == "." }) ?? true {
                    continue
                }
                group.addTask { await self.scanArtistDir(dir: url, artistName: url.lastPathComponent) }
            }
            
            for await _ in group {}
            NotificationCenter.default.post(Notification(name: .musicLibraryFinishedScanning))
        }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [self] in
                tracksByArtist = tracks.sorted { $0.artist.idx > $1.artist.idx }
                tracksByAlbum = tracks.sorted { ($0.album?.idx ?? -1) > ($1.album?.idx ?? -1) }
                tracksByAlphabet = tracks.sorted { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending }
            }
            
            for await _ in group {}
            NotificationCenter.default.post(Notification(name: .musicLibraryFinishedSorting))
        }
        
    }
    
    private func scanArtistDir(dir: URL, artistName: String) async {
        let items: [URL]
        do {
            items = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isReadableKey])
        } catch {
            print("Cannot access directory \(dir)")
            return
        }
        
        let artistID = self.addArtist(name: artistName)
        for url in items {
            let albumName = url.lastPathComponent
            if albumName.first.map({ $0 == "." }) ?? true {
                continue
            }
            
            let isDir = try! url.resourceValues(forKeys: [URLResourceKey.isDirectoryKey]).isDirectory ?? false
            
            if isDir {
                // is an album
                await self.scanAlbum(url: url, artist: artistID, albumName: albumName)
            } else {
                // is a single
                let trackID = await self.scanTrack(url: url, artist: artistID, album: nil)
                self.tracks.append(trackID)
            }
        }
    }
    
    private func scanAlbum(url: URL, artist artistID: ArtistID, albumName: String) async {
        // load _metadata folder
        let metadataURL = url.appendingPathComponent("_metadata", conformingTo: .directory)
        var albumArt: UIImage? = nil
        if let items = try? FileManager.default.contentsOfDirectory(at: metadataURL, includingPropertiesForKeys: [.isRegularFileKey, .isReadableKey]) {
            for item in items {
                let filename = item.lastPathComponent
                // album art
                if filename.caseInsensitiveCompare("artwork.jpg") == .orderedSame
                    || filename.caseInsensitiveCompare("artwork.jpeg") == .orderedSame
                    || filename.caseInsensitiveCompare("artwork.heic") == .orderedSame
                    || filename.caseInsensitiveCompare("artwork.png") == .orderedSame {
                    let data = try? Data(contentsOf: item)
                    albumArt = data.flatMap(UIImage.init(data:))
                }
            }
        }
        
        let items: [URL]
        do {
            items = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey, .isReadableKey])
        } catch {
            print("Cannot access directory \(url)")
            return
        }
        
        let album = Album(name: albumName, artist: artistID, tracks: [], art: albumArt, genre: "Unknown Genre")
        let albumID = self.addAlbum(album)
        for trackURL in items {
            switch trackURL.pathExtension {
            case "mp3", "flac", "m4a": break
            default: continue
            }
            let track = await self.scanTrack(url: trackURL, artist: artistID, album: albumID)
            let trackID = self.addTrack(track)
            album.tracks.append(trackID)
        }
    }
    
    private func scanTrack(url: URL, artist artistID: ArtistID, album albumID: AlbumID?) async -> Track {
        let asset = AVAsset(url: url)
        var name: String? = nil
        let metadataItems = try? await asset.load(.metadata)
        for metadata in metadataItems ?? [] {
            switch metadata.commonKey {
            case AVMetadataKey.commonKeyTitle:
                name = try? await metadata.load(.stringValue)
            default: break
            }
        }
        let duration = try? await asset.load(.duration)
        let track = Track(
            name: name ?? url.lastPathComponent,
            artist: artistID,
            album: albumID,
            asset: asset,
            duration: duration
        )
        return track
    }
    
    private func addArtist(name: String) -> ArtistID {
        let artist = Artist(name: name, albums: [])
        let idx = artists.count
        artists.append(artist)
        return ArtistID(idx: idx)
    }
    
    private func addAlbum(_ album: Album) -> AlbumID {
        let idx = albums.count
        albums.append(album)
        return AlbumID(idx: idx)
    }
    
    private func addTrack(_ track: Track) -> TrackID {
        let idx = tracks.count
        tracks.append(track)
        return TrackID(idx: idx)
    }
    
}
