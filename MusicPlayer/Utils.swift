//
//  Utils.swift
//  MusicPlayer
//
//  Created by Luo Zili on 2023/6/9.
//

import Foundation

extension Collection {
    subscript (checked index: Self.Index) -> Self.Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}

extension Array {
    subscript (unsafe index: Self.Index) -> Self.Element {
        return self.withUnsafeBufferPointer { $0[index] }
    }
}
