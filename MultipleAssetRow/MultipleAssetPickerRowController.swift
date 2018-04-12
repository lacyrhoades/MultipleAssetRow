//  MultipleAssetPickerRowController.swift

import Eureka
import Foundation

/// Selector Controller used to pick an image
open class MultipleAssetPickerRowController: UIViewController, TypedRowControllerType {
    // for TypedRowControllerType
    public var row: RowOf<AssetSet>!
    public var onDismissCallback: ((UIViewController) -> Void)?
    
    // for us to know what kind of UI to use
    public var assetSourceType: MultipleAssetRowSourceTypes!
    public weak var assetDelegate: MultipleAssetPickerDelegate?
    
    private let pickerController = MultipleAssetPickerController()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.backgroundGray
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapDone))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        pickerController.title = self.row.title
        pickerController.sourceType = self.assetSourceType
        pickerController.assetDelegate = self.assetDelegate
        
        pickerController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pickerController.view)
        
        self.addChildViewController(self.pickerController)
        pickerController.didMove(toParentViewController: self)

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pickerView]|", options: [], metrics: [:], views: ["pickerView": self.pickerController.view]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pickerView]|", options: [], metrics: [:], views: ["pickerView": self.pickerController.view]))
    }
    
    @objc func didTapDone() {
        
        // If you don't set this to nil
        // The magic "did change" might not fire
        self.row.value = nil
        
        switch self.assetDelegate?.selectionMode {
        case .some(.pathOnly):
            var assetSet = AssetSet()
            assetSet.sourceType = self.assetDelegate?.sourceType
            assetSet.path = self.assetDelegate?.currentPath
            self.row.value = assetSet
            self.onDismissCallback?(self)
        case .some(.loadAsset):
            self.pickerController.getSelectedAssets(withProgress: { (progress) in
                self.pickerController.showFetched(progress: progress)
            }) { (assets) in
                if assets.isEmpty {
                    self.row.value = nil
                } else {
                    self.row.value = AssetSet(contents: assets)
                }
                self.onDismissCallback?(self)
            }
        default:
            return
        }
    }
    
    @objc func didTapCancel() {
        onDismissCallback?(self)
    }
}
