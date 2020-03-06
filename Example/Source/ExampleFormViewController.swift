//
//  ExampleFormViewController.swift
//  Example
//
//  Created by Lacy Rhoades on 3/5/20.
//  Copyright © 2020 Lacy Rhoades. All rights reserved.
//

import Eureka
import MultipleAssetRow

class ExampleFormViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("MultipleAssetRow Example") { section in
            
        }
        <<< MultipleAssetRow() { row in
            row.title = "Pick an Image"
            var existingAssets = AssetSet()
            //if let overlay = FoboCore.Context.overlayManager.customLogo {
            //    existingAssets.contents.append(MultiAsset(name: overlay.name, id: overlay.assetID.string))
            //}
            row.value = existingAssets
            row.placeholderText = "Default Image(s)"
            row.availableSourceTypes = [.Dropbox, .PhotoLibrary, .SMBShare, .Google]
            row.assetDelegate = nil
        }
    }
}
