//
//  MusicLibrary.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/8.
//

import Foundation

class Album {
    var name: String
    var artist: ArtistID
    var tracks: [TrackID]
    var genre: String
    
    init(name: String, artist: ArtistID, tracks: [TrackID], genre: String) {
        self.name = name
        self.artist = artist
        self.tracks = tracks
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
    let source: URL
    
    init(name: String, artist: ArtistID, album: AlbumID? = nil, genre: String? = nil, discNum: Int? = nil, trackNum: Int? = nil, source: URL) {
        self.name = name
        self.artist = artist
        self.album = album
        self.genre = genre
        self.discNum = discNum
        self.trackNum = trackNum
        self.source = source
    }
}

struct ArtistID { var idx: Int }
struct AlbumID  { var idx: Int }
struct TrackID  { var idx: Int }

class MusicLibrary {
    
    static var shared = MusicLibrary()
    
    var tracks = [Track]()
    var albums = [Album]()
    var artists = [Artist]()
    
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
    
    func scanMusic() {
        let items: [URL]
        do {
            items = try FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: [.isRegularFileKey, .isReadableKey])
        } catch {
            print("Cannot access documents directory")
            return
        }
        
        for url in items {
            let artistName = url.lastPathComponent
            if artistName.first.map({ $0 == "." }) ?? true {
                continue
            }
            scanArtistDir(dir: url, artistName: url.lastPathComponent)
        }
    }
    
    private func scanArtistDir(dir: URL, artistName: String) {
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
                self.scanAlbum(url: url, artist: artistID, albumName: albumName)
            } else {
                // is a single
            }
        }
    }
    
    private func scanAlbum(url: URL, artist artistID: ArtistID, albumName: String) {
        let items: [URL]
        do {
            items = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey, .isReadableKey])
        } catch {
            print("Cannot access directory \(url)")
            return
        }
        
        let album = Album(name: albumName, artist: artistID, tracks: [], genre: "Unknown Genre")
        let albumID = self.addAlbum(album)
        for trackURL in items {
            let trackID = self.scanTrack(url: trackURL, artist: artistID, album: albumID)
            album.tracks.append(trackID)
        }
    }
    
    private func scanTrack(url: URL, artist artistID: ArtistID, album albumID: AlbumID?) -> TrackID {
        let track = Track(
            name: url.lastPathComponent,
            artist: artistID,
            album: albumID,
            source: url
        )
        return self.addTrack(track: track)
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
    
    private func addTrack(track: Track) -> TrackID {
        let idx = tracks.count
        tracks.append(track)
        return TrackID(idx: idx)
    }
    
}
