//
//  MultipleAssetRowSourceTypes.swift
//  ImageRow
//
//  Created by Lacy Rhoades on 10/13/17.
//

import Foundation

public enum AssetSourceType: Int {
    case photoLibrary
    case dropbox
    case smbShare
}

public struct MultipleAssetRowSourceTypes: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = 1 << rawValue }
    init(_ sourceType: AssetSourceType) { self.init(rawValue: sourceType.rawValue) }
    
    public static let PhotoLibrary = MultipleAssetRowSourceTypes(.photoLibrary)
    public static let Dropbox = MultipleAssetRowSourceTypes(.dropbox)
    public static let SMBShare = MultipleAssetRowSourceTypes(.smbShare)
    public static let All: MultipleAssetRowSourceTypes = [PhotoLibrary, Dropbox]
}

extension MultipleAssetRowSourceTypes {
    var localizedString: String {
        switch self {
        case MultipleAssetRowSourceTypes.PhotoLibrary:
            return NSLocalizedString("Photo Library", comment: "")
        case MultipleAssetRowSourceTypes.Dropbox:
            return NSLocalizedString("Dropbox", comment: "")
        case MultipleAssetRowSourceTypes.SMBShare:
            return NSLocalizedString("Local Network Share", comment: "")
        case MultipleAssetRowSourceTypes.All:
            return NSLocalizedString("All", comment: "")
        default:
            return NSLocalizedString("", comment: "")
        }
    }
}
