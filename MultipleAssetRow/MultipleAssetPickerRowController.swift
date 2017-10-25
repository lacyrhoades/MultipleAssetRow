//  MultipleAssetPickerRowController.swift

import Eureka
import Foundation

/// Selector Controller used to pick an image
open class MultipleAssetPickerRowController: UIViewController, TypedRowControllerType {
    // for TypedRowControllerType
    public var row: RowOf<Assets>!
    public var onDismissCallback: ((UIViewController) -> Void)?
    
    // for us to know what kind of UI to use
    public var assetSourceType: MultipleAssetRowSourceTypes!
    public weak var assetDelegate: MultipleAssetPickerDelegate?
    
    private let pickerController = MultipleAssetPickerController()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        
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
        self.pickerController.getSelectedAssetIDs(withProgress: { (progress) in
            print(progress)
        }) { (assetIDs) in
            if assetIDs.isEmpty {
                self.row.value = nil
            } else {
                self.row.value = Assets(value: assetIDs)
            }
            self.onDismissCallback?(self)
        }
    }
    
    @objc func didTapCancel() {
        onDismissCallback?(self)
    }
}
