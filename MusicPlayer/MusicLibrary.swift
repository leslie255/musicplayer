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
    
    static private let moveFilesHereMessage = """
Move your music files here in the structure of

Artist/
    single.mp3
    Album/
        _metadata/
            artwork.png
        song1.m4a
        song2.flac

mp3, m4a, flac are all supported!
album art can be in png, jpg or heic
"""
    static var shared = MusicLibrary()
    
    var tracks = [Track]()
    var albums = [Album]()
    var artists = [Artist]()
    
    var tracksByArtist = [Track]()
    var tracksByAlbum = [Track]()
    var tracksByTitle = [Track]()
    
    func track(forID id: TrackID) -> Track {
        tracks[id.idx]
    }
    
    func artist(forID id: ArtistID) -> Artist {
        artists[id.idx]
    }
    
    func album(forID id: AlbumID) -> Album {
        albums[id.idx]
    }
    
    func track(forOptionalID id: TrackID?) -> Track? {
        id.map(track(forID:))
    }
    
    func artist(forOptionalID id: ArtistID?) -> Artist? {
        id.map(artist(forID:))
    }
    
    func album(forOptionalID id: AlbumID?) -> Album? {
        id.map(album(forID:))
    }
    
    func scanMusic() async {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var items: [URL]
        do {
            items = try FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: [.isReadableKey])
        } catch {
            print("Cannot access documents directory")
            return
        }
        
        if items.isEmpty {
            createMessageTxt(at: docDir)
        }
        
        artists.reserveCapacity(items.count)
        
        await withTaskGroup(of: Void.self) { group in
            for url in items {
                let artistName = url.lastPathComponent
                if artistName.first.map({ $0 == "." }) ?? true {
                    continue
                }
                group.addTask { [self] in await scanArtistDir(dir: url, artistName: url.lastPathComponent) }
            }
            
            for await _ in group {}
            NotificationCenter.default.post(Notification(name: .musicLibraryFinishedScanning))
        }
        
        tracksByArtist = tracks.sorted { [self] (track0, track1) in
            let artistName0 = artist(forID: track0.artist).name
            let artistName1 = artist(forID: track1.artist).name
            return artistName0.caseInsensitiveCompare(artistName1) == .orderedAscending
        }
        tracksByAlbum = tracks.sorted { [self] (track0, track1) in
            let albumName0 = track0.album.map(album(forID:))?.name ?? track0.name
            let albumName1 = track1.album.map(album(forID:))?.name ?? track1.name
            return albumName0.caseInsensitiveCompare(albumName1) == .orderedAscending
        }
        tracksByTitle = tracks.sorted { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending }
        
        NotificationCenter.default.post(Notification(name: .musicLibraryFinishedSorting))
    }
    
    private func scanArtistDir(dir: URL, artistName: String) async {
        let items: [URL]
        do {
            items = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isReadableKey])
        } catch {
            print("Cannot access directory \(dir)")
            return
        }
        
        albums.reserveCapacity(items.count)
        
        let artistID = addArtist(name: artistName)
        for url in items {
            let albumName = url.lastPathComponent
            if albumName.first.map({ $0 == "." }) ?? true {
                continue
            }
            
            let isDir = try! url.resourceValues(forKeys: [URLResourceKey.isDirectoryKey]).isDirectory ?? false
            
            if isDir {
                // is an album
                await scanAlbum(url: url, artist: artistID, albumName: albumName)
            } else {
                // is a single
                let (track, _) = await scanTrack(url: url, artist: artistID, album: nil, includeArtwork: false)
                addTrack(track)
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
        let albumID = addAlbum(album)
        for trackURL in items {
            switch trackURL.pathExtension {
            case "mp3", "flac", "m4a": break
            default: continue
            }
            let track: Track
            if album.art == nil {
                let (_track, artwork) = await scanTrack(url: trackURL, artist: artistID, album: albumID, includeArtwork: true)
                album.art = artwork
                track = _track
            } else {
                let (_track, _) = await scanTrack(url: trackURL, artist: artistID, album: albumID, includeArtwork: false)
                track = _track
            }
            let trackID = addTrack(track)
            album.tracks.append(trackID)
        }
    }
    
    private func scanTrack(url: URL, artist artistID: ArtistID, album albumID: AlbumID?, includeArtwork: Bool) async -> (Track, UIImage?) {
        let asset = AVAsset(url: url)
        var name: String?
        var artwork: UIImage?
        let metadataItems = try? await asset.load(.metadata)
        let fileName = url.lastPathComponent
        for metadata in metadataItems ?? [] {
            switch metadata.commonKey {
            case AVMetadataKey.commonKeyTitle:
                name = try? await metadata.load(.stringValue)
            case AVMetadataKey.commonKeyArtwork:
                if includeArtwork {
                    let data = try? await metadata.load(.dataValue)
                    artwork = data.flatMap(UIImage.init(data:))
                }
            default: break
            }
        }
        let duration = try? await asset.load(.duration)
        let track = Track(
            name: name ?? fileName,
            artist: artistID,
            album: albumID,
            trackNum: nil,  // TODO
            asset: asset,
            duration: duration
        )
        return (track, artwork)
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
    
    @discardableResult
    private func addTrack(_ track: Track) -> TrackID {
        let idx = tracks.count
        tracks.append(track)
        return TrackID(idx: idx)
    }
    
    private func createMessageTxt(at dir: URL) {
        let path = dir.appendingPathComponent("move files here.txt", conformingTo: .fileURL).absoluteString
        FileManager.default.createFile(
            atPath: path,
            contents: MusicLibrary.moveFilesHereMessage.data(using: .utf8))
    }
}
