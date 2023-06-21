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
    
    var artistsByTitle = [Artist]()
    
    var albumsByTitle = [Album]()
    
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
        
        artistsByTitle = artists.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        albumsByTitle = albums.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        tracksByArtist = artistsByTitle.lazy
            .flatMap { $0.albums }
            .map(album(forID:))
            .flatMap { $0.tracks }
            .map(track(forID:))
        tracksByAlbum = albumsByTitle.lazy
            .flatMap { $0.tracks }
            .map(track(forID:))
        tracksByTitle = tracks.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        
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
        
        let artist = Artist(name: artistName, albums: [])
        let artistID = addArtist(artist)
        
        for url in items {
            let albumName = url.lastPathComponent
            if albumName.first.map({ $0 == "." }) ?? true {
                continue
            }
            
            let isDir = try! url.resourceValues(forKeys: [URLResourceKey.isDirectoryKey]).isDirectory ?? false
            
            if isDir {
                // is an album
                await scanAlbum(url: url, artist: artistID, albumName: albumName).map { artist.albums.append($0) }
            } else {
                // is a single
                // TODO
            }
        }
    }
    
    private func scanAlbum(url: URL, artist artistID: ArtistID, albumName: String) async -> AlbumID? {
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
            return nil
        }
        
        let album = Album(name: albumName, artist: artistID, tracks: [], art: albumArt, genre: "Unknown Genre")
        let albumID = addAlbum(album)
        var tracks = [Track]()
        tracks.reserveCapacity(items.count)
        
        for trackURL in items
        where trackURL.pathExtension.caseInsensitiveCompare("mp3") == .orderedSame
        || trackURL.pathExtension.caseInsensitiveCompare("flac") == .orderedSame
        || trackURL.pathExtension.caseInsensitiveCompare("m4a") == .orderedSame
        {
            let track: Track
            if album.art == nil {
                let (_track, artwork) = await scanTrack(url: trackURL, artist: artistID, album: albumID, includeArtwork: true)
                album.art = artwork
                track = _track
            } else {
                let (_track, _) = await scanTrack(url: trackURL, artist: artistID, album: albumID, includeArtwork: false)
                track = _track
            }
            
            tracks.append(track)
        }
        
        tracks.sort {
            ($1.discNum ?? 0) * 100 + ($1.trackNum ?? 0) > ($0.discNum ?? 0) * 100 + ($0.trackNum ?? 0)
        }
        
        album.tracks = tracks.map(addTrack(_:))
        
        return albumID
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
        let (discNum, trackNum) = getDiscAndTrackName(fileName: fileName)
        let track = Track(
            name: name ?? fileName,
            artist: artistID,
            album: albumID,
            discNum: discNum,
            trackNum: trackNum,
            asset: asset,
            duration: duration
        )
        return (track, artwork)
    }
    
    private func getDiscAndTrackName(fileName: String) -> (Int?, Int?) {
        func charAsDigit(char: UInt32) -> UInt32? {
            let digit = char &- 0x30
            return digit < 10 ? digit : nil
        }
        var chars = fileName.unicodeScalars.makeIterator()
        guard let digit0 = chars.next().map(UInt32.init(_:)).flatMap(charAsDigit(char:)) else { return (nil, nil) }
        guard let char1 = chars.next() else { return (nil, nil) }
        if let digit1 = charAsDigit(char: UInt32(char1)) { return (nil, Int(digit0 * 10 + digit1)) }
        if char1 != "-" { return (nil, nil) }
        let discNum = digit0
        guard let digit2 = chars.next().map(UInt32.init(_:)).flatMap(charAsDigit(char:)) else { return (nil, nil) }
        guard let digit3 = chars.next().map(UInt32.init(_:)).flatMap(charAsDigit(char:)) else { return (nil, nil) }
        let trackNum = digit2 * 10 + digit3
        return (Int(discNum), Int(trackNum))
    }
    
    private func addArtist(_ artist: Artist) -> ArtistID {
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
    
    private func createMessageTxt(at dir: URL) {
        let path = dir.appendingPathComponent("move files here.txt", conformingTo: .fileURL).absoluteString
        FileManager.default.createFile(
            atPath: path,
            contents: MusicLibrary.moveFilesHereMessage.data(using: .utf8))
    }
}
