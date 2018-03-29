//
//  Assets.swift
//  ImageRow
//
//  Created by Lacy Rhoades on 10/13/17.
//

import Foundation

public typealias AssetID = String

public struct MultiAsset {
    public var name: String
    public var id: AssetID
    public init(name: String, id: AssetID) {
        self.name = name
        self.id = id
    }
}

public struct AssetSet {
    public var sourceType: MultipleAssetRowSourceTypes?
    public var path: String?
    
    public var contents: [MultiAsset]
    
    public var isEmpty: Bool {
        return self.contents.isEmpty
    }
    
    public init() {
        self.contents = []
    }
    
    public init(contents: [MultiAsset]) {
        self.contents = contents
    }

    public func appending(_ asset: MultiAsset) -> AssetSet {
        var set = self
        set.contents.append(asset)
        return set
    }
}

extension AssetSet: Equatable {
    public static func == (lhs: AssetSet, rhs: AssetSet) -> Bool {
        return lhs.contents.count == rhs.contents.count && lhs.contents.reduce(true, { (soFar, eachAssetID) -> Bool in
            return soFar && rhs.contents.contains(eachAssetID)
        })
    }
}

extension MultiAsset: Equatable {
    public static func == (lhs: MultiAsset, rhs: MultiAsset) -> Bool {
        return lhs.id == rhs.id
    }
}
