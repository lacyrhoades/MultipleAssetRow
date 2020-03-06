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
    case google
    case smbShare
}

public struct MultipleAssetRowSourceTypes: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = 1 << rawValue }
    init(_ sourceType: AssetSourceType) { self.init(rawValue: sourceType.rawValue) }
    
    public static let PhotoLibrary = MultipleAssetRowSourceTypes(.photoLibrary)
    public static let Dropbox = MultipleAssetRowSourceTypes(.dropbox)
    public static let Google = MultipleAssetRowSourceTypes(.google)
    public static let SMBShare = MultipleAssetRowSourceTypes(.smbShare)
    
    public static let allSources: MultipleAssetRowSourceTypes = [.PhotoLibrary, .Dropbox, .Google, .SMBShare]
}

extension MultipleAssetRowSourceTypes {
    var localizedString: String {
        switch self {
        case MultipleAssetRowSourceTypes.PhotoLibrary:
            return NSLocalizedString("Photo Library", comment: "")
        case MultipleAssetRowSourceTypes.Dropbox:
            return NSLocalizedString("Dropbox", comment: "")
        case MultipleAssetRowSourceTypes.Google:
            return NSLocalizedString("Google Drive", comment: "")
        case MultipleAssetRowSourceTypes.SMBShare:
            return NSLocalizedString("Local Network Share", comment: "")
        default:
            assert(false)
            return NSLocalizedString("Unknown", comment: "")
        }
    }
}
