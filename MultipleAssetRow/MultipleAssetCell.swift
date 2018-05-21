//  MultipleAssetCell.swift

import Eureka
import Photos

public final class MultipleAssetCell: PushSelectorCell<AssetSet> {
    var assetView = MultipleAssetView()
    
    public override func setup() {
        super.setup()
        
        if let path = self.row.value?.path, let type = self.row.value?.sourceType {
            self.assetView.emptyLabel.text = labelString(forPath: path, andSourceType: type)
        } else {
            self.assetView.emptyLabel.text = (self.row as? MultipleAssetRow)?.placeholderText ?? "None"
        }
        
        
        self.height = {
            var height: CGFloat = 46.0
            
            if let val = self.row.value {
                if let _ = val.path {
                    height = CGFloat(46.0)
                } else {
                    height = CGFloat(86.0)
                }
            }
            
            self.setNeedsLayout()
            
            return height
        }
        
        selectionStyle = .none
        accessoryType = .none
        editingAccessoryType = .none
        
        assetView.frame = self.bounds
        assetView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(assetView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: assetView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: assetView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: assetView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: assetView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0),
            ])
    }
    
    public override func update() {
        super.update()
        
        if let path = self.row.value?.path, let type = self.row.value?.sourceType {
            self.assetView.emptyLabel.text = labelString(forPath: path, andSourceType: type)
        } else {
            self.assetView.emptyLabel.text = (self.row as? MultipleAssetRow)?.placeholderText ?? "None"
        }
        
        accessoryType = .none
        editingAccessoryType = accessoryType
        selectionStyle = row.isDisabled ? .none : .default
        
        self.assetView.assets = row.value
        
        self.assetView.scrollView.alpha = (row.value == nil) ? 0.0 : 1.0
    }
}

class MultipleAssetView: UIView {
    var scrollView = UIScrollView()
    var stackView = CenteredStackView()
    var emptyLabel = UILabel()
    
    var assets: AssetSet? {
        didSet {
            self.showAssets()
        }
    }
    
    var touches: [UITouch] = []
    
    convenience init() {
        self.init(frame: .zero)
        
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 7.0
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        emptyLabel.textAlignment = .right
        emptyLabel.font = UIFont.systemFont(ofSize: 18.0)
        emptyLabel.textColor = UIColor.gray
        emptyLabel.text = "None"
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(emptyLabel)
        
        let widthConstraint = NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0)
        widthConstraint.priority = .defaultLow

        let margin: CGFloat = 16.0
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: emptyLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: emptyLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -1 * margin),
            NSLayoutConstraint(item: emptyLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: emptyLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -1 * margin),
            NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: margin),
            NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -1 * margin),
            
            NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0),
            widthConstraint,
        ])
    }
    
    func showAssets() {
        DispatchQueue.main.async {
            self.emptyLabel.isHidden = (self.assets?.isEmpty ?? true) == false
        }
        
        guard let assets = self.assets, assets.isEmpty == false else {
            if let path = self.assets?.path, let sourceType = self.assets?.sourceType {
                DispatchQueue.main.async {
                    self.emptyLabel.isHidden = false
                    self.emptyLabel.text = labelString(forPath: path, andSourceType: sourceType)
                }
            }
            
            DispatchQueue.main.async {
                self.stackView.removeAllArrangedSubviews()
            }
            
            return
        }
        
        let show: (_: [UIImage]) -> () = {
            images in
            
            self.stackView.removeAllArrangedSubviews()
            
            images.forEach({ (eachImage) in
                let view = UIView()
                view.clipsToBounds = true
                
                let frameworkBundle = Bundle(for: MultipleAssetPickerCell.self)
                let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("MultipleAssetRowResources.bundle")
                let resourceBundle = Bundle(url: bundleURL!)
                if let tile = UIImage(named: "TransparencyTile", in: resourceBundle, compatibleWith: nil) {
                    let bg = UIView()
                    bg.frame = view.bounds
                    bg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    bg.backgroundColor = UIColor(patternImage: tile)
                    view.addSubview(bg)
                }
                
                let imageView = UIImageView()
                imageView.frame = view.bounds
                imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                imageView.contentMode = .scaleAspectFill
                imageView.image = eachImage
                imageView.backgroundColor = .clear
                imageView.isOpaque = false
                imageView.layer.isOpaque = false
                view.addSubview(imageView)
                
                view.translatesAutoresizingMaskIntoConstraints = false
                self.stackView.addArrangedSubview(view)
                
                NSLayoutConstraint.activate([
                    NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: self.stackView, attribute: .height, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.5, constant: 0)
                ])
            })
        }
        
        let size: CGSize = CGSize(width: 200, height: 200)
        
        let imageRequests = DispatchGroup()
        
        let options = PHFetchOptions()
        
        let assetIDs = assets.contents.map { (eachAsset) -> AssetID in
            return eachAsset.id
        }
        
        DispatchQueue.global().async {
            let fetch = PHAsset.fetchAssets(withLocalIdentifiers: assetIDs, options: options)
            
            var results: [AssetID: UIImage] = [:]
            
            fetch.enumerateObjects({ (asset, index, test) in
                imageRequests.enter()
                
                let options = PHImageRequestOptions()
                
                PHCachingImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (maybeData, _, orientation, _) in
                    if let data = maybeData, let image = UIImage(data: data) {
                        let thumbnail = image.resized(toMaxSize: size)
                        results[asset.localIdentifier] = thumbnail
                    }
                    
                    imageRequests.leave()
                })
            })
            
            imageRequests.notify(queue: DispatchQueue.main, execute: {
                // The PHAsset fetch gives results in random order
                // So we sort them here back to the order which was requested
                var sortedResults: [UIImage] = []
                
                for eachAssetID in assetIDs {
                    if let asset = results[eachAssetID] {
                        sortedResults.append(asset)
                    }
                }
                
                show(sortedResults)
            })
        }
    }
}

