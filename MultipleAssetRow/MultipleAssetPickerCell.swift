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
    let titleLabel = UILabel()
    let thinLine = UIView()
    
    var asset: MultipleAssetPickerAsset? {
        didSet {
            self.titleLabel.text = asset?.name
            
            let frameworkBundle = Bundle(for: MultipleAssetPickerCell.self)
            let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("MultipleAssetRowResources.bundle")
            let resourceBundle = Bundle(url: bundleURL!)
            
            if let asset = asset {
                switch asset.type {
                case .folder:
                    icon.image = UIImage(named: "Folder", in: resourceBundle, compatibleWith: nil)
                case .file:
                    icon.image = UIImage(named: "File", in: resourceBundle, compatibleWith: nil)
                    if let fetch = asset.fetchThumbnail {
                        fetch() {
                            image in
                            self.icon.image = image
                        }
                    }
                case .image:
                    icon.image = UIImage(named: "Image", in: resourceBundle, compatibleWith: nil)
                    if let fetch = asset.fetchThumbnail {
                        fetch() {
                            image in
                            self.icon.image = image
                        }
                    }
                case .addNew:
                    icon.image = UIImage(named: "AddNew", in: resourceBundle, compatibleWith: nil)
                }
            } else {
                icon.image = nil
            }
            
        }
    }
    
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
        icon.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(icon)
        
        titleLabel.textColor = UIColor.darkText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(titleLabel)
        
        thinLine.backgroundColor = .lightGray
        thinLine.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(thinLine)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[icon]-[thinLine]|", options: [], metrics: [:], views: ["icon": icon, "thinLine": thinLine]))
        self.contentView.addConstraint(NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal, toItem: icon, attribute: .width, multiplier: 1, constant: 1.0))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(margin)-[icon]-(margin)-|", options: [], metrics: ["margin": 8.0], views: ["icon": icon]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(margin)-[titleLabel]-(margin)-|", options: [], metrics: ["margin": 8.0], views: ["titleLabel": titleLabel]))
        self.contentView.addConstraint(NSLayoutConstraint(item: thinLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: thinLine, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: 0))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: thinLine, attribute: .leading, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: thinLine, attribute: .trailing, multiplier: 1, constant: 0))
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.contentView.backgroundColor = UIColor.lightGray
            } else {
                self.contentView.backgroundColor = UIColor.white
            }
        }
    }
}
