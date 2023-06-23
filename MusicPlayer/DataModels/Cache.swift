//
//  Cache.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/22.
//

import UIKit
import AVFoundation

extension Artwork: Codable {
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let data = try values.decode(Data.self, forKey: .data)
        self.init(data: data)
    }
}

extension Asset: Codable {
    enum CodingKeys: String, CodingKey {
        case url
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let url = try values.decode(URL.self, forKey: .url)
        self = .unloaded(url)
    }
}

struct CacheManager {
    private let cacheDir: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }()
}
