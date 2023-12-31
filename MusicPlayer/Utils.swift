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

// MARK: String compare

/// Case-insensitive equal
infix operator ==~ : ComparisonPrecedence

/// Localized standard equal
infix operator ==^ : ComparisonPrecedence
/// Localized standard greater than
infix operator >^ : ComparisonPrecedence
/// Localized standard less than
infix operator <^ : ComparisonPrecedence

extension String {
    static func ==~(lhs: Self, rhs: Self) -> Bool {
        lhs.caseInsensitiveCompare(rhs) == .orderedSame
    }
    static func ==^(lhs: Self, rhs: Self) -> Bool {
        lhs.localizedStandardCompare(rhs) == .orderedSame
    }
    static func >^(lhs: Self, rhs: Self) -> Bool {
        lhs.localizedStandardCompare(rhs) == .orderedAscending
    }
    static func <^(lhs: Self, rhs: Self) -> Bool {
        lhs.localizedStandardCompare(rhs) == .orderedDescending
    }
}
