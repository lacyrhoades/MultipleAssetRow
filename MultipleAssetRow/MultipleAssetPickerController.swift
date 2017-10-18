//
//  MultipleAssetPickerController.swift
//  ImageRow
//
//  Created by Lacy Rhoades on 10/17/17.
//

import UIKit

public protocol MultipleAssetPickerDelegate: class {
    var sourceType: MultipleAssetRowSourceTypes { get set }
    var assetChangeAction: (() -> ())? { get set }
    var numberOfAssets: Int { get }
}

class MultipleAssetPickerController: UIViewController {
    var sourceType: MultipleAssetRowSourceTypes!
    weak var assetDelegate: MultipleAssetPickerDelegate?
    
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        self.view.backgroundColor = .green
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(MultipleAssetPickerCell.self, forCellWithReuseIdentifier: MultipleAssetPickerCell.cellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.assetDelegate?.sourceType = self.sourceType
        self.assetDelegate?.assetChangeAction = {
            self.collectionView.reloadData()
        }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: [:], views: ["collectionView": collectionView]))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: [:], views: ["collectionView": collectionView]))
    }
}

extension MultipleAssetPickerController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.size.width, height: 48.0)
    }
}

extension MultipleAssetPickerController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetDelegate?.numberOfAssets ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleAssetPickerCell.cellReuseIdentifier, for: indexPath)
        
        return cell
    }
}
