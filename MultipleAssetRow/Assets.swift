//
//  Assets.swift
//  ImageRow
//
//  Created by Lacy Rhoades on 10/13/17.
//

import Foundation

public typealias AssetID = String
public struct Assets {
    var value: [AssetID]
}

extension Assets: Equatable {
    public static func == (lhs: Assets, rhs: Assets) -> Bool {
        return lhs.value.count == rhs.value.count && lhs.value.reduce(true, { (soFar, eachAssetID) -> Bool in
            return soFar && rhs.value.contains(eachAssetID)
        })
    }
}
