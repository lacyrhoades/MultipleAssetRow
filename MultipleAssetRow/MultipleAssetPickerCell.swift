//
//  MultipleAssetPickerCell.swift
//  ImageRow
//
//  Created by Lacy Rhoades on 10/17/17.
//

import UIKit

class MultipleAssetPickerCell: UICollectionViewCell {
    public static let cellReuseIdentifier = "MultipleAssetPickerCell"
    
    let icon = UIImageView()
    let thinLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.contentView.backgroundColor = .white
        
        icon.contentMode = .scaleAspectFit
        icon.image = UIImage(named: "folder", in: Bundle(for: MultipleAssetPickerCell.self), compatibleWith: nil)
        icon.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(icon)
        
        thinLine.backgroundColor = .darkGray
        thinLine.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(thinLine)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[icon]-[thinLine]|", options: [], metrics: [:], views: ["icon": icon, "thinLine": thinLine]))
        self.contentView.addConstraint(NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal, toItem: icon, attribute: .width, multiplier: 1, constant: 1.0))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(margin)-[icon]-(margin)-|", options: [], metrics: ["margin": 8.0], views: ["icon": icon, "thinLine": thinLine]))
        self.contentView.addConstraint(NSLayoutConstraint(item: thinLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: thinLine, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: 0))
    }
}