class CenteredStackView: UIStackView {
    var leadingView = UIView()
    var trailingView = UIView()
    
    func removeAllArrangedSubviews() {
        self.arrangedSubviews.forEach { (eachSubview) in
            self.removeArrangedSubview(eachSubview)
        }
        
        self.addArrangedSubview(leadingView)
        self.addArrangedSubview(trailingView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: leadingView, attribute: .width, relatedBy: .equal, toItem: trailingView, attribute: .width, multiplier: 1, constant: 0)
        ])
    }
    
    override func addArrangedSubview(_ view: UIView) {
        let length = self.arrangedSubviews.count
        
        if (length == 2) {
            super.insertArrangedSubview(view, at: 1)
        } else if (length > 2) {
            self.removeArrangedSubview(self.leadingView)
            self.removeArrangedSubview(self.trailingView)
            super.addArrangedSubview(view)
        } else {
            super.addArrangedSubview(view)
        }
    }
}

extension MultipleAssetView: UIGestureRecognizerDelegate {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}

extension UIImage {
    func resized(toMaxSize maxSize: CGSize) -> UIImage {
        let maxResultWidth: CGFloat = maxSize.width // 720
        let maxResultHeight: CGFloat = maxSize.height // 960
        let maxRatio = maxResultWidth / maxResultHeight // 1.77777777
        
        var scaledWidth = maxResultWidth
        var scaledHeight = maxResultHeight
        
        let naturalRatio = self.size.width / self.size.height // 1.333333333
        
        if maxRatio >= naturalRatio {
            scaledHeight = maxResultHeight // fit to height
            scaledWidth = ceil(scaledHeight * naturalRatio) // fit to width
        } else {
            scaledWidth = maxResultWidth // fit to width
            scaledHeight = ceil(scaledWidth / naturalRatio)
        }
        
        let xOffset: CGFloat = floor((maxResultWidth - scaledWidth) / 2.0)
        let yOffset: CGFloat = floor((maxResultHeight - scaledHeight) / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(maxSize, false, 1.0);
        self.draw(in: CGRect(x: xOffset, y: yOffset, width: scaledWidth, height: scaledHeight))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return resultImage!
    }
}

func labelString(forPath path: String, andSourceType type: MultipleAssetRowSourceTypes) -> String {
    return String(format: "\"%@\" via %@", path.isEmpty ? "/" : path.truncatedTail(length: 20), type.localizedString)
}

extension String {
    func truncatedTail(length: Int, prefix: String? = "\u{2026}") -> String {
        if self.count > length {
            let min = index(endIndex, offsetBy: length * -1)
            return (prefix ?? "") + self[min..<endIndex]
        } else {
            return self
        }
    }
}
